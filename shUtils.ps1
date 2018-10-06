Function Show-NicTeamProperties($NicTeamName)
{
    # See also: https://personalnexus.wordpress.com/2018/04/29/the-case-of-multicast-message-loss-again/

    (Get-NetLbfoTeam $NicTeamName).Members | Get-NetAdapterAdvancedProperty | ft DisplayName,DisplayValue,ValidDisplayValues,NumericParameterMaxValue
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


Function Sort-GpxFile($InputFileName, $OutputFileName)
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
