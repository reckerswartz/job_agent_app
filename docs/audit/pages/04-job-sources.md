# Job Sources Page Audit

**URL:** `/job_sources`  
**Title:** Job Sources — Job Agent  
**Layout:** Dashboard

## Structure

- **Page Header:** "Job Sources" / "Manage the job boards you want to search" + "Add Source" button
- **Source Cards (3):** Each shows platform badge, name, base URL, enabled/active status, scan interval, last scanned time, action buttons
- **Separator + Search Criteria section** with "Manage Criteria" link

### Source Card Actions
Each card has: Scan Now, History, Disable, Edit, Remove

## Functionality Tests

| Element | Action | Result | Status |
|---------|--------|--------|--------|
| "Add Source" button | Click | Navigates to `/job_sources/new` | PASS |
| "Edit" link | Click | Navigates to `/job_sources/:id/edit` | PASS |
| "History" link | Click | Navigates to `/job_sources/:id/scan_runs` | PASS |
| "Manage Criteria" link | Click | Navigates to `/job_search_criteria` | PASS |
| Platform badges | Display | Shows "Naukri", "Indeed", "Linkedin" with color coding | PASS |
| Enabled/Active status | Display | Both show green badges | PASS |
| Scan interval | Display | Shows "8h", "12h", "6h" correctly | PASS |
| Last scanned timestamps | Display | Relative times shown correctly | PASS |

## UI/UX Findings

### Positive
- Cards are well-organized with clear status indicators
- Action buttons provide full CRUD + scan operations
- Platform color-coded badges (Naukri=danger, Indeed=purple, LinkedIn=primary)
- Search Criteria section visible below sources

### Issues

| # | Severity | Issue | Details |
|---|----------|-------|---------|
| S-1 | Medium | "Scan Now" has no loading indicator | After clicking, there's no visual feedback that a scan has started — user doesn't know if it's working |
| S-2 | Medium | "Remove" button has no confirmation dialog | Clicking "Remove" deletes the source immediately — should use `data-turbo-confirm` |
| S-3 | Low | No listing count per source | Cards don't show how many listings each source has found — useful context for evaluating source value |
| S-4 | Low | Search Criteria section shows no criteria details | Just "Search Criteria" heading and "Manage Criteria" link — could show a summary of active criteria |
