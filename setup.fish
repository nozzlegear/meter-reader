#! /usr/bin/env fish

set userName (whoami)

if test "$userName" != "root" 
    echo ""
    set_color yellow
    echo "Setup script requires root access."
    exit 1
end

echo "Installing rtl-sdr tools..."

apt install rtl-sdr -y

set rtlamrUrl "https://github.com/bemasher/rtlamr/releases/download/v0.9.1/rtlamr_linux_amd64.tar.gz"
set rtlamrZip "rtlamr.tar.gz"

echo "Installing rtlamr executable from $rtlamrUrl"

wget $rtlamrUrl -O $rtlamrZip
mkdir -p "bin"
tar xvzf $rtlamrZip -C "bin"
chmod +x bin/rtlamr
mv bin/rtlamr /usr/bin/rtlamr
rm $rtlamrZip
rm -r bin 

echo "Installed rtlamr at /usr/bin/rtlamr"
echo "Blacklisting drivers for Linux"

bash -c ./blacklist-linux-driver.sh

set_color yellow
echo ""
echo "NOTE: You must unplug the USB meter reader and plug it back in for the driver to take effect. Once you've unplugged the reader and plugged it back in, you can run rtl_test to test that setup was successful. If you do not see error messages, it was successful."
set_color green
echo ""
echo "Finished!"
echo ""
