# Microsoft Office 365 Audit Log Retriever
# It's a bit hacky. It scales up and down the interval between queries as necessary.
# That has a performance hit - but hopefully it's a worthwhile cost.

param (
  [DateTime] $start,
  [DateTime] $end,
  [string] $logtype,
  [switch] $help
)
Write-Output "[X] Microsoft Office 365 Audit Log Retriever"
Write-Output "    ========================================"
if($help) {
	Write-Output "[?] -start		To specify start of log collection (defaults to 90 days from today)"
	Write-Output "			Use MM/DD/YYYY HH:MM:SS format"
	Write-Output "[?] -end		To specify end of log collection (defaults to today)"
	Write-Output "			Use MM/DD/YYYY HH:MM:SS format"
	Write-Output ""
	Write-Output "[?] -logtype		To specify Unified, Admin or Mailbox log (defaults to Unified)"
	Write-Output ""
	Write-Output "Example: ./AuditLogRetrieve.ps1 -start '02/30/2020 00:00:01' -end '04/15/2020 23:59:59' -logtype Admin"
	Write-Output ""
	Write-Output "[?] -help		To see this help"
	exit
}
if(!$start) {
	[DateTime]$start = (Get-Date).AddDays(-90)
}
if(!$end) {
	[DateTime]$end = Get-Date
}
if(!$logtype) {
	$logtype = 'Unifieid'
}
#################################### Configuration Section ###################################################
$logFile = $logtype + "_progress.log"
$outputFile = $logtype + "_All.csv"

# Uncomment this if you want the program to prompt you every time
# Otherwise just run these ONCE before you start your investigation

#Install-Module -Name ExchangeOnlineManagement
#Connect-ExchangeOnline

# Manually set the start and end
#[DateTime]$start = '05/16/2020 00:00:00'
#[DateTime]$end = '06/19/2020 23:59:59'
$resultSize = 1000
$defaultintervalMinutes = 60
$retryCount = 3
Write-Output "[***] Retrieving Microsoft 365 $logtype audit logs from $($start) till $($end) [***]"
Write-Output "[?] Outputing to $outputfile"

#################################### End Configuration Section ###################################################

[DateTime]$currentStart = $start
[DateTime]$currentEnd = $start
$currentTries = 0
$intervalMinutes = $defaultintervalMinutes
$originalEnd = $currentEnd

Function Write-Out ([String]$Message)
{
	# Padded this out to merge Logfile output and Screen output to save text
    $final = [DateTime]::Now.ToString() + ":" + $Message
    $final | Out-File $logFile -Append
	Write-Output $Message
}
 
while ($true)
{
    $currentEnd = $currentStart.AddMinutes($intervalMinutes)
    if ($currentEnd -gt $end)
    {
        break
    }
    $currentTries = 0
    $sessionID = [DateTime]::Now.ToString().Replace('/', '_')
    Write-Out "INFO: Retrieving $logtype logs between $($currentStart) and $($currentEnd) [$intervalMinutes mins]"
    $currentCount = 0
    while ($true)
    {
        if($logtype -eq "Unified") {
			[Array]$results = Search-UnifiedAuditLog -StartDate $currentStart -EndDate $currentEnd -SessionId $sessionID -SessionCommand ReturnNextPreviewPage -ResultSize $resultSize
		}
		if($logtype -eq "Admin") {
			[Array]$results = Search-AdminAuditLog -StartDate $currentStart -EndDate $currentEnd -ResultSize $resultSize
		}
		if($logtype -eq "Mailbox") {
			[Array]$results = Search-MailboxAuditLog -StartDate $currentStart -EndDate $currentEnd -ShowDetails -IncludeInactiveMailbox -ResultSize $resultSize
		}
        if ($results -eq $null -or $results.Count -eq 0)
        {
            #Retry if needed. This may be due to a temporary network glitch
            if ($currentTries -lt $retryCount)
            {
                $currentTries = $currentTries + 1
                Start-Sleep -Milliseconds 5
                continue
            }
            else
            {             
				#if ($intervalMinutes -lt 60 -and $results.Count -lt 2500)
				if ($results.Count -lt 2500)
				{
					$intervalMinutes = $intervalMinutes * 2
				}
				Write-Out "WARNING: Empty data set returned between $($currentStart) and $($currentEnd). Retry count reached. Moving forward with interval of $intervalMinutes minutes!"
                break
            }
        }
        $currentTotal = $results[0].ResultCount
        if ($currentTotal -gt 5000)
        {
            Write-Out "WARNING: $($currentTotal) total records match the search criteria."
            $intervalMinutes = $intervalMinutes / 2
            $originalEnd = $currentEnd
            Write-Out "Attempting $currentStart to $currentEnd with smaller batch of $intervalMinutes minutes"
            break
        }
        $currentCount = $currentCount + $results.Count
        Write-Out "INFO: Retrieved $($currentCount) records out of the total $($currentTotal)"
        $results | Export-CSV $outputFile -NoTypeInformation -Append
        if ($currentTotal -eq $results[$results.Count - 1].ResultIndex)
        {
            $message = "INFO: Successfully retrieved $($currentTotal) records for the current time range. Moving on!"
            Write-Out $message
            if ($currentEnd -eq $originalEnd)
            {
                $intervalMinutes = $defaultintervalMinutes
            }
            break
        }
    }
	$currentStart = $currentEnd
}
Remove-PSSession $Session
