# 🛡️ Enterprise Homelab — Project SP: From Initial Access to Breached

![Badge](https://img.shields.io/badge/Red%20Team-Attack-red)
![Badge](https://img.shields.io/badge/Evil%20WinRM-red)
![Badge](https://img.shields.io/badge/Hydra-red)
![Badge](https://img.shields.io/badge/Blue%20Team-Detection-blue)
![Badge](https://img.shields.io/badge/Wazuh-SIEM-blue)
![Badge](https://img.shields.io/badge/Active%20Directory-blue)

A hands-on cybersecurity homelab simulating a real enterprise network environment. This project covers building a corporate network from scratch, deploying defensive security tools, and executing a full end-to-end cyber attack simulation — covering both **red team (offensive)** and **blue team (defensive)** perspectives.

![Network Topology](/screenshots/network-topology/project-sp-network-topology.png)

---

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Getting Started](#getting-started)
- [Network Topology](#network-topology)
- [Virtual Machines](#virtual-machines)
- [Tools Used](#tools-used)
- [Attack Chain Summary](#attack-chain-summary)
- [Detection Summary](#detection-summary)
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

## 🚀 Getting Started

To replicate this lab, you'll need a host machine with at least **16 GB RAM** and **~400 GB free disk space**.

### Prerequisites

- [VirtualBox](https://www.virtualbox.org/) or VMware Workstation Pro
- ISO images for: Windows Server 2025, Windows 11 Enterprise, Ubuntu Desktop 22.04, Ubuntu Server 22.04, Kali Linux 2024.4

### Setup Order

1. **Create a NAT Network** (`10.0.0.0/24`) in your hypervisor
2. **Deploy VMs** in this order: Domain Controller → Corporate Server → Security Box → Workstations → Attacker
3. **Configure Active Directory** on `project-sp-dc` — promote to domain controller, configure DNS/DHCP, create user accounts
4. **Install Wazuh** on `project-sp-sec-box` — deploy the Wazuh manager and enroll all other VMs as agents (see [`configs/wazuh-notes.md`](./configs/wazuh-notes.md))
5. **Install MailHog** on `project-sp-corp-svr` to simulate the internal email server
6. **Run the attack simulation** following [`writeups/attack-walkthrough.md`](./writeups/attack-walkthrough.md)

> 💡 The Wazuh agent enrollment script is at [`configs/create_monitors.sh`](./configs/create_monitors.sh).

---

## 🧪 Experimental: Slack + Splunk Integration

> I've also been experimenting with an alternative alerting setup — integrating Splunk with Slack for real-time security notifications. Still playing around with the look and feel of this one.

![Slack + Splunk Integration Preview](/screenshots/slack-splunk-integration/experimental.gif)

*This is a work-in-progress experiment — may or may not make it into the final stack.*

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
| **Custom PowerShell Reverse Shell** | Persistence backdoor after domain compromise |

---

## Attack Chain Summary

The full attack walkthrough is in [`writeups/attack-walkthrough.md`](./writeups/attack-walkthrough.md).

### High-Level Kill Chain

```
[1] Reconnaissance         — nmap host & service discovery
       ↓
[2] Credential Access      — Hydra brute force over SSH (rockyou.txt)
       ↓
[3] Initial Access         — Phishing email → credential harvest → SSH as jane
       ↓
[4] Lateral Movement       — NetExec WinRM spray → Evil-WinRM shell on Windows workstation
       ↓
[5] Privilege Escalation   — Credential reuse → RDP to Domain Controller as Administrator
       ↓
[6] Data Exfiltration      — SCP secrets.txt from DC to attacker machine
       ↓
[7] Domain Persistence     — Rogue Domain Admin account + daily reverse shell scheduled task
```

> 📸 *See `/screenshots/attack-simulation/` for step-by-step evidence.*

---

## Detection Summary

Wazuh monitored the environment throughout the attack. Here's what was detected — and what wasn't.

### ✅ Detected

| Attack Phase | Alert | Rule ID | Severity |
|---|---|---|---|
| Credential Access | Multiple failed SSH login attempts (Hydra) | 18152 | High |
| Lateral Movement | WinRM connection established | 60010 | Medium |
| Lateral Movement | Lateral movement via SMB | 18118 | High |
| Privilege Escalation | New admin account activity | 18104 | Medium |
| Persistence | PowerShell execution detected | 92210 | High |
| Persistence | Scheduled task creation | 61140 | High |
| Exfiltration | SCP file transfer detected | 5710 | Medium |

### ❌ Detection Gaps

| Attack Phase | What Was Missed | Why |
|---|---|---|
| Initial Access (Phishing) | Credential harvest via fake web page | No HTTP content inspection; Wazuh had no visibility into the attacker's Apache log |
| Initial Access (Phishing) | MailHog email delivery to Jane | MailHog generates no syslog output by default; no email gateway alerting configured |
| Lateral Movement | Browser-based file download (reverse.ps1) | HTTP GET from DC browser not captured — no proxy or DNS logging in place |
| Exfiltration | SCP content inspection | Alert fired on the transfer event but file contents were not inspected or flagged |

> **Key insight:** Wazuh fired individual alerts across every major phase, but without SIEM correlation rules chaining brute force → lateral movement → privilege escalation → persistence into a single timeline, each event appeared isolated. An analyst would need to manually connect the dots to recognize a coordinated intrusion.

---

## Skills Demonstrated

- ✅ Virtualization & Homelab Setup (VirtualBox)
- ✅ Active Directory — Users, Groups, Group Policy, DNS, DHCP
- ✅ SIEM Deployment & Log Ingestion (Wazuh)
- ✅ Penetration Testing — Phishing, Brute Force, Post-Exploitation
- ✅ Lateral Movement Techniques
- ✅ Privilege Escalation
- ✅ Threat Detection & Alert Analysis
- ✅ Detection Gap Analysis
- ✅ Linux & Windows Server Administration

---

## What I Learned

Building this lab gave me hands-on experience I couldn't get from reading theory. A few things that genuinely surprised me:

- **Credential reuse was the real kill chain.** I expected to need multiple different attack techniques to move from the corporate server to the Domain Controller. In reality, one password — reused across SSH, WinRM, and RDP — unlocked the entire domain. No exploits needed at any stage.

- **SIEM visibility without correlation is just noise.** Wazuh fired alerts at almost every attack phase, but they appeared as disconnected events: a brute force here, a new user there, a scheduled task somewhere else. Without a correlation rule tying them into a single incident, a tired analyst could easily dismiss each one individually.

- **Phishing bypassed every technical control I'd deployed.** AD, SIEM, network segmentation — none of it mattered once Jane clicked the link. Phishing remains effective not because defenses fail, but because they don't cover the human layer.

- **Detecting what *didn't* fire taught me more than what did.** Identifying the gaps — no HTTP inspection, no email gateway logging, no DNS monitoring — gave me a much clearer picture of where real enterprise blind spots exist than just listing the successful detections.

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
