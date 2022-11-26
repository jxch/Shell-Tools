param([String]$vpn, [String]$ip, [String]$mask)

$vpn_ipv4 = (Get-NetIPAddress | Where-Object {$_.InterfaceAlias -eq $vpn}).IPAddress

Write-Host "vpn: $vpn; vpn-ipv4: $vpn_ipv4"
If([String]::IsNullOrEmpty($vpn_ipv4)) {
    Write-Warning "请连接 VPN：$vpn"
} Else {
    Write-Host "route delete $ip" -ForegroundColor DarkGray
    route delete $ip
    Write-Host "route add $ip mask $mask $vpn_ipv4" -ForegroundColor DarkGray
    route add $ip mask $mask $vpn_ipv4

    If([String]::IsNullOrEmpty((route print | Select-String -Pattern "\s0.0.0.0" | Select-String $vpn_ipv4))) {
        Write-Host "操作完成！可使用 route print | select-string $ip 查询路由表是否修改。"
    } Else {
        Write-Host "route delete $ip" -ForegroundColor DarkGray
        route delete $ip
        Write-Warning "请去控制面板关闭 $vpn 网卡的默认网关功能" 
        Write-Warning "参见：ncpa.cpl -> $vpn -> 属性 -> 网络 -> (TCP/IPv4) -> 高级 -> 在远程网络上使用默认网关" 
        Write-Warning "重新连接 $vpn"
    }
}
