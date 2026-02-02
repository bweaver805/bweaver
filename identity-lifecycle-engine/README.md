# Identity Lifecycle Engine

An automation engine for onboarding, offboarding, group management, and access workflows across Okta and Active Directory. Designed for clean, auditable, and repeatable identity operations in hybrid enterprise environments.

---

## 🚀 Features

- Automated user provisioning and deprovisioning  
- Okta group synchronization and mapping logic  
- Access review reporting  
- Modular PowerShell functions for identity workflows  
- JSON‑driven configuration for predictable lifecycle logic  
- Clean, auditable logs for compliance and security teams  

---

## 📁 Repository Structure

### `/functions`
Core identity automation functions:

- `New-UserAccount.ps1` — Creates AD + Okta accounts  
- `Disable-UserAccount.ps1` — Secure offboarding workflow  
- `Sync-OktaGroups.ps1` — Group mapping + entitlement logic  
- `Generate-AccessReport.ps1` — Compliance and audit reporting  

### `/workflows`
High‑level lifecycle processes:

- `onboarding.ps1` — Full new‑hire workflow  
- `offboarding.ps1` — Termination workflow with safety checks  
- `access-review.ps1` — Quarterly/annual access review automation  

### `/docs`
Architecture and logic documentation:

- Identity architecture overview  
- Lifecycle logic and decision trees  
- Group mapping and entitlement models  

---

## 🧩 Example Usage

```powershell
.\onboarding.ps1 -UserCSV newhires.csv
.\offboarding.ps1 -Username jdoe
.\access-review.ps1 -OutputPath review.json
