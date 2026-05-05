Attack Chain Summary
The full attack walkthrough is in writeups/attack-walkthrough.md.

High-Level Kill Chain
[1] Reconnaissance
       ↓
[2] Phishing — Credential Harvesting Website
       ↓
[3] Initial Access — PowerShell Reverse Shell
       ↓
[4] Credential Dumping / Brute Force (Hydra)
       ↓
[5] Lateral Movement (NetExec, Evil-WinRM)
       ↓
[6] Privilege Escalation
       ↓
[7] Domain Compromise
📸 See /screenshots/attack-simulation/ for step-by-step evidence.

Remake this all process, add images where neeeded based on projectsecurity docs

Remake Wazuh