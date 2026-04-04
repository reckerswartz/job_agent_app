# Master Audit Summary — Job Agent App

**Date:** 2026-04-04 (Session 10)  
**Pages Audited:** 20+ pages across 13 detailed reports  
**Test Users:** `demo@jobagent.dev` (regular), `admin@jobagent.dev` (admin)

---

## All Issues by Severity

### Medium (14 issues)

| ID | Page | Issue |
|----|------|-------|
| A-1 | Sign In | No "Forgot Password?" link despite Devise recoverable being enabled |
| D-1 | Dashboard | Stat cards are not clickable — users expect to click "18 Jobs Found" to navigate to listings |
| D-2 | Dashboard | Activity feed icons have no accessible text for screen readers |
| S-1 | Job Sources | "Scan Now" has no loading indicator after click |
| S-2 | Job Sources | "Remove" button has no confirmation dialog |
| AP-1 | Applications | No "Board View" link on list page (asymmetric navigation) |
| AP-3 | Pipeline Board | Drag-and-drop has no visual drop zone highlight feedback |
| AN-1 | Analytics | No date range filter — all charts show all-time data |
| AN-2 | Analytics | Charts are not interactive (no tooltips or drill-down) |
| AC-1 | Activity Logs | No search capability for activity descriptions |
| PR-1 | Profile | No way to download the uploaded resume PDF |
| PR-4 | Profile Edit | Tab state not preserved in URL — refresh resets to Resume tab |
| ST-1 | Settings | Two separate save buttons instead of a single "Save All" |
| N-1 | Notifications | No category filter tabs (unlike Activity Logs) |
| N-2 | Notifications | Action URL column not rendered as clickable link |
| MO-1 | Mobile | Pipeline board not usable on mobile (1820px wide, touch drag issues) |
| AD-1 | Admin | Admin stat cards show system-wide counts but listing pages are scoped per-user |

### Low (19 issues)

| ID | Page | Issue |
|----|------|-------|
| H-1 | Home | Feature card Bootstrap Icons have no aria-label |
| H-2 | Home | Footer is minimal vs dashboard footer |
| A-2 | Sign In | No password visibility toggle |
| A-3 | Sign Up | No password strength indicator |
| D-3 | Dashboard | Upcoming Interviews rows not linked to application detail |
| D-4 | Dashboard | No "View All" link for Recent Activity |
| S-3 | Job Sources | No listing count per source card |
| S-4 | Job Sources | Search Criteria section shows no criteria summary |
| AP-2 | Applications | No search/filter on application list |
| AP-4 | Pipeline Board | Board overflows horizontally on < 1920px screens |
| AP-5 | Applications | No "Board View" link on list page (duplicate of AP-1) |
| L-2 | Job Listings | Match range filter inputs have no visible labels |
| L-3 | Job Listings | Bulk action bar always visible even with 0 selected |
| AN-3 | Analytics | No export/download for chart data |
| AC-2 | Activity Logs | No date range filter |
| AC-3 | Activity Logs | Descriptions don't link to relevant resources |
| PR-2 | Profile | Skills not grouped by category |
| PR-3 | Profile | Work experience entries lack visual separation |
| ST-2 | Settings | No "unsaved changes" indicator |
| MO-2 | Mobile | Notification dropdown may overflow on xs viewport |
| MO-3 | Mobile | Filter panel wraps awkwardly on mobile |
| DM-1 | Dark Mode | Home/auth pages don't have dark mode toggle |

### Info (10 issues)

| ID | Page | Issue |
|----|------|-------|
| H-3 | Home | No "Forgot Password" link visible on home |
| A-4 | Auth | Brand icon has no accessible text |
| D-5 | Dashboard | Search placeholder could be more specific |
| L-4 | Listings | Status badge colors could be more distinct |
| AN-4 | Analytics | Scan Success Rate card doesn't match chart visual style |
| AN-5 | Analytics | Source names lowercase in charts |
| AC-4 | Activity | No bulk delete/clear history |
| ST-4 | Settings | No account/password change section |
| I-2 | Interventions | Type icons lack accessible text |
| DM-2 | Dark Mode | Bootstrap Icons inherit color correctly (positive) |

---

## Fix Phases

### Phase 1 — High-Impact UX Fixes (7 items)

Quick wins that significantly improve usability:

1. **D-1: Make stat cards clickable** — Wrap each stat card in `<a>` linking to the relevant page
2. **AP-1/AP-5: Add "Board View" link to applications list** — Mirror the "Table View" link on the board
3. **S-2: Add confirmation to source Remove button** — Add `data-turbo-confirm`
4. **D-4: Add "View All" link to Recent Activity** — Link to `/activity`
5. **D-3: Link interview rows to application detail** — Make upcoming interviews clickable
6. **A-1: Add "Forgot Password?" link to sign-in** — Link to Devise password reset
7. **N-2: Make notification action URLs clickable** — Render as `<a>` links in the table

### Phase 2 — Interaction Polish (5 items)

Better feedback and flow:

8. **S-1: Add loading state to "Scan Now" button** — Use `loading-button` Stimulus controller
9. **L-3: Hide bulk action bar until first selection** — JS toggle visibility
10. **PR-4: Preserve tab state in URL hash** — Update URL on tab click, restore on load
11. **PR-1: Add resume download button** — Link to Active Storage blob URL on profile show
12. **ST-1: Merge save buttons into one** — Single "Save Settings" at bottom

### Phase 3 — Accessibility & Polish (5 items)

Screen reader support and visual consistency:

13. **D-2/I-2/H-1/A-4: Add aria-labels to Bootstrap Icons** — Add `aria-hidden="true"` to decorative icons, `aria-label` to functional ones
14. **L-2: Add visible labels to match range inputs** — Replace placeholders with labels
15. **AC-3: Link activity descriptions to resources** — Wrap resource names in links
16. **AN-5: Capitalize source names in analytics charts** — Transform keys before rendering
17. **PR-3: Add visual separators between work entries** — CSS border-bottom or `<hr>`

### Phase 4 — Future Enhancements (not immediate)

- AN-1: Date range filter for analytics
- AN-2: Interactive charts (consider switching to ApexCharts)
- AC-1: Search for activity logs
- MO-1: Mobile-optimized pipeline board (vertical stack)
- AD-1: Clarify admin scope vs user scope in dashboard
