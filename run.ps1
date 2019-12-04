#!/bin/pwsh
param(
    [Parameter(Mandatory = $true)]
    [alias("i", "meter-id")]
    [string]
    $meterId
)

$tcpJob = ./bin/rtl-sdr/x64/rtl_tcp.exe &
$meterMsg = ./bin/rtlamr.exe -format=json -msgtype=r900 -filterid="$meterId" --single
$consumption = $meterMsg | jq '.Message.Consumption / 10' 

write-host ""
write-host "Consumption for meter $meterId is $consumption" -foregroundcolor green 

stop-job $tcpJob.Id 
