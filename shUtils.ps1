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
