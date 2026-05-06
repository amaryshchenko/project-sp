#!/bin/bash

BASE_URL="https://localhost:9200"
AUTH="admin:admin"

create_monitor() {
  local name=$1
  local severity=$2
  local query=$3

  curl -k -u "$AUTH" -X POST "$BASE_URL/_plugins/_alerting/monitors" \
    -H "Content-Type: application/json" \
    -d "{
      \"type\": \"monitor\",
      \"name\": \"$name\",
      \"enabled\": true,
      \"schedule\": {
        \"period\": {
          \"interval\": 1,
          \"unit\": \"MINUTES\"
        }
      },
      \"inputs\": [{
        \"search\": {
          \"indices\": [\"wazuh-alerts-*\"],
          \"query\": {
            \"size\": 0,
            \"query\": $query,
            \"aggregations\": {
              \"alert_count\": {
                \"value_count\": {
                  \"field\": \"_id\"
                }
              }
            }
          }
        }
      }],
      \"triggers\": [{
        \"name\": \"$name trigger\",
        \"severity\": \"$severity\",
        \"condition\": {
          \"script\": {
            \"source\": \"ctx.results[0].aggregations.alert_count.value > 0\",
            \"lang\": \"painless\"
          }
        },
        \"actions\": []
      }]
    }"
  echo ""
  echo "Created: $name"
}

# 1. Multiple Failed SSH/WinRM Login Attempts
# Matches Wazuh group authentication_failures, within last 1 minute
create_monitor \
  "Multiple Failed SSH-WinRM Login Attempts" "1" \
  '{
    "bool": {
      "filter": [
        {"terms": {"rule.groups": ["authentication_failures", "authentication_failed"]}},
        {"range": {"@timestamp": {"gte": "now-1m"}}}
      ]
    }
  }'

# 2. PowerShell Execution Detected
# Matches Windows PowerShell event channel logs (Event ID 4103/4104)
create_monitor \
  "PowerShell Execution Detected" "1" \
  '{
    "bool": {
      "filter": [
        {"range": {"@timestamp": {"gte": "now-1m"}}}
      ],
      "should": [
        {"match_phrase": {"data.win.system.channel": "Microsoft-Windows-PowerShell/Operational"}},
        {"match_phrase": {"data.win.system.channel": "PowerShellCore/Operational"}},
        {"terms": {"rule.groups": ["windows_powershell", "powershell"]}}
      ],
      "minimum_should_match": 1
    }
  }'

# 3. WinRM Connection Established
# WinRM uses Windows Event ID 6 (WSMan) or network logon type 3 via winrm process
create_monitor \
  "WinRM Connection Established" "2" \
  '{
    "bool": {
      "filter": [
        {"range": {"@timestamp": {"gte": "now-1m"}}}
      ],
      "should": [
        {"match_phrase": {"data.win.system.channel": "Microsoft-Windows-WinRM/Operational"}},
        {"match_phrase": {"data.win.eventdata.processName": "wsmprovhost.exe"}},
        {"match_phrase": {"data.win.eventdata.parentImage": "wsmprovhost.exe"}}
      ],
      "minimum_should_match": 1
    }
  }'

# 4. New Admin Account Activity
# Windows Event ID 4720 (account created) or 4732 (added to admin group)
create_monitor \
  "New Admin Account Activity" "2" \
  '{
    "bool": {
      "filter": [
        {"range": {"@timestamp": {"gte": "now-1m"}}}
      ],
      "should": [
        {"term": {"data.win.system.eventID": "4720"}},
        {"term": {"data.win.system.eventID": "4732"}},
        {"term": {"data.win.system.eventID": "4728"}},
        {"terms": {"rule.groups": ["account_changed", "adduser"]}}
      ],
      "minimum_should_match": 1
    }
  }'

# 5. Lateral Movement via SMB
# Windows Event ID 4648 (explicit credential use) or Sysmon network connections to port 445
create_monitor \
  "Lateral Movement via SMB" "1" \
  '{
    "bool": {
      "filter": [
        {"range": {"@timestamp": {"gte": "now-1m"}}}
      ],
      "should": [
        {"term": {"data.win.system.eventID": "4648"}},
        {"term": {"data.win.eventdata.destinationPort": "445"}},
        {"terms": {"rule.groups": ["smbd", "samba"]}},
        {"match_phrase": {"data.win.eventdata.shareName": "IPC$"}}
      ],
      "minimum_should_match": 1
    }
  }'

# 6. Scheduled Task Creation
# Windows Event ID 4698 (task created) or Sysmon process create for schtasks.exe
create_monitor \
  "Scheduled Task Creation" "1" \
  '{
    "bool": {
      "filter": [
        {"range": {"@timestamp": {"gte": "now-1m"}}}
      ],
      "should": [
        {"term": {"data.win.system.eventID": "4698"}},
        {"match_phrase": {"data.win.eventdata.image": "schtasks.exe"}},
        {"match_phrase": {"data.win.eventdata.commandLine": "schtasks"}}
      ],
      "minimum_should_match": 1
    }
  }'

# 7. SCP File Transfer Detected
# SSH subsystem scp — matches sshd logs containing "scp" in command or subsystem
create_monitor \
  "SCP File Transfer Detected" "2" \
  '{
    "bool": {
      "filter": [
        {"terms": {"rule.groups": ["syslog", "sshd"]}},
        {"range": {"@timestamp": {"gte": "now-1m"}}}
      ],
      "should": [
        {"match_phrase": {"full_log": "subsystem request for sftp"}},
        {"match_phrase": {"full_log": "scp"}},
        {"match_phrase": {"data.srcuser": "scp"}}
      ],
      "minimum_should_match": 1
    }
  }'

echo ""
echo "All 7 monitors created!"