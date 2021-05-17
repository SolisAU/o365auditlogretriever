# PowerShell Microsoft 365 Log Retrieval Scripts

Repo contains ~three (3)~ one script ~s~ to collect the various Microsoft 365 audit logs
* Unified Audit Log
* Admin Audit Log
* Mailbox Audit Log

Start by installing the ExchangeOnlineManagement module into an elevated PowerShell command prompt.

`Install-Module -Name ExchangeOnlineManagement`

Next connect to the Microsoft 365 tenancy.

`Connect-ExchangeOnline`

~Then run `AdminLogRetrieve.ps1` to retrieve the last 90 days of the Admin Audit Log; `AuditLogRetrieve.ps1` for the last 90 days of the Unified Audit Log; and `MailboxLogRetrieve.ps1` for the last 90 days of the Mailbox Audit Log.~

Then run `AuditLogRetrieve.ps1` for the last 90 days of the Unified Audit Log; or add `-start`, `-date` and/or `-logtype` to be more specific. `-help` to get help.

Files will be written to current directory.

## Tweaking Settings

No longer valid. Run with `-help` for more information.

Script will scale up and scale down (double or half, appropriately) the interval between the searches to ensure the results being returned are less than 5,000 records to avoid losing data.
