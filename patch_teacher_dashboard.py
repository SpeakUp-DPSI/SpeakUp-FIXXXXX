import re

def patch_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # 1. Remove Quick Actions
    quick_actions_regex = r'// ─── Quick Actions \(Carousel style\) ──────────────.*?const SizedBox\(height: 16\),'
    content = re.sub(quick_actions_regex, '', content, flags=re.DOTALL)
    
    # Also remove _quickAction method if it's there
    quick_action_method = r'Widget _quickAction\(.*?\}\n'
    content = re.sub(quick_action_method, '', content, flags=re.DOTALL)

    # 2. Fix Recent Reports layout to prevent overflow on mobile
    # Original:
    #                                                 if (r.incidentDate != null)
    #                                                   Text(
    #                                                     r.incidentDate!,
    #                                                     style: const TextStyle(
    #                                                         fontSize: 10,
    #                                                         color:
    #                                                             AppTheme.neutral400),
    #                                                   ),
    #                                                 const SizedBox(width: 8),
    #                                                 Container(
    #                                                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    #                                                   decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(20)),
    #                                                   child: Text(badgeLabel, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
    #                                                 ),
    #                                                 const SizedBox(width: 4),
    #                                                 const Icon(Icons.chevron_right, size: 18, color: AppTheme.neutral400),
    
    # We will wrap the badge and chevron in a column or just remove the date from the right and put it under the title, or change Row structure.
    # Actually, putting date under the category is safer.
    
    # Let's replace the right side of the row.
    right_side_orig = r'if \(r\.incidentDate != null\).*?const Icon\(Icons\.chevron_right, size: 18, color: AppTheme\.neutral400\),'
    right_side_new = """
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: badgeColor,
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: Text(
                                                        badgeLabel,
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    if (r.incidentDate != null) ...[
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        r.incidentDate!,
                                                        style: const TextStyle(
                                                          fontSize: 10,
                                                          color: AppTheme.neutral400,
                                                        ),
                                                      ),
                                                    ]
                                                  ],
                                                ),
                                                const SizedBox(width: 4),
                                                const Icon(Icons.chevron_right, size: 18, color: AppTheme.neutral400),
"""
    content = re.sub(right_side_orig, right_side_new.strip('\n'), content, flags=re.DOTALL)

    with open(filepath, 'w') as f:
        f.write(content)
    print(f"Patched {filepath}")

patch_file('speakup_web/lib/features/dashboard/presentation/screens/teacher_dashboard_screen.dart')
patch_file('speakup_mobile/lib/features/dashboard/presentation/screens/teacher_dashboard_screen.dart')

