# MCP Servers

Model Context Protocol (MCP) servers extend AI coding assistant capabilities by connecting them to external tools and services. The Job Agent App uses 4 MCP servers configured in `.devin/config.json`.

## Installed Servers

### 1. Playwright MCP (Microsoft) — Browser Automation

- **Package:** `@playwright/mcp@latest`
- **GitHub:** https://github.com/microsoft/playwright-mcp (7k+ ⭐)
- **API Keys:** None required
- **Purpose:** Core browser automation for the job agent — navigate job boards, fill search forms, extract listings, take screenshots, and run end-to-end tests.

**Key tools:**
| Tool | Description |
|------|-------------|
| `browser_navigate` | Navigate to a URL |
| `browser_click` | Click elements on a page |
| `browser_type` | Type text into fields |
| `browser_fill_form` | Fill multiple form fields |
| `browser_snapshot` | Capture accessibility snapshot (for element refs) |
| `browser_take_screenshot` | Capture visual screenshot |
| `browser_evaluate` | Run JavaScript on the page |
| `browser_select_option` | Select dropdown options |

### 2. Framelink Figma MCP — Design-to-Code

- **Package:** `figma-developer-mcp`
- **GitHub:** https://github.com/GLips/Figma-Context-MCP (4.4k+ ⭐)
- **API Keys:** `FIGMA_API_KEY` required
- **Purpose:** Read Figma design files and translate them into AI-friendly layout/styling data. Implement the job dashboard UI directly from Figma designs.

**Setup:**
1. Create a Figma personal access token: https://help.figma.com/hc/en-us/articles/8085703771159-Manage-personal-access-tokens
2. Set `FIGMA_API_KEY` in `.devin/config.json` → `mcpServers.figma.env`

**Key tools:**
| Tool | Description |
|------|-------------|
| `get_file` | Fetch and simplify a Figma file's layout data |
| `get_images` | Download images from a Figma file |

**How to use:** Paste a Figma file/frame URL into the chat and ask the agent to implement the design. The server simplifies Figma API responses into AI-friendly format with essential layout, styling, and hierarchy information.

### 3. MCP-Miro — Whiteboard & Planning

- **Package:** `@llmindset/mcp-miro`
- **GitHub:** https://github.com/evalstate/mcp-miro (33+ ⭐)
- **API Keys:** `MIRO_OAUTH_TOKEN` required
- **Purpose:** Create and manipulate Miro whiteboard content — visual brainstorming, architecture diagrams, workflow planning for the job agent pipeline.

**Setup:**
1. Create a Miro app and get an OAuth token: https://developers.miro.com/docs/rest-api-build-your-first-hello-world-app
2. Set `MIRO_OAUTH_TOKEN` in `.devin/config.json` → `mcpServers.miro.env`

**Key tools:**
| Tool | Description |
|------|-------------|
| `create_sticky_note` | Create sticky notes on a board |
| `create_shape` | Create shapes on a board |
| `bulk_create_items` | Create multiple items at once |
| `get_board_items` | Read all items from a board |
| `get_frames` | Get all frames from a board |
| `get_items_in_frame` | Get items within a specific frame |

### 4. MCP-Toolbox (AI-ZeroLab) — Web Search & Utilities

- **Package:** `mcp-toolbox[all]` (via `uvx`)
- **GitHub:** https://github.com/ai-zerolab/mcp-toolbox (9+ ⭐)
- **API Keys:** `TAVILY_API_KEY`, `DUCKDUCKGO_API_KEY` (optional, for web search)
- **Requires:** Python + `uv` (`curl -LsSf https://astral.sh/uv/install.sh | sh`)
- **Purpose:** Web search for supplementing job board scraping, URL-to-markdown conversion for parsing job descriptions, file operations, and memory tools.

**Setup:**
1. Install `uv`: `curl -LsSf https://astral.sh/uv/install.sh | sh`
2. (Optional) Get a Tavily API key: https://tavily.com/
3. Set API keys in `.devin/config.json` → `mcpServers.toolbox.env`

**Key tools:**
| Category | Tools | Description |
|----------|-------|-------------|
| Web Search | `search_with_tavily`, `search_with_duckduckgo` | Search the web for job market data, company info |
| Web Content | `get_html` | Fetch HTML content from URLs |
| Markdown | `convert_url_to_markdown`, `convert_file_to_markdown` | Parse job description pages into clean text |
| File Ops | `read_file_content`, `write_file_content`, `list_directory` | File system operations |
| Memory | `think`, `remember`, `recall` | Persistent memory across conversations |
| Command | `execute_command` | Run shell commands |

## Why These 4 Servers

| Server | Role in Job Agent App |
|--------|----------------------|
| **Playwright** | Core engine — automates job board navigation, search, and data extraction |
| **Figma** | Design implementation — build the job dashboard UI from Figma designs |
| **Miro** | Planning — visually map job search workflows, architecture, and user flows |
| **Toolbox** | Research — web search for company info, markdown parsing for job descriptions |

## Configuration

All MCP servers are configured in `.devin/config.json`. API keys with empty values (`""`) need to be filled in before the server can be used. Playwright works out of the box with no keys.

```json
{
  "mcpServers": {
    "playwright": { ... },
    "figma": { "env": { "FIGMA_API_KEY": "your-key" } },
    "miro": { "env": { "MIRO_OAUTH_TOKEN": "your-token" } },
    "toolbox": { "env": { "TAVILY_API_KEY": "your-key" } }
  }
}
```

## Reference

Based on analysis of [14 MCP Servers for UI/UX Engineers](https://snyk.io/articles/14-mcp-servers-for-ui-ux-engineers/) by Snyk, filtered for relevance to the Job Agent App.
