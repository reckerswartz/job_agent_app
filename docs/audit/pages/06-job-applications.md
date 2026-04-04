# Job Applications Page Audit

## List View (`/job_applications`)

**Title:** Applications — Job Agent

### Structure
- **Page Header:** "Applications" / "6 applications"
- **Status Tabs:** All (6)
- **Table:** Position (linked), Company, Match %, Stage badge, Status badge, Applied date, Actions

### Functionality Tests

| Element | Action | Result | Status |
|---------|--------|--------|--------|
| Application link | Click | Navigates to `/job_applications/:id` detail | PASS |
| Status tabs | Display | "All (6)" tab visible | PASS |
| Stage badges | Display | Shows Interviewing, Screening, Offered, Applied, Rejected | PASS |

### Issues

| # | Severity | Issue | Details |
|---|----------|-------|---------|
| AP-1 | Medium | No link to Pipeline Board view | The list view doesn't have a "Board View" toggle — only the board has "Table View" link. Should be bidirectional |
| AP-2 | Low | No search/filter capability | Unlike Job Listings, applications have no search bar or stage filter dropdowns |

---

## Pipeline Board (`/job_applications/board`)

**Title:** Pipeline Board — Job Agent

### Structure
- **Page Header:** "Pipeline Board" / "6 applications" + "Table View" link
- **7 Kanban Columns:** Applied (1), Screening (1), Interviewing (2), Offered (1), Accepted (0), Rejected (1), Withdrawn (0)
- Each column: header with stage name + count badge, draggable cards or "No applications yet" / "Drag cards here"

### Functionality Tests

| Element | Action | Result | Status |
|---------|--------|--------|--------|
| "Table View" link | Click | Navigates to `/job_applications` | PASS |
| Draggable cards | Display | Cards have `draggable="true"`, show title, company, match %, time | PASS |
| Card link | Click | Navigates to application detail | PASS |
| Empty columns | Display | "No applications yet" for Accepted/Withdrawn, "Drag cards here" would show if other columns had apps | PASS |
| Column counts | Display | Badge counts match actual card counts | PASS |

### Issues

| # | Severity | Issue | Details |
|---|----------|-------|---------|
| AP-3 | Medium | Drag-and-drop feedback unclear | No visual drop zone highlight when dragging a card — hard to know where to drop |
| AP-4 | Low | Board overflows horizontally on smaller screens | 7 columns at 260px each = 1820px — needs horizontal scrolling on < 1920px screens |
| AP-5 | Low | No "Board View" link on list page | Asymmetric navigation — board has "Table View" but table doesn't have "Board View" |
