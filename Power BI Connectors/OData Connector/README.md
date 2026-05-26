# HDP OData Connector for Power BI

This repository contains the source code for the HDP Power BI connector and explains how to build the connector from source. For more detailed information on installing and using the connector, see the [official product documentation](https://docs.progress.com/bundle/datadirect-hybrid-data-pipeline/page/Custom-connector-for-Power-BI.html)

## Quick Start

**Prerequisites:** Windows machine with PowerShell 5.1 or later. No other tools required — the build script downloads everything it needs on first run.

```powershell
.\build.ps1                        # Debug build
.\build.ps1 -Configuration Release # Release build
```

Output: `HdpOAuthConnect\bin\<Configuration>\HdpOAuthConnect.mez`

The Power Query SDK tools are downloaded and cached in `.packages/` on first run.

### Building in VS Code

The [Power Query SDK extension](https://marketplace.visualstudio.com/items?itemName=PowerQuery.vscode-powerquery-sdk) (`PowerQuery.vscode-powerquery-sdk`) integrates with VS Code's build system.

1. Open the `HdpOAuthConnect/` folder as the workspace root in VS Code
2. Install the Power Query SDK extension
3. Run **Terminal → Run Build Task** (`Ctrl+Shift+B`) and select **build: Debug** or **build: Release**

