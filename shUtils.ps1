Function Show-NicTeamProperties($nicTeamName)
{
    # See also: https://personalnexus.wordpress.com/2018/04/29/the-case-of-multicast-message-loss-again/

    (Get-NetLbfoTeam $nicTeamName).Members | Get-NetAdapterAdvancedProperty | ft DisplayName,DisplayValue,ValidDisplayValues,NumericParameterMaxValue
}


Function Set-UdpExemptPortRange($udpExemptPortRange)
{
    # Example usage with nonconsecutive ranges:
    #
    #     $udpExemptPortRanges = @("1234-2345","6789-7890")
    #     Set-UdpExemptPortRange($udpExemptPortRanges)
    #
    # See also: https://personalnexus.wordpress.com/2017/02/06/the-case-of-multicast-message-loss-on-windows-server-2012-r2/

    New-ItemProperty HKLM:\System\CurrentControlSet\services\Tcpip\Parameters\ -Name UdpExemptPortRange -Value $udpExemptPortRange -PropertyType MultiString -Force
}


Function Sort-GpxFile($inputFileName, $outputFileName)
{
    # See also: https://personalnexus.wordpress.com/2018/09/26/the-case-of-lightroom-placing-all-photos-at-the-end-of-the-track-sorting-a-gpx-file/

    [xml]$xml = Get-Content $inputFileName
    ($points = ($xml.gpx.trk.trkseg.trkpt | Sort-Object -Property time -Descending) ) | Out-Null
    $firstPoint = $points[-1]
    $points | ForEach-Object { $xml.gpx.trk.trkseg.InsertAfter($_, $firstPoint) } | Out-Null
    $xml.Save($outputFileName)
}
