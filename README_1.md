# Screenshots

This folder contains evidence screenshots from the homelab project.

## Folder Structure

| Folder | What to put here |
|---|---|
| `network-topology/` | VM overview, VirtualBox/VMware network config, IP assignments |
| `ad-setup/` | Active Directory Users & Computers, GPO editor, DNS manager |
| `wazuh-dashboard/` | Wazuh alert dashboard, agent list, specific alert details |
| `attack-simulation/` | Phishing page, reverse shell connecting, Hydra output, Evil-WinRM session, NetExec output |

## Screenshot Tips

- Use descriptive filenames: `wazuh-powershell-alert.png` not `screenshot1.png`
- Capture the whole window including the hostname/IP so it's clear which machine you're on
- For attack steps, number them: `01-phishing-page.png`, `02-credentials-captured.png`, etc.

## Suggested Screenshots to Take

### Network Topology
- [ ] VirtualBox/VMware network settings showing `project-x-nat`
- [ ] All VMs running simultaneously in the hypervisor

### Active Directory
- [ ] AD Users and Computers showing users and OUs
- [ ] DNS Manager showing domain zones
- [ ] Group Policy Management console

### Wazuh Dashboard
- [ ] Main security events dashboard
- [ ] Agent list showing all connected hosts
- [ ] High-severity alert detail (e.g., brute force or PowerShell alert)

### Attack Simulation
- [ ] Phishing website in browser
- [ ] Credentials captured on attacker machine
- [ ] Reverse shell connecting back (`nc` listener receiving connection)
- [ ] Hydra brute force output
- [ ] Evil-WinRM session on target
- [ ] NetExec showing successful auth across machines
- [ ] RDP session via XFreeRDP
