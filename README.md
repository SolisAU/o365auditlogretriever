# PowerShell Microsoft 365 Log Retrieval Scripts

Repo contains three (3) scripts to collect the various Microsoft 365 audit logs
* Unified Audit Log
* Admin Audit Log
* Mailbox Audit Log

Start by installing the ExchangeOnlineManagement module into an elevated PowerShell command prompt.

`Install-Module -Name ExchangeOnlineManagement`

Next connect to the Microsoft 365 tenancy.

`Connect-ExchangeOnline`

Then run `AdminLogRetrieve.ps1` to retrieve the last 90 days of the Admin Audit Log; `AuditLogRetrieve.ps1` for the last 90 days of the Unified Audit Log; and `MailboxLogRetrieve.ps1` for the last 90 days of the Mailbox Audit Log.

Files will be written to current directory.

## Tweaking Settings

In the header of each file is a section like this:

[DateTime]$start = (Get-Date).AddDays(-90)
#[DateTime]$start = '06/30/2020 22:36:13'
[DateTime]$end = Get-Date
$resultSize = 1000
$intervalMinutes = 720
$retryCount = 3

These values can be used to changed if you need to filter down the window of retrieval, or need to pick out a specific time period. In most cases you shouldn't need to tweak these, however the `intervalMinutes` may need to be adjusted for very large environments. Code is currently set to retrieve up to a maximum of 5,000 records (in 1,000 record batches) in 6 minute increments.
