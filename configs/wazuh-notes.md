# Wazuh SIEM — Setup Notes

## Overview

Wazuh was deployed on `project-x-sec-box` (Ubuntu 22.04) as the central SIEM for the homelab.  
All domain-joined and standalone machines had Wazuh agents installed to forward logs.

---

## Deployment

Wazuh was installed using the official all-in-one installer:

```bash
curl -sO https://packages.wazuh.com/4.7/wazuh-install.sh
sudo bash ./wazuh-install.sh -a
```

This installs:
- Wazuh Manager
- Wazuh Indexer (Elasticsearch-based)
- Wazuh Dashboard (Kibana-based)

Dashboard accessible at: `https://10.0.0.10`

---

## Agent Installation

### Windows Agent (win-client, DC)

Run on the target Windows machine (PowerShell as Administrator):

```powershell
Invoke-WebRequest -Uri https://packages.wazuh.com/4.x/windows/wazuh-agent-4.7.0-1.msi -OutFile wazuh-agent.msi
msiexec.exe /i wazuh-agent.msi /q WAZUH_MANAGER="10.0.0.10"
NET START WazuhSvc
```

### Linux Agent (linux-client, corp-svr)

```bash
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | apt-key add -
echo "deb https://packages.wazuh.com/4.x/apt/ stable main" | tee /etc/apt/sources.list.d/wazuh.list
apt-get update && apt-get install wazuh-agent
WAZUH_MANAGER="10.0.0.10" systemctl start wazuh-agent
```

---

## Key Configurations

### Enable PowerShell Logging (Windows GPO)

To detect PowerShell execution via Wazuh, PowerShell script block logging must be enabled on Windows machines via Group Policy:

```
Computer Configuration > Administrative Templates > Windows Components
> Windows PowerShell > Turn on PowerShell Script Block Logging = Enabled
```

### Log Sources Ingested

| Source | Type | Notes |
|---|---|---|
| Windows Event Logs | Security (4624, 4625, 4648, 4720) | Login attempts, account changes |
| Sysmon | Process creation, network | Requires Sysmon install |
| PowerShell logs | Script block logging | Requires GPO config above |
| Linux auth logs | `/var/log/auth.log` | SSH brute force detection |
| Active Directory | Security events | Forwarded from DC |

---

## Notable Alert Rules

| Rule ID | Description | Severity |
|---|---|---|
| 18152 | Multiple Windows login failures | High |
| 92210 | PowerShell suspicious command | High |
| 5710 | SSH brute force attempt | High |
| 18104 | New user added to local admin group | Medium |
| 60010 | WinRM connection | Medium |

---

*Reference: https://documentation.wazuh.com*
