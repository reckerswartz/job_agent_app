# Profile Page Audit

## Profile Show (`/profile`)

**Title:** My Profile — Job Agent  
**Layout:** Dashboard

### Structure

- **Page Header:** "My Profile" / status badge "Complete" + "Structure with AI" button + "Edit Profile" link
- **Contact Card:** Name (Pankaj Kumar), Headline (Senior Ruby on Rails Developer), contact items (email, phone, location, LinkedIn link) using Bootstrap Icons
- **Summary Card:** Professional summary text
- **Work Experience Card:** 2 entries with title, company, dates, location, description
- **Education Card:** 1 entry with institution, degree, field, dates
- **Skills Card:** 10 skill badges with level (Expert/Advanced/Intermediate)
- **Certifications Card:** 1 entry with name, issuer, date
- **Extracted Resume Text:** Collapsible card with Show/Hide toggle

### Functionality Tests

| Element | Action | Result | Status |
|---------|--------|--------|--------|
| "Edit Profile" link | Click | Navigates to `/profile/edit` | PASS |
| "Structure with AI" button | Click | Submits form with loading state "Structuring..." | PASS |
| LinkedIn link | Click | Opens LinkedIn profile URL in new tab | PASS |
| "Show / Hide" toggle | Click | Expands/collapses extracted resume text | PASS |
| Status badge | Display | Shows "Complete" in green | PASS |
| Contact icons | Display | Bootstrap Icons for email, phone, geo, link | PASS |

### Issues

| # | Severity | Issue | Details |
|---|----------|-------|---------|
| PR-1 | Medium | No way to download resume PDF | Profile shows extracted text but no "Download Resume" button to get the original uploaded PDF |
| PR-2 | Low | Skills don't show category grouping | Skills are listed flat — could be grouped by category (Backend, Frontend, DevOps/Tools) |
| PR-3 | Low | Work experience entries not clearly separated | No visual divider between work experience entries |

---

## Profile Edit (`/profile/edit`)

**Title:** Edit Profile — Job Agent

### Structure

- **Page Header:** "Edit Profile" / status badge + "View Profile" link
- **6 Tabs:** Resume, Contact, Experience, Education, Skills, Other
- **Resume Tab:** Upload zone with file info, "Upload & Parse" button, extracted text preview
- **Contact Tab:** Profile Title, Headline, First/Last Name, Email, Phone, City, Country, LinkedIn, Website, Summary — "Save Contact Details" + Cancel
- **Experience/Education/Skills/Other tabs:** Section-specific entry management

### Functionality Tests

| Element | Action | Result | Status |
|---------|--------|--------|--------|
| Tab navigation | Click each tab | All 6 tabs switch content correctly | PASS |
| Contact tab fields | Display | Pre-filled with seeded data (Pankaj, Kumar, etc.) | PASS |
| "Save Contact Details" | Click | Saves and shows success toast | PASS |
| "View Profile" link | Click | Navigates back to `/profile` | PASS |
| "Cancel" link | Click | Navigates back to `/profile` | PASS |
| Resume upload zone | Display | Shows current file name and size | PASS |

### Issues

| # | Severity | Issue | Details |
|---|----------|-------|---------|
| PR-4 | Medium | Tab state not preserved in URL | Clicking a tab doesn't update the URL hash — refreshing always returns to Resume tab |
| PR-5 | Low | No inline validation on contact form | Fields don't show validation errors until form submit |
