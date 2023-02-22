<#----------------------------------
    .SYNOPSIS  
        Send email on event log scripting  
    .NOTES 
        Runs in conjunction with task scheduler, if event 101 or 203 from Microsoft-Windows-TaskScheduler/Operational
is captured in event log, this email fires. Logging enabled in $Log variable
    .AUTHOR
		
.LOGIC
        If event $EventId captured, send email and log event in $log variable
 .FUNCTIONS

.VERSION
        1.1
----------------------------------#>


$EventId = 101,203
#events filtered to alert on

$A = Get-WinEvent -MaxEvents 1  -FilterHashTable @{Logname = "Microsoft-Windows-TaskScheduler/Operational" ; ID = $EventId}
#location of events to watch

$Message = $A.Message
$EventID = $A.Id
$MachineName = $A.MachineName
$Source = $A.ProviderName
$Log = "\\CIFS_share000001\failed tasks email log\ScheduledTask-Failure.log"
#Logging historical information of failed events

#Email parameters below
$Sender = "Sender@email.com"
$Recipient = "Recipient@email.com"
$Subject ="Alert From $MachineName $(get-timestamp)"
$Body = "MachineName: $MachineName `n`nTime: $(get-timestamp) `n`nMessage: $Message"

#email sending parameters
$SMTPServer = "Office365.mail.protection.outlook.com"

#email generation
$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 25)
$SMTPClient.Send($Sender, $Recipient, $Subject, $Body)

#Functions - get timestamp to capture time and date in format, append to log file
function get-timestamp {
    return "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (get-Date)
}
write-output "Task failure - email sent at: $(get-timestamp)" | Out-file $Log -append
