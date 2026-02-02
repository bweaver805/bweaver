FlexPod Automation Framework — Workflow Overview
This document provides a high‑level overview of the orchestration workflows used in the FlexPod Automation Framework. Each workflow is designed to be modular, idempotent, and configuration‑driven, enabling predictable deployments and repeatable lifecycle operations across VMware, Cisco UCS, and NetApp ONTAP.

🧩 Workflow Philosophy
The framework follows three core principles:
1. Modular
Each FlexPod component (VMware, UCS, ONTAP) is automated through isolated modules.
Workflows orchestrate these modules rather than containing logic themselves.
2. Declarative
A config.json file defines the desired state.
Workflows read the configuration and apply it consistently across the stack.
3. Idempotent
Running the same workflow multiple times should not break or duplicate configuration.
Modules check existing state before making changes.

🚀 Primary Workflows
The framework includes two major orchestration workflows:

1. deploy-flexpod.ps1 — Full Stack Deployment
This workflow provisions and configures a complete FlexPod environment from scratch.
Deployment Stages
Stage 1 — Pre‑Flight Validation
- Validate connectivity to vCenter, UCS Manager, and ONTAP
- Validate credentials
- Validate config.json schema
- Confirm required modules are available
Stage 2 — UCS Configuration
- Configure chassis and fabric interconnects
- Create service profile templates
- Deploy service profiles for ESXi hosts
- Apply firmware policies (optional)
Stage 3 — ONTAP Provisioning
- Create SVMs
- Create FlexVols and export policies
- Configure NFS/iSCSI datastores
- Validate network reachability from ESXi hosts
Stage 4 — VMware Configuration
- Add ESXi hosts to vCenter
- Configure vSwitches / distributed switches
- Apply cluster policies (HA, DRS, EVC)
- Create and mount datastores
- Validate storage paths and multipathing
Stage 5 — Post‑Deployment Validation
- Confirm host compliance
- Validate datastore performance
- Confirm UCS service profile health
- Generate deployment report

2. lifecycle-maintenance.ps1 — Ongoing Operations
This workflow handles recurring operational tasks to maintain FlexPod health and consistency.
Lifecycle Stages
Stage 1 — Drift Detection
- Compare current state to config.json
- Identify configuration drift across UCS, VMware, and ONTAP
Stage 2 — Compliance Enforcement
- Reapply cluster policies
- Rebuild missing service profiles
- Correct ONTAP export policies
- Validate datastore mount consistency
Stage 3 — Patch & Update Operations
- Optional: UCS firmware updates
- Optional: ESXi patching
- Optional: ONTAP upgrade checks
Stage 4 — Reporting
- Generate compliance report
- Generate drift summary
- Export results to JSON/CSV

🔄 Workflow Execution Flow
Below is the conceptual flow used by both workflows:
Load config.json
       ↓
Validate environment
       ↓
Load required modules
       ↓
Execute component workflows (UCS → ONTAP → VMware)
       ↓
Validate results
       ↓
Generate report



🧱 Module Interaction Model
Workflows orchestrate modules in this order:
[ UCS Module ] → [ ONTAP Module ] → [ VMware Module ]


This mirrors the physical and logical dependencies of a FlexPod environment.

📄 Configuration‑Driven Logic
All workflows rely on a single configuration file:
config.json


This file defines:
- vCenter hostname
- UCS Manager hostname
- ONTAP cluster
- Default datastore sizes
- Service profile templates
- Network mappings
- Storage provisioning details
Workflows do not contain hardcoded values — everything is driven by configuration.

📊 Reporting
Each workflow generates structured output:
- Deployment summary
- Drift detection report
- Compliance status
- Storage and compute validation results
Reports can be exported in:
- JSON (dashboard‑ready)
- CSV (Excel/PowerBI‑friendly)

🎯 Purpose of This Workflow Design
This workflow model ensures:
- Predictable deployments
- Repeatable lifecycle operations
- Minimal configuration drift
- Clear separation of concerns
- Easy extensibility for new modules or vendors
It reflects real‑world FlexPod engineering practices and aligns with automation‑first operational design.
