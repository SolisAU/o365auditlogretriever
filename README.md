# o365auditlogretriever

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
