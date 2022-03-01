# Start Outlook and then immediately quit it, to work around the issue of
# Application.Startup not runing the first time Outlook is started.
# Afterwards, when the user starts Outlook normally, Application.Startup will
# work as expected.
# See also: https://social.msdn.microsoft.com/Forums/en-US/6dc295a7-1f37-41f3-86b9-ae8344c8a670/outlook-vba-applicationstartup-event-feuert-nicht-beim-ersten-start?forum=officede

$outlook = New-Object -ComObject "Outlook.Application"
$outlook.Quit()
$outlook = $null