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

if test -z "$WATER_METER_SQL_PASSWORD"
    echo ""
    echo "Must set WATER_METER_SQL_PASSWORD environment variable."
    exit 1
end

echo ""

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
echo "["(date --iso-8601) (date +"%T %Z")"]"
echo "Consumption for meter $meterId is $consumption." 
echo "Posting consumption to SQL container." 

if test -t 1
    set useTty "-it"
else
    set useTty "-i"
end

docker exec $useTty meter-reader_sql_1 /opt/mssql-tools/bin/sqlcmd -b -V16 -S localhost -U SA -P "$WATER_METER_SQL_PASSWORD" -Q "insert into WaterMeterUsage (Date, Usage) VALUES (getdate(), $consumption)"

echo "Posted consumption to SQL container." 
echo "Done."
set_color normal
