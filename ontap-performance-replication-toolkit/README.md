# ONTAP Performance & Replication Toolkit

A modular toolkit for analyzing NetApp ONTAP performance, validating SnapMirror replication health, and generating storage insights across multi‑site environments.

## 🚀 Features
- Performance metric collection (latency, IOPS, throughput)
- SnapMirror health validation and lag analysis
- Automated storage reporting (CSV, JSON)
- VMware‑integrated datastore checks
- Modular PowerShell functions for reuse in larger frameworks

## 📁 Repository Structure
- `/scripts` — PowerShell modules and functions  
- `/docs` — Architecture notes and workflow diagrams  
- `/examples` — Sample output and reports  

## 🧩 Example Usage
```powershell
.\Get-OntapPerformance.ps1 -Cluster "prod-cluster"
.\Test-SnapMirrorHealth.ps1 -Source svm1 -Destination svm2
