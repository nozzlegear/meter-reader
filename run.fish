#! /usr/bin/env fish

set scriptName (status -f)
# Read the meter id from shell input (./run.fish "meter-id")
# set meterId $argv[1]
# Or just hardcode it into the script
set meterId "1850027356"

if test -z "$meterId"
    echo ""
    echo "Usage: $scriptName [meter id]"
    exit 1
end

# Run rtl_tcp in the background, redirecting its output to /dev/null
rtl_tcp > /dev/null 2>&1 &
set rtlTcpPid (jobs -lp)

# Wait for the job to start
sleep 2

function readMeter 
    rtlamr -format=json -msgtype=r900 -filterid="$meterId" --single | jq '.Message.Consumption / 10'
end 

# Run rtlamr and read the meter
set -l consumption (readMeter); or exit 1

# Stop the last job (rtl_tcp)
# https://stackoverflow.com/a/30384101
if jobs -q
    echo "Killing rtl_tcp job $rtlTcpPid"
    # No matter which kill signal I try (e.g. default, or -3 to simulate ctrl+c), rtl_tcp refuses to quit when killed via this script. 
    # The only way to kill it is to send -9, which makes the kernel forcefully kill the process instead.
    kill -9 $rtlTcpPid
end

echo ""
set_color green
echo "Consumption for meter $meterId is $consumption." # -foregroundcolor green 

