-- ============================================================================
-- FIXED VERSION — Jalankan ini, BUKAN versi dari Antigravity sebelumnya.
-- Perbaikan: enum 'resolved' tidak valid, kolom created_by -> user_id,
-- tipe parameter uuid -> bigint, guard staff-only, pin search_path.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Function: dashboard_statistics
--    FIX: hapus literal enum 'resolved' yang tidak ada; tambah guard staff-only
--    karena SECURITY DEFINER melewati RLS (tanpa guard, siswa/ortu bisa lihat
--    statistik seluruh sekolah).
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.dashboard_statistics()
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    total_count int;
    today_count int;
    this_month_count int;
    valid_count int;
    processing_count int;
    mediation_count int;
    completed_count int;
BEGIN
    IF NOT public.is_staff() THEN
        RAISE EXCEPTION 'Hanya staff (admin/guru_bk/kepsek) yang boleh mengakses statistik dashboard';
    END IF;

    SELECT count(*) INTO total_count FROM public.reports;
    SELECT count(*) INTO today_count FROM public.reports WHERE date(created_at) = current_date;
    SELECT count(*) INTO this_month_count FROM public.reports WHERE date_trunc('month', created_at) = date_trunc('month', current_date);
    SELECT count(*) INTO valid_count FROM public.reports WHERE status = 'valid';
    SELECT count(*) INTO processing_count FROM public.reports WHERE status = 'processing';
    SELECT count(*) INTO mediation_count FROM public.reports WHERE status = 'mediation';
    SELECT count(*) INTO completed_count FROM public.reports WHERE status = 'completed';

    RETURN json_build_object(
        'total', total_count,
        'today', today_count,
        'this_month', this_month_count,
        'valid', valid_count,
        'processing', processing_count,
        'mediation', mediation_count,
        'completed', completed_count
    );
END;
$$;

REVOKE EXECUTE ON FUNCTION public.dashboard_statistics() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.dashboard_statistics() TO authenticated;

-- ----------------------------------------------------------------------------
-- 2. Function: get_my_mediations
--    FIX: pin search_path (best practice untuk SECURITY DEFINER).
--    Tidak ada bug logika — kondisi select-nya sudah konsisten dengan RLS
--    policy "mediations_select" yang sudah ada.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_my_mediations()
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    uid uuid := auth.uid();
    result json;
BEGIN
    SELECT json_agg(m) INTO result
    FROM (
        SELECT
            med.*,
            (SELECT json_build_object('id', p.id, 'name', p.name, 'email', p.email)
             FROM public.profiles p WHERE p.id = med.mediator_id) as mediator,
            (SELECT json_build_object('id', r.id, 'report_code', r.report_code, 'title', r.title)
             FROM public.reports r WHERE r.id = med.report_id) as report,
            (SELECT json_agg(
                json_build_object(
                    'id', mp.id,
                    'user_id', mp.user_id,
                    'status', mp.status,
                    'user', (SELECT json_build_object('name', p2.name) FROM public.profiles p2 WHERE p2.id = mp.user_id)
                )
             ) FROM public.mediation_participants mp WHERE mp.mediation_id = med.id) as participants
        FROM public.mediations med
        WHERE med.mediator_id = uid
           OR med.id IN (SELECT mediation_id FROM public.mediation_participants WHERE user_id = uid)
    ) m;
    RETURN COALESCE(result, '[]'::json);
END;
$$;

REVOKE EXECUTE ON FUNCTION public.get_my_mediations() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_my_mediations() TO authenticated;

-- ----------------------------------------------------------------------------
-- 3. Trigger & Function: Generate Report Code sebelum insert ke reports
--    Tidak ada bug — dipakai apa adanya.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.generate_report_code()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.report_code IS NULL THEN
        NEW.report_code := 'REP-' || to_char(current_date, 'YYYYMMDD') || '-' || upper(substring(md5(random()::text) from 1 for 6));
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_generate_report_code ON public.reports;
CREATE TRIGGER trg_generate_report_code
BEFORE INSERT ON public.reports
FOR EACH ROW
EXECUTE FUNCTION public.generate_report_code();

-- ----------------------------------------------------------------------------
-- 4. Trigger & Function: Track report status history setelah update
--    FIX: kolom "created_by" -> "user_id" (nama kolom asli di tabel),
--    tambah cast eksplisit ::text agar aman dari enum->text.
--    CATATAN: ini hanya menangkap perubahan status (UPDATE), bukan status
--    awal saat report dibuat. Tambahkan trigger AFTER INSERT terpisah
--    (lihat bagian 4b) kalau ingin histori status awal juga tercatat.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.track_report_status_history()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO public.report_status_histories (report_id, user_id, status, notes)
        VALUES (NEW.id, auth.uid(), NEW.status::text, 'Status changed');
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_track_report_status ON public.reports;
CREATE TRIGGER trg_track_report_status
AFTER UPDATE ON public.reports
FOR EACH ROW
EXECUTE FUNCTION public.track_report_status_history();

-- 4b. (Opsional, disarankan) — catat status awal saat report pertama dibuat
CREATE OR REPLACE FUNCTION public.track_report_status_initial()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
    INSERT INTO public.report_status_histories (report_id, user_id, status, notes)
    VALUES (NEW.id, auth.uid(), NEW.status::text, 'Laporan dibuat');
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_track_report_status_initial ON public.reports;
CREATE TRIGGER trg_track_report_status_initial
AFTER INSERT ON public.reports
FOR EACH ROW
EXECUTE FUNCTION public.track_report_status_initial();

-- ----------------------------------------------------------------------------
-- 5. RPC contact_participant (masih placeholder)
--    FIX: parameter uuid -> bigint (sesuai tipe mediations.id).
--    Tambah guard: hanya mediator laporan tsb atau staff yang boleh panggil.
--    PENTING: RAISE NOTICE tidak terlihat oleh user/app — ini masih STUB.
--    Sebelum dipakai di production, ganti isinya dengan logika nyata, misalnya
--    insert ke tabel notifications untuk tiap participant, atau panggil
--    Edge Function pengirim WA/email/FCM.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.contact_participant(mediation_id bigint)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_mediator_id uuid;
BEGIN
    SELECT mediator_id INTO v_mediator_id FROM public.mediations WHERE id = mediation_id;

    IF v_mediator_id IS NULL THEN
        RAISE EXCEPTION 'Mediasi dengan id % tidak ditemukan', mediation_id;
    END IF;

    IF NOT (public.is_staff() OR v_mediator_id = auth.uid()) THEN
        RAISE EXCEPTION 'Tidak berwenang menghubungi peserta mediasi ini';
    END IF;

    -- TODO: ganti dengan logika nyata, contoh minimal: buat notifikasi in-app
    INSERT INTO public.notifications (user_id, title, body, type, reference_id)
    SELECT mp.user_id,
           'Pengingat Mediasi',
           'Anda memiliki jadwal mediasi yang perlu dikonfirmasi.',
           'mediation_schedule',
           mediation_id::text
    FROM public.mediation_participants mp
    WHERE mp.mediation_id = contact_participant.mediation_id;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.contact_participant(bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.contact_participant(bigint) TO authenticated;
