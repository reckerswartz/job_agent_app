# Dark Mode, Mobile Responsiveness & Error Pages Audit

## Dark Mode

**Toggle:** Topbar button (Bootstrap Icon `bi-moon-fill` ↔ `bi-sun-fill`)  
**Persistence:** localStorage  
**Implementation:** CSS custom properties via `[data-theme="dark"]`

### Functionality Tests

| Element | Action | Result | Status |
|---------|--------|--------|--------|
| Toggle light→dark | Click moon icon | Theme switches to dark, icon becomes sun | PASS |
| Toggle dark→light | Click sun icon | Theme switches to light, icon becomes moon | PASS |
| Persistence | Refresh page | Theme persists from localStorage | PASS |
| Sidebar | Dark mode | Sidebar is already dark-themed, stays consistent | PASS |
| Stat cards | Dark mode | Background adapts to dark theme | PASS |
| Tables | Dark mode | Text and borders adapt | PASS |
| Footer | Dark mode | Text color adapts | PASS |

### Issues

| # | Severity | Issue | Details |
|---|----------|-------|---------|
| DM-1 | Low | Home/auth pages don't have dark mode toggle | Only the dashboard layout has the toggle — landing and auth pages always use light theme |
| DM-2 | Info | Bootstrap Icons inherit text color correctly | Icons use `currentColor` so they adapt to dark mode automatically |

---

## Mobile Responsiveness (375×812 — iPhone SE)

### Functionality Tests

| Element | Action | Result | Status |
|---------|--------|--------|--------|
| Sidebar | Display | Hidden by default (CSS `translateX(-100%)`) | PASS |
| Hamburger toggle | Display | Visible in topbar | PASS |
| Hamburger toggle | Click | Sidebar slides in with overlay | PASS |
| Sidebar overlay | Click | Sidebar closes | PASS |
| Topbar search | Display | Hidden on xs viewports | PASS |
| Stat cards | Display | Stack 2-per-row on mobile | PASS |
| Tables | Display | Horizontal scroll via `.table-responsive` | PASS |
| Page header | Display | Title and actions stack vertically | PASS |
| Touch targets | Display | Sidebar links have 44px min-height (WCAG) | PASS |

### Issues

| # | Severity | Issue | Details |
|---|----------|-------|---------|
| MO-1 | Medium | Pipeline board not usable on mobile | 7 columns × 260px = 1820px — horizontally scrollable but cramped, drag-and-drop may not work with touch |
| MO-2 | Low | Notification bell dropdown may overflow on xs | 320px dropdown on 375px screen leaves 55px margin — could clip |
| MO-3 | Low | Filter panel in job listings may be hard to use on mobile | Multiple dropdowns in a row wrap awkwardly |

---

## Error Pages

**Implementation:** Custom error pages via `config.exceptions_app = self.routes`  
**Note:** Only render in production; development shows Rails debug page

### Pages

| URL | Title | Status |
|-----|-------|--------|
| `/404` | Page Not Found — Job Agent | PASS (Bootstrap Icon search, CTA to dashboard/home) |
| `/422` | Unable to Process — Job Agent | PASS (Bootstrap Icon slash-circle) |
| `/500` | Something Went Wrong — Job Agent | PASS (Bootstrap Icon exclamation-triangle) |

### Issues

| # | Severity | Issue | Details |
|---|----------|-------|---------|
| ER-1 | Info | Error pages use application layout (no sidebar) | Consistent with auth pages — appropriate for error context |
