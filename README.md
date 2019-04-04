# aws-analyzer

This script will generate an HTML "powerpoint-like" file.

It will analyze the following resources:
### EC2
- Stopped EC2 instances
- Underused EC2 instances
- Out-of-date EC2 instances
- Number of reserved instances
### EBS Volumes & Snapshots
- Snapshots older than a week
- Unattached volumes
- Offline volumes
### Networking
- Unassociated EIPs
- Number of VPN connections
### S3 Buckets
- Number of buckets and size used
### RDS
- Stopped EC2 instances
- Underused EC2 instances
- Out-of-date EC2 instances
- Number of reserved instances

Then the HTML file provides some advices on what to do to lighten the bill :)

