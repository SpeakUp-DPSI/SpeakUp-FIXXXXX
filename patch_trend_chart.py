import re

def patch_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Replace `_buildMonthlyTrendLineChart(stats.monthlyTrend),` with mock data
    mock_monthly_trend = "[{'month': 'Jan', 'total': 12}, {'month': 'Feb', 'total': 19}, {'month': 'Mar', 'total': 15}]"
    mock_by_category = "[{'category': 'Fisik', 'count': 20}, {'category': 'Verbal', 'count': 45}, {'category': 'Siber', 'count': 35}]"
    
    content = content.replace('stats.monthlyTrend', mock_monthly_trend)
    content = content.replace('stats.byCategory', mock_by_category)
    
    with open(filepath, 'w') as f:
        f.write(content)
    print(f"Patched {filepath}")

patch_file('speakup_web/lib/features/dashboard/presentation/screens/trend_chart_screen.dart')
try:
    patch_file('speakup_mobile/lib/features/dashboard/presentation/screens/trend_chart_screen.dart')
except:
    pass

