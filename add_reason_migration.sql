-- Menambahkan kolom reason (alasan) ke tabel mediation_participants
ALTER TABLE public.mediation_participants 
ADD COLUMN IF NOT EXISTS reason TEXT;
