Identity Lifecycle Logic
This document outlines the decision logic, branching workflows, and operational rules that drive the Identity Lifecycle Engine. The goal is to ensure predictable, auditable, and automation‑friendly identity operations across Okta and Active Directory.
The lifecycle engine is built around three core workflows:
- Onboarding
- Offboarding
- Access Review
Each workflow follows a consistent pattern:
validate → decide → execute → log → verify.

🧩 1. Onboarding Logic
The onboarding workflow provisions new users across AD, Okta, and downstream systems based on HR attributes and entitlement rules.
1.1 Input Sources
- HR feed (CSV, API, or ticket)
- config.json (role → group mappings)
- Secure credential store
1.2 Decision Flow
Start
  ↓
Validate HR record
  ↓
Check for existing AD account
  ├─ Yes → Convert to rehire logic
  └─ No → Create new AD account
  ↓
Check for existing Okta account
  ├─ Yes → Link to AD / update attributes
  └─ No → Create Okta user
  ↓
Assign base entitlements
  ↓
Determine role-based access
  ↓
Apply group mappings
  ↓
Enable MFA + security policies
  ↓
Generate onboarding log
  ↓
End


1.3 Key Rules
- Rehire logic prevents duplicate accounts
- Role determines entitlements, not department alone
- Group mappings are declarative, defined in group-mapping.md
- All actions logged for audit and compliance

🧩 2. Offboarding Logic
The offboarding workflow ensures secure, complete, and compliant removal of access for terminated users.
2.1 Trigger Sources
- HR termination feed
- Manager request
- Security event
2.2 Decision Flow
Start
  ↓
Validate user exists in AD/Okta
  ↓
Check for active sessions
  ↓
Disable Okta user
  ↓
Revoke MFA + tokens
  ↓
Disable AD account
  ↓
Move AD account to quarantine OU
  ↓
Remove group memberships
  ↓
Export access snapshot (for audit)
  ↓
Schedule mailbox retention / archive
  ↓
Generate offboarding log
  ↓
End


2.3 Key Rules
- Disable first, delete never (audit + legal retention)
- Group removal is idempotent
- Mailbox retention follows config policy
- Access snapshot stored for compliance

🧩 3. Access Review Logic
The access review workflow generates entitlement reports for managers, auditors, or compliance teams.
3.1 Review Types
- Quarterly access review
- Annual SOX review
- Manager‑initiated review
- Privileged access review
3.2 Decision Flow
Start
  ↓
Load user list (scope depends on review type)
  ↓
Pull AD group memberships
  ↓
Pull Okta app assignments
  ↓
Apply entitlement classification rules
  ↓
Flag high‑risk access
  ↓
Generate review package (JSON/CSV)
  ↓
Log review metadata
  ↓
End


3.3 Key Rules
- Privileged access flagged automatically
- Group → entitlement mapping defined in config
- Output normalized for dashboards
- Review packages stored for audit

🔐 4. Security & Compliance Logic
The lifecycle engine enforces several security controls:
4.1 Idempotency
Running the same workflow twice must not:
- Create duplicate accounts
- Reassign groups unnecessarily
- Break existing entitlements
4.2 Logging
Every workflow logs:
- Inputs
- Decisions
- Actions taken
- Errors
- Final state
4.3 Least Privilege
Group mappings enforce:
- Role‑based access
- No direct assignment of privileged groups
- Separation of duties
4.4 Retention
- Logs retained per compliance policy
- Access snapshots stored for audit

🧱 5. Configuration‑Driven Logic
All lifecycle decisions are driven by:
config.json
- Default OU paths
- Base entitlements
- Role → group mappings
- Security policies
- Retention settings
group-mapping.md
- Declarative entitlement model
- Role‑based access rules
- Privileged access definitions
This ensures the engine is predictable, maintainable, and auditable.

🎯 Purpose of This Logic Model
This lifecycle logic ensures:
- Clean, consistent onboarding
- Secure, complete offboarding
- Auditable access reviews
- Minimal manual intervention
- Reduced identity drift
- Compliance with enterprise security standards
It reflects real‑world identity engineering practices and aligns with automation‑first operational design.
