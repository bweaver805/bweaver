Incident Response Checklist
Operational guide for Office 365 security events
This checklist outlines the steps required to investigate, contain, and remediate security incidents within an Office 365 environment. It is designed for administrators, security analysts, and on‑call responders who need a clear, repeatable workflow.

1. Initial Detection
Trigger Sources
- Microsoft 365 Defender alerts
- Azure AD Identity Protection (risky sign‑ins, risky users)
- Security & Compliance Center alerts
- User‑reported suspicious activity
- SIEM or SOC notifications
Immediate Actions
- Validate the alert severity and scope
- Confirm whether the activity is ongoing
- Document the initial timestamp, alert ID, and affected accounts

2. Containment
Account‑Level Containment
- Block sign‑in for affected accounts
- Revoke active sessions
- Reset passwords (if applicable)
- Require MFA re‑registration
Tenant‑Level Containment
- Disable suspicious inbox rules
- Block malicious IPs or locations via Conditional Access
- Suspend compromised applications or OAuth grants

3. Investigation
Identity & Access
- Review sign‑in logs for unusual patterns
- Check risky user and risky sign‑in reports
- Validate MFA status and recent changes
Mailbox & Communication
- Search for malicious inbox rules
- Review sent items for unauthorized messages
- Check message trace for suspicious activity
Data Access
- Review SharePoint/OneDrive file access logs
- Identify unusual downloads, sharing, or permission changes
Device & Endpoint
- Validate device compliance status
- Check for new or unknown device enrollments

4. Remediation
Identity
- Reset credentials
- Re‑enforce MFA
- Remove unauthorized roles or group memberships
Mailbox
- Remove malicious inbox rules
- Restore mailbox items if compromised
- Convert mailbox to shared (if user is being disabled)
Licensing & Access
- Remove unnecessary licenses
- Disable unused applications
- Revoke OAuth tokens and app permissions
Data
- Restore files from version history or backup
- Remove unauthorized sharing links
- Reapply correct permissions

5. Recovery & Validation
Post‑Remediation Checks
- Confirm sign‑in activity returns to baseline
- Validate no new risky sign‑ins
- Ensure mailbox rules remain clean
- Confirm Conditional Access policies are enforced
- Validate device compliance and enrollment integrity
User Communication
- Notify affected users
- Provide guidance on phishing awareness
- Reinforce MFA and password hygiene

6. Documentation & Reporting
Required Documentation
- Incident summary
- Timeline of events
- Affected accounts and systems
- Actions taken (containment, remediation, recovery)
- Root cause analysis (if determinable)
- Recommendations for prevention
Reporting Targets
- Security leadership
- Compliance/audit teams
- IT management
- External partners (if required by policy)

7. Prevention & Hardening
Identity
- Strengthen Conditional Access
- Enforce MFA for all users
- Review privileged roles regularly
Email & Collaboration
- Enable anti‑phish and anti‑spam baselines
- Implement DLP policies
- Enforce safe links and safe attachments
Device & Endpoint
- Strengthen Intune compliance policies
- Require device encryption
- Enforce app protection policies
Monitoring
- Expand alert coverage
- Integrate logs into SIEM
- Schedule regular access reviews
