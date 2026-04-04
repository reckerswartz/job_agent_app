# Activity Logs Page Audit

**URL:** `/activity`  
**Title:** Activity — Job Agent  
**Layout:** Dashboard

## Structure

- **Page Header:** "Activity" / "Your action history"
- **Category Filter Tabs:** All (14), Scan (3), Application (4), Listing (1), Profile (2), Settings (3)
- **Table:** When (sortable), Action (sortable), Description, Category badge

## Functionality Tests

| Element | Action | Result | Status |
|---------|--------|--------|--------|
| Category tabs | Click "Scan" | Filters to scan-related entries, URL adds `?category=scan` | PASS |
| Category tabs | Click "All" | Shows all 14 entries | PASS |
| Sort by When | Click column header | Sorts by timestamp | PASS |
| Sort by Action | Click column header | Sorts by action name | PASS |
| Category badges | Display | Color-coded badges for each category | PASS |
| Timestamps | Display | Relative times ("2 hours ago", "3 days ago") shown correctly | PASS |

## UI/UX Findings

### Positive
- Category tabs dynamically show only categories with data
- Sortable columns for When and Action
- Color-coded category badges
- Clean table layout with clear descriptions

### Issues

| # | Severity | Issue | Details |
|---|----------|-------|---------|
| AC-1 | Medium | No search capability | Can't search activity by description text — useful for finding specific actions |
| AC-2 | Low | No date range filter | Can't filter by date range — all history shown at once |
| AC-3 | Low | Descriptions are plain text | Some descriptions could link to the relevant resource (e.g., "Applied to X at Y" could link to the application) |
| AC-4 | Info | No bulk delete or clear history | Users can't clear old activity entries |
