Function Show-NicTeamProperties($NicTeamName)
{
    # See also: https://personalnexus.wordpress.com/2018/04/29/the-case-of-multicast-message-loss-again/

    (Get-NetLbfoTeam $NicTeamName).Members | Foreach-Object {Get-NetAdapter -Name $_ | Get-NetAdapterAdvancedProperty | Format-Table DisplayName,DisplayValue,NumericParameterMaxValue,ValidDisplayValues}
}


Function Set-UdpExemptPortRange($UdpExemptPortRange)
{
    # Example usage with nonconsecutive ranges:
    #
    #     $udpExemptPortRanges = @("1234-2345","6789-7890")
    #     Set-UdpExemptPortRange($udpExemptPortRanges)
    #
    # See also: https://personalnexus.wordpress.com/2017/02/06/the-case-of-multicast-message-loss-on-windows-server-2012-r2/

    New-ItemProperty HKLM:\System\CurrentControlSet\services\Tcpip\Parameters\ -Name UdpExemptPortRange -Value $UdpExemptPortRange -PropertyType MultiString -Force
}


Function Repair-GpxFile($InputFileName, $OutputFileName)
{
    # See also: https://personalnexus.wordpress.com/2018/09/26/the-case-of-lightroom-placing-all-photos-at-the-end-of-the-track-sorting-a-gpx-file/

    [xml]$xml = Get-Content $InputFileName
    ($points = ($xml.gpx.trk.trkseg.trkpt | Sort-Object -Property time -Descending) ) | Out-Null
    $firstPoint = $points[-1]
    $points | ForEach-Object { $xml.gpx.trk.trkseg.InsertAfter($_, $firstPoint) } | Out-Null
    $xml.Save($OutputFileName)
}


Function Convert-SidToUsername($SidString)
{
    # See also: https://personalnexus.wordpress.com/2018/10/06/the-case-of-low-disk-space-because-of-another-users-recycle-bin/

    $sid = New-Object System.Security.Principal.SecurityIdentifier($SidString)
    
    try
    {
       $user = $sid.Translate([System.Security.Principal.NTAccount])
       $result = $user.Value
    }
    catch
    {
        $result = "Unknown user: $SidString"
    }
    return $result
}


Function Convert-UsernameToSid($Domain = "", $Username)
{
    # See also: https://personalnexus.wordpress.com/2018/10/06/the-case-of-low-disk-space-because-of-another-users-recycle-bin/

    if ($Domain)
    {
        $user = New-Object System.Security.Principal.NTAccount($Domain, $Username)
    }
    else
    {
        $user = New-Object System.Security.Principal.NTAccount($Username)
    }

    try
    {
        $sid = $user.Translate([System.Security.Principal.SecurityIdentifier])
        $result = $sid.Value
    }
    catch
    {
        $result = "Unknown user: $Domain\$Username"
    }
    return $result
}


Function Set-WorkStationLockTime($Time = '7PM')
{
    # See also:
    #     https://devblogs.microsoft.com/scripting/use-powershell-to-create-scheduled-tasks/
    #     https://devblogs.microsoft.com/scripting/powertip-use-powershell-to-delete-scheduled-task/

    $scheduledTaskAction = New-ScheduledTaskAction -Execute 'rundll32.exe' -Argument 'user32.dll,LockWorkStation'
    $scheduledTaskTrigger = New-ScheduledTaskTrigger -Daily -At $Time
    $scheduledTaskName = "LockWorkStation$Time"
    
    Get-ScheduledTask $scheduledTaskName -ErrorAction SilentlyContinue| Unregister-ScheduledTask -Confirm:$false

    Register-ScheduledTask -Action $scheduledTaskAction -Trigger $scheduledTaskTrigger -TaskName $scheduledTaskName -Description "Lock the workstation at $Time" | Out-Null
    
    Get-ScheduledTask $scheduledTaskName | Format-List TaskName,Description,State
}

Function Start-PerformanceLog($LogFilePath, 
                              $Counters = $null, 
                              $StartTime = (New-TimeSpan), 
                              $StopTime = (New-TimeSpan -Hours 23 -Minutes 59 -Seconds 59), 
                              $IntervalSeconds = 30)
{
    if ($null -eq $Counters)
    {
        $Counters = @("IDProcess",
                      "Name",
                      "PercentProcessorTime",
                      "PageFaultsPersec",
                      "PrivateBytes",
                      "WorkingSet",
                      "ThreadCount",
                      "HandleCount")
    }
    # Convert certain counters to GB to more easily spot huge memory usage
    if ($Counters.Contains("PrivateBytes"))
    {
        $Counters += @{label="PrivateBytesGB"; expression={$_.PrivateBytes/1GB}}
    }
    if ($Counters.Contains("WorkingSet"))
    {
        $Counters += @{label="WorkingSetGB"; expression={$_.WorkingSet/1GB}}
    }
    $Counters += @{label="Timestamp"; expression={Get-Date}}

    while ((Get-Date).TimeOfDay -lt $StartTime)
    {
        Start-Sleep -Seconds 1
    }

    Write-Host "$(Get-Date) Logging at $LogFilePath from $StartTime to $StopTime..."

    $Iterations = 0
    while ((Get-Date).TimeOfDay -lt $StopTime )
    {
        $Iterations += 1   
        Get-WmiObject Win32_PerfFormattedData_PerfProc_Process | `
            Select-Object $Counters | `
            Export-Csv -Path $LogFilePath -Delimiter ";" -Force -Append -NoTypeInformation
        Start-Sleep -Seconds $IntervalSeconds
    }

    Write-Host "$(Get-Date) Finished logging after $Iterations iterations."
}
