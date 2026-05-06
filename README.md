# 🛡️ Enterprise Homelab — Project SP: From Initial Access to Breached

![Badge](https://img.shields.io/badge/Evil-WinRM-red)
![Badge](https://img.shields.io/badge/Hydra-red)
![Badge](https://img.shields.io/badge/Red%20Team-Attack-red)
![Badge](https://img.shields.io/badge/Blue%20Team-Detection-blue)
![Badge](https://img.shields.io/badge/Wazuh-SIEM-blue)
![Badge](https://img.shields.io/badge/Active%20Directory-blue)

A hands-on cybersecurity homelab simulating a real enterprise network environment. This project covers building a corporate network from scratch, deploying defensive security tools, and executing a full end-to-end cyber attack simulation — covering both **red team (offensive)** and **blue team (defensive)** perspectives.

---

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Network Topology](#network-topology)
- [Virtual Machines](#virtual-machines)
- [Tools Used](#tools-used)
- [Attack Chain Summary](#attack-chain-summary)
- [Skills Demonstrated](#skills-demonstrated)
- [What I Learned](#what-i-learned)
- [Screenshots](#screenshots)
- [Repository Structure](#repository-structure)

---

## Project Overview

This homelab simulates a small enterprise environment consisting of workstations, servers, a domain controller, a security monitoring stack, and a dedicated attacker machine. The goal was to:

1. Build a realistic corporate network using virtualization
2. Deploy enterprise-grade defensive tools (SIEM, IDS)
3. Execute a cyber attack from initial access to full compromise
4. Detect and analyze the attack using the security stack

---

## Network Topology

**Network:** `10.0.0.0/24` (NAT Network via VirtualBox / VMware)

| Hostname | IP Address | Role |
|---|---|---|
| `project-sp-dc` | `10.0.0.5` | Domain Controller (AD, DNS, DHCP, SSO) |
| `project-sp-corp-svr` | `10.0.0.8` | Corporate Server |
| `project-sp-sec-box` | `10.0.0.10` | Security Server (Wazuh SIEM) |
| `project-sp-win-client` | `10.0.0.100` | Windows Workstation (victim) |
| `project-sp-linux-client` | `10.0.0.101` | Linux Desktop Workstation (victim) |
| `project-sp-attacker` | `10.0.0.9` | Attacker Machine (Kali Linux) |

![Network Topology](/screenshots/network-topology/project-sp-network-topology.png)

---

## Virtual Machines

| VM | Operating System | CPU | RAM | Storage |
|---|---|---|---|---|
| project-sp-dc | Windows Server 2025 | 2 vCPU | 4 GB | 50 GB |
| project-sp-win-client | Windows 11 Enterprise | 2 vCPU | 4 GB | 80 GB |
| project-sp-linux-client | Ubuntu Desktop 22.04 | 1 vCPU | 2 GB | 80 GB |
| project-sp-sec-box | Ubuntu Desktop 22.04 | 2 vCPU | 4 GB | 80 GB |
| project-sp-corp-svr | Ubuntu Server 22.04 | 1 vCPU | 2 GB | 25 GB |
| project-sp-attacker | Kali Linux 2024.4 | 1 vCPU | 2 GB | 55 GB |

**Hypervisors supported:** VirtualBox · VMware Workstation Pro

![VMs](/screenshots/network-topology/ALL_VMs.png)

---

## Tools Used

### 🔵 Defense / Enterprise

| Tool | Purpose |
|---|---|
| **Microsoft Active Directory** | User/resource management, SSO, Group Policy |
| **Wazuh** | Open-source SIEM — log ingestion, intrusion detection, alerting |
| **MailHog** | Fake SMTP server for email simulation |

### 🔴 Offense

| Tool | Purpose |
|---|---|
| **Hydra** | Password brute-force / dictionary attacks |
| **Evil-WinRM** | Post-exploitation via Windows Remote Management |
| **NetExec** | Remote command execution and lateral movement |
| **XFreeRDP** | RDP access to Windows targets |
| **SecLists** | Wordlists for usernames, passwords, and payloads |
| **Custom PowerShell Reverse Shell** | Initial access after phishing |

---

## Attack Chain Summary

The full attack walkthrough is in [`writeups/attack-walkthrough.md`](./writeups/attack-walkthrough.md).

### High-Level Kill Chain

```
[1] Reconnaissance
       ↓
[2] Credential Access (Brute Force)
       ↓
[3] Initial Access (Phishing)
       ↓
[4] Lateral Movement (Linux to Windows)
       ↓
[5] Privilege Escalation (Credential Reuse)
       ↓
[6] Data Exfiltration (SCP)
       ↓
[7] Domain Persistence (Rogue Admin & Scheduled Task)
```

> 📸 *See `/screenshots/attack-simulation/` for step-by-step evidence.*

---

## Skills Demonstrated

- ✅ Virtualization & Homelab Setup (VirtualBox)
- ✅ Active Directory — Users, Groups, Group Policy, DNS, DHCP
- ✅ SIEM Deployment & Log Ingestion (Wazuh)
- ✅ Penetration Testing — Phishing, Brute Force, Post-Exploitation
- ✅ Lateral Movement Techniques
- ✅ Privilege Escalation
- ✅ Threat Detection & Alert Analysis
- ✅ Linux & Windows Server Administration

---

## What I Learned

Building this lab from the ground up gave me hands-on experience with how enterprise environments are structured and where they are most vulnerable. Some key takeaways:

- **Active Directory is a prime target** — misconfigured GPOs and weak passwords can lead to full domain compromise
- **SIEM visibility is critical** — without log ingestion and alerting, most of the attack would have gone undetected
- **Defense and offense are two sides of the same coin** — understanding how attackers move laterally made me a better defender
- **Phishing is still effective initial access vector** — technical controls alone aren't enough without user awareness

---

## Repository Structure

```
project-sp/
├── configs/
│   ├── create_monitors.sh
│   └── wazuh-notes.md             
│
├── screenshots/
│   ├── ad-setup/
│   ├── attack-simulation/
│   ├── network-topology/
│   ├── wazuh-dashboard/
│   └── phishing/
│
├── scripts/
│   ├── phishing-simulation/
│   │   ├── index.html
│   │   └── process.php
│   └── reverse-shell/
│       └── reverse.ps1
│
├── writeups/
│   └── attack-walkthrough.md
│
├── README.md
```

---
## Screenshots

| Folder | Contents |
|---|---|
| `screenshots/network-topology/` | Network layout and VM overview |
| `screenshots/ad-setup/` | Active Directory configuration |
| `screenshots/wazuh-dashboard/` | SIEM alerts and dashboards |
| `screenshots/attack-simulation/` | Step-by-step attack evidence |

> 🔒 All credentials shown in screenshots are from an isolated lab environment.

---
