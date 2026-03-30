// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

// Bootstrap JS — only import components we use
import { Collapse, Dropdown, Alert, Tooltip } from "bootstrap"

// Charts
import "chartkick/chart.js"
