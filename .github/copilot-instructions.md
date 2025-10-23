<!-- Auto-generated guidance for AI coding agents working in this repository -->
# Copilot instructions for azuredeployment

This repository contains ARM templates, Bicep-like modular JSON templates, PowerShell automation scripts and deployment helpers for spinning up VM-based labs and automation in Azure. Keep guidance concise and specific to the project's conventions.

Key facts (quick):
- Primary workloads: JSON ARM templates under `deploymentTemplatesGen2/` and `vmDeploymentBastion/` (top-level template files: `serverMain.json`, `desktopMain.json`).
- Reusable module files live in `deploymentTemplatesGen2/modules/` and follow a parameter->variable->resources->outputs structure (e.g., `networkInterface.json`, `virtualNetwork.json`).
- Automation scripts live under `automation/PowerShell-*` (both 5.1 and 7.x style). They assume Az PowerShell modules and Az CLI context.
- Repo README at `/README.md` contains deploy-to-portal links and high-level usage.

What an AI agent should do first:
- Read `deploymentTemplatesGen2/serverMain.json` and one or two module files (for example `modules/networkInterface.json`) to understand parameter naming, tagging conventions and artifact linking via `_artifactsLocation` + `_moduleRepo` variables.
- Open `automation/PowerShell-7.2/resourceGroupCleanupV6.ps1` (or similarly named cleanup/startup scripts) to understand how automation expects tags like `Cleanup` and `CreatedBy` to be set on resources.

Project-specific conventions to preserve when editing:
- Template versioning: templates use `contentVersion` and `templateLink` referencing `https://raw.githubusercontent.com/balticapprenticeships/azuredeployment/main/...`. When adding modules, mirror this pattern and update `contentVersion` only when changing resource shapes.
- Tagging: resources are consistently tagged with keys such as `DisplayName`, `ResourceType`, `Dept`, `CreatedBy`, `CourseDate`, `Cleanup`. Preserve or extend these tags rather than replacing them.
- Naming: VM-related resources use `vmNamePrefix` produced from `concat(parameters('vmName'), parameters('deliveringCoachInitials'))` and copyIndex-based suffixes. Keep that naming pattern for any new resources to integrate with existing outputs and automation.
- Parameter-driven modules: modules expect callers to pass parameters rather than reading global variables. Follow the existing parameter names (`location`, `vmName`, `vmCount`, `deliveringCoachInitials`, `createdBy`, etc.) where possible to maximize reusability.

Build / test / debugging workflows (discoverable):
- There is no compiled build step: ARM templates are validated using Azure tools. Use `az deployment group validate --resource-group <rg> --template-file <file>` or `New-AzResourceGroupDeployment -ResourceGroupName <rg> -TemplateFile <file> -WhatIf` for local validation.
- PowerShell scripts assume Az modules. Run locally with PowerShell 7.2 where available. Example: run `resourceGroupCleanupV6.ps1` in a test subscription after `Connect-AzAccount`.
- Function apps (automation) are referenced under `automation/FunctionApps` but may not be present—search before editing. The workspace has a VS Code task `func: host start` configured for `automation/FunctionApps/DailyDeleteVms` — if testing functions locally, use that task.

Integration points & external dependencies:
- External artifact hosting: templates reference raw GitHub URIs via `_artifactsLocation` — keep relative paths consistent when adding modules so portal deployment links continue to work.
- KeyVault usage: templates compute `vaultName` and `vaultResourceGroup` dynamically; do not hardcode KeyVault names in new code.
- Automation scripts rely on specific tags (see Tagging section). Adding or renaming tags may break automated cleanup and start/stop scripts.

Examples to cite in PRs / code changes:
- Parameter/variable pattern: `deploymentTemplatesGen2/serverMain.json` uses `_artifactsLocation` and `_moduleRepo` to compose `templateLink.uri` for nested deployments — match this when adding nested modules.
- Outputs shaped for automation: modules export arrays using `copy` in outputs (see `modules/networkInterface.json` outputs `networkInterfaceId` and `privateIP`) — keep output shapes compatible if modifying.

When modifying templates or scripts:
- Small changes: run an ARM template validation and, when changing tags/names, run the relevant PowerShell automation script locally in `-WhatIf` or a test subscription to verify behavior.
- Major changes (resource renames, tag removals, output shape changes): add a short note in `README.md` and update `deploymentTemplatesGen2/changelog.md` describing compatibility impact.

What not to change without human review:
- Tag keys (`Cleanup`, `CreatedBy`, `CourseDate`) and resource name conventions derived from `vmNamePrefix`.
- `_artifactsLocation` URIs and `contentVersion` linkage when editing modules consumed by top-level templates without adjusting templateLink references.

If uncertain, ask the maintainer or open a draft PR. Maintainer context: repo owner `balticapprenticeships` — link to top-level README for deploy examples.

End of instructions. Ask the user what sections need more detail or which files they'd like cited inline.
