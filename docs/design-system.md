# Job Agent Design System

## Colors (from `config/_variables.scss`)

| Variable | Value | Usage |
|----------|-------|-------|
| `$primary` | `#1E3A5F` | Deep navy — trust, professionalism |
| `$secondary` | `#4ECDC4` | Teal — energy, opportunity |
| `$accent` | `#FF6B6B` | Coral — urgency, call-to-action |
| `$success` | `#10B981` | Green — applied, matched, ok |
| `$warning` | `#F59E0B` | Amber — running, pending, expiring |
| `$danger` | `#EF4444` | Red — errors, failed |
| `$info` | `#3B82F6` | Blue — informational, new |
| `$light` | `#F8F9FA` | Warm white — backgrounds |
| `$dark` | `#1A1A2E` | Near-black — text |

## Shared Partials

| Partial | Params | Used In |
|---------|--------|---------|
| `shared/_page_header` | `title`, `subtitle` (opt), `actions` (opt) | All index + detail pages |
| `shared/_empty_state` | `icon`, `title`, `message`, `cta_text` (opt), `cta_path` (opt) | 6 empty list views |
| `shared/_stat_card` | `value`, `label`, `icon`, `color` | User + admin dashboards |
| `shared/_filter_tabs` | `tabs` (array of `{label, count, path, active}`) | Listings, applications, interventions |
| `shared/_pagination` | `pagy` | All paginated tables |
| `shared/_processing_banner` | `profile` | Profile show + edit |

## Badge Helper

Use `BadgeHelper#status_badge(value, :context)` for consistent badge rendering.

```ruby
status_badge("completed", :scan)    # => <span class="badge bg-success">Completed</span>
badge_color("failed", :application) # => "danger"
```

### Contexts

| Context | Values |
|---------|--------|
| `:listing` | new=info, reviewed=secondary, saved=primary, applied=success, rejected=danger, expired=dark |
| `:application` | queued=secondary, in_progress=warning, submitted=success, failed=danger, needs_intervention=info |
| `:scan` | queued=secondary, running=warning, completed=success, failed=danger |
| `:verification` | ok=success, failed=danger, timeout=warning, untested=secondary |
| `:model_type` | text=primary, vision=warning, multimodal=info |
| `:role` | admin=danger, user=secondary |

## Data Tables

Use `DataTableable` concern in controllers + `DataTableHelper` in views.

```ruby
# Controller
include DataTableable
scope = apply_sorting(scope, %w[name status created_at], default_column: "created_at")
@pagy, @items = pagy(scope, limit: per_page_limit)

# View
sort_indicator("name")           # => " ▲" or " ▼" or ""
sort_url("name", items_path)     # => "/items?sort=name&dir=asc"
```

## SCSS Architecture

```
config/
  _variables.scss          # Bootstrap overrides, brand colors
  _dark_theme.scss         # [data-theme="dark"] overrides

components/
  _auth.scss               # Sign in/up forms
  _buttons.scss            # Button variants
  _cards.scss              # Landing page cards
  _file-upload.scss        # Drag-and-drop upload zone
  _footer.scss             # Landing footer
  _hero.scss               # Landing hero
  _navbar.scss             # Landing navbar
  _onboarding.scss         # Wizard steps, upload zone, platform cards
  _toasts.scss             # Toast notifications + shortcuts modal

dashboard/
  _sidebar.scss            # Fixed sidebar + mobile overlay
  _topbar.scss             # Sticky topbar with search + avatar
  _content.scss            # Main content area
  _stats.scss              # Stat cards with icons
  _tables.scss             # Data tables + match scores + source badges
  _activity.scss           # Activity feed
  _profile.scss            # Profile cards + sections
  _sources.scss            # Source cards + empty states
  _listings.scss           # Listing detail page
  _scan_runs.scss          # Scan run detail
  _applications.scss       # Application detail + steps
  _interventions.scss      # Intervention cards

pages/
  _home.scss               # Landing page specific
  _dashboard.scss          # Dashboard page specific
```

## Icons

All UI icons use [Bootstrap Icons](https://icons.getbootstrap.com/) (`bi-*` classes). The font is loaded via webpack (`bootstrap-icons/font/bootstrap-icons.css`).

```erb
<i class="bi bi-search"></i>        <%# inline icon %>
icon: "bi-search"                    <%# passed to stat_card / empty_state partials %>
```

## Stimulus Controllers

| Controller | Purpose |
|-----------|---------|
| `sidebar` | Toggle sidebar on mobile, swipe-to-close |
| `theme` | Dark mode toggle (localStorage), `bi-moon-fill` / `bi-sun-fill` |
| `toast` | Auto-dismiss flash notifications |
| `shortcuts` | Keyboard shortcuts (g+d, g+l, etc.) + help modal |
| `topbar-search` | Enter key → navigate to /job_listings?q=... |
| `data-table` | Debounced search, per-page, sort header clicks |
| `bulk-select` | Checkbox selection + bulk status update |
| `loading-button` | Disable button + show custom text on form submit |
| `pipeline-board` | Kanban drag-and-drop between pipeline stages |
| `toggle-section` | Show/hide section based on another field's value |
| `confirm-toggle` | Native confirm dialog when enabling a checkbox |
| `dirty-form` | Show "Unsaved changes" badge when form inputs change |
