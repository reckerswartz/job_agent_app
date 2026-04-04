# Job Listings Page Audit

**URL:** `/job_listings`  
**Title:** Job Listings — Job Agent  
**Layout:** Dashboard

## Structure

- **Page Header:** "Job Listings" / "18 listings found" + "Export CSV" link
- **Search Bar:** Text input + Search button + Clear link (when query active)
- **Collapsible Filters:** Toggle button "Filters" → Remote, Type, Source, Match range, Easy Apply checkbox, Filter button
- **Status Tabs:** All (18), New (6), Reviewed (2), Saved (2), Applied (6), Rejected (1), Expired (1)
- **Bulk Action Bar:** Checkbox select-all, "0 selected", Save Selected, Reject Selected
- **Table:** Checkbox, Position (sortable), Company (sortable), Location, Match (sortable), Source badge, Status badge, Posted (sortable)

## Functionality Tests

| Element | Action | Result | Status |
|---------|--------|--------|--------|
| Search input | Type "Shopify" + Search | Filters to Shopify listing | PASS |
| Clear search | Click Clear | Returns to full listing | PASS |
| "Filters" toggle | Click | Expands/collapses filter panel | PASS |
| Remote filter | Select "Remote" | Filters to remote-only listings | PASS |
| Source filter | Select "Linkedin" | Filters by LinkedIn source | PASS |
| Easy Apply checkbox | Toggle | Filters easy-apply listings | PASS |
| Status tab "Applied" | Click | Shows 6 applied listings, URL has `?status=applied` | PASS |
| Status tab "New" | Click | Shows 6 new listings | PASS |
| Column sort "Match" | Click | Sorts by match score desc | PASS |
| Column sort "Posted" | Click | Sorts by posted date | PASS |
| Bulk select-all | Toggle | Selects all checkboxes, updates count | PASS |
| Export CSV | Click | Downloads CSV file | PASS |
| Listing link | Click | Navigates to `/job_listings/:id` detail page | PASS |

## UI/UX Findings

### Positive
- Comprehensive filtering: status tabs, search, advanced filters (Remote/Type/Source/Match/Easy Apply)
- Collapsible filter panel reduces clutter — auto-expands when filters are active
- Sortable columns with visual indicators
- Bulk selection with Save/Reject actions
- Export CSV for data portability
- Match score color-coded badges (green high, yellow medium, red low)
- Source platform badges with distinct colors

### Issues

| # | Severity | Issue | Details |
|---|----------|-------|---------|
| L-1 | Medium | No pagination visible | All 18 listings shown on one page. With more data, this will need pagination (Pagy is configured but no paginator rendered for < 20 items) |
| L-2 | Low | Match range filter has no labels on inputs | The min/max spinbuttons have no visible "Min"/"Max" labels, just placeholders |
| L-3 | Low | Bulk action bar always visible | "0 selected" bar shows even when nothing selected — should hide until first selection |
| L-4 | Info | Status badge colors could be more distinct | "New" and "Applied" badges use similar blue shades |
