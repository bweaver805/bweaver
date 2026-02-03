# Ansible Infrastructure Automation

A modular, production‑ready Ansible framework designed for hybrid infrastructure environments.  
This repository reflects real-world automation patterns used across enterprise Linux, identity, storage, and virtualization platforms.

## 🔧 Features
- Modular role-based architecture
- Idempotent playbooks for system provisioning and configuration
- Inventory structure supporting multi‑environment deployments
- Extensible design for hybrid cloud and on‑prem automation
- Example custom modules for advanced workflows

## 📁 Repository Layout
- **inventory/** – Host definitions and group variables  
- **playbooks/** – Reusable automation playbooks  
- **roles/** – Modular roles for system configuration  
- **modules/** – Custom Python modules for advanced tasks  

## 🚀 Example Use
Run a playbook against your inventory:

ansible-playbook -i inventory/hosts.ini playbooks/system_prep.yml
## 🧩 About This Project
Created as part of my ongoing work in infrastructure automation, identity engineering, and hybrid enterprise environments.
This repo highlights my approach to clean, scalable, and maintainable automation using Ansible.
