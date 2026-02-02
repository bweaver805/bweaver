# FlexPod Automation Framework

A modular automation framework for provisioning, configuring, and maintaining FlexPod environments across VMware, Cisco UCS, and NetApp ONTAP. Designed for repeatability, lifecycle consistency, and clean operational workflows.

---

## 🚀 Features

- Automated VMware cluster configuration  
- ONTAP provisioning (SVMs, FlexVols, exports)  
- Cisco UCS service profile and chassis automation  
- End‑to‑end FlexPod deployment workflows  
- Modular design for reuse across environments  
- JSON‑driven configuration for predictable deployments  

---

## 📁 Repository Structure

### `/modules`
Reusable automation modules for each FlexPod component:

- **VMware** — host config, cluster policies, datastore prep  
- **ONTAP** — SVM creation, FlexVol provisioning, export policies  
- **UCS** — service profiles, chassis configuration, firmware prep  

### `/workflows`
High‑level orchestration scripts:

- `deploy-flexpod.ps1` — full stack deployment  
- `lifecycle-maintenance.ps1` — patching, compliance, drift correction  

### `/docs`
Architecture diagrams, workflow explanations, and module design notes.

---

## 🧩 Example Usage

```powershell
.\deploy-flexpod.ps1 -ConfigFile config.json
