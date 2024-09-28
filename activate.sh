#!/bin/bash

skip_rdboot=false
unameOut="$(uname -s)"
while [ "$#" -gt 0 ]; do
  case "$1" in
    --skip-rdboot)
      skip_rdboot=true
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
  shift
done

script_path="$(cd "$(dirname "$0")" && pwd)"

printg() {
  printf "\e[32m$1\e[m\n"
}

printy() {
  printf "\e[33;1m%s\n" "$1"
}

printr() {
  echo -e "\033[1;31m$1\033[0m"
}


if [ -d "$script_path/knownhosts" ]; then
    cd $script_path
else
    cd $script_path && mkdir knownhosts
fi

if [ -f "${HOME}/.ssh/known_hosts" ]; then
    printg "[*] Automatically getting hosts file location and copying it to script path"

    cd $script_path && cp "${HOME}/.ssh/known_hosts" "$script_path/"

    cd $script_path && cp "$script_path/known_hosts" "$script_path/knownhosts/"  

    

    rm -rf ${HOME}/.ssh/known_hosts
fi

chmod +x "$script_path"/SSHRD_Script/Darwin/sshpass
rm -rf ${HOME}/.ssh/known_hosts

if [ "$skip_rdboot" = true ]; then
    printg "[*] User has chosen to skip sshrd boot, make sure to boot sshrd on your device and run mount_filesystems"
else
    printg "[?] What version is your iDevice on?"
    read ios1
    printg
fi

if [ ! -f "$script_path/sshpass" ]; then
    cp "$script_path/SSHRD_Script/$unameOut/sshpass" "$script_path/"
    printg "[*] Copying sshpass to script path (Will be needed for later)"
else
    cd $script_path
fi

if [ ! -f "$script_path/iproxy" ]; then
    cp "$script_path/SSHRD_Script/$unameOut/iproxy" "$script_path/"
    printg "[*] Copying iproxy to script path (Will be needed for later)"

else
    cd $script_path
fi

printg "[*] Creating Ramdisk, make sure that your iDevice is in DFU mode"


if [ "$skip_rdboot" = true ]; then
    printg "[*] Skipped booting ramdisk as specified"
else
    printg "[*] Creating Ramdisk"
    cd "$script_path/SSHRD_Script" && chmod +x sshrd.sh && ./sshrd.sh "$ios1"
    printg "[*] Booting ramdisk"
    cd "$script_path/SSHRD_Script" && ./sshrd.sh boot
fi

printg "[*] You might have to press allow for opening new terminal window"

if [ "$skip_rdboot" = true ]; then
    printg "[*] Terminal window with ssh should already be opened if you are on mac"
else
  
  case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    sleep 5 && osascript -e "tell application \"Terminal\" to do script \"cd $script_path/SSHRD_Script && ./sshrd.sh ssh\"";;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    MSYS_NT*)   machine=Git;;
    *)          machine="UNKNOWN:${unameOut}"
   esac
  
fi

printr "[!] Do not close it, and make sure that ssh is successfully connected! And if you are using Linux you should open a new terminal and manually run the command below"
printg  "sudo su root -c 'cd $script_path/SSHRD_Script && ./sshrd.sh ssh'"
printg "[*] Press enter when everything is ready. "
read rdbready

cd $script_path			
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mount_filesystems

printg "[*] Deleting previous activation files (If this errors it is okay)"

./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 rm -rf /mnt2/mobile/Library/FairPlay/
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 rm -rf /mnt2/mobile/Media/Downloads/1
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 rm -rf /mnt2/mobile/Media/1

printg "[*] Making directory /mnt2/mobile/Media/Downloads/1"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mkdir -p /mnt2/mobile/Media/Downloads/1/Activation
printg "[*] Making directory /mnt2/mobile/Media/1"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mkdir -p /mnt2/mobile/Media/1
printg "[*] Pushing Activation files to /mnt2/mobile/Media/Downloads/1"
./sshpass -p alpine scp -rP 2222 -o StrictHostKeyChecking=no $script_path/Activation root@localhost:/mnt2/mobile/Media/Downloads/1
sleep 1

printg "[*] Moving activation files to /mnt2/mobile/Media/1"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mv -f /mnt2/mobile/Media/Downloads/1 /mnt2/mobile/Media

chown_path="/usr/sbin/chown"

printg "[*] Fixing permisions of activation folder"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 "$chown_path" -R mobile:mobile /mnt2/mobile/Media/1
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chmod -R 755 /mnt2/mobile/Media/1

printg "[*] Fixing permissions of all activation files"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chmod 644 /mnt2/mobile/Media/1/Activation/activation_record.plist 
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chmod 644 /mnt2/mobile/Media/1/Activation/data_ark.plist 
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chmod 644 /mnt2/mobile/Media/1/Activation/com.apple.commcenter.device_specific_nobackup.plist 


printg "[*] Moving Fairplay folder to /mnt2/mobile/Library/FairPlay"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mv -f /mnt2/mobile/Media/1/Activation/FairPlay /mnt2/mobile/Library/FairPlay 
printg "[*] Reparing FairPlay permissions"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chmod 755 /mnt2/mobile/Library/FairPlay

printg "[*] Finding internal folder"
ACT1=$(./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 find /mnt2/containers/Data/System -name internal) 
ACT2=$(./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 find /mnt2/containers/Data/System -name activation_records) 


ACT2=${ACT1%?????????????????}

ACT3=$ACT2/Library/internal/data_ark.plist

printg "[*] Setting permissions of data_ark.plist"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chflags nouchg $ACT3 

printg "[*] Replacing data_ark.plist"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mv -f /mnt2/mobile/Media/1/Activation/data_ark.plist $ACT3 
printg "[*] Repairing permissions"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chmod 755 $ACT3 
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chflags uchg $ACT3

ACT4=$ACT2/Library/activation_records 

printg "[*] Making directory activation_records"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 rm -rf $ACT4 
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mkdir $ACT4 

printg "[*] Copying activation_record.plist to activation_records folder"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mv -f /mnt2/mobile/Media/1/Activation/activation_record.plist $ACT4/activation_record.plist 

printg "[*] Reparing permissions"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chmod 755 $ACT4/activation_record.plist 
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chflags uchg $ACT4/activation_record.plist 

printg "[*] Replacing com.apple.commcenter.device_specific_nobackup.plist"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chflags nouchg /mnt2/wireless/Library/Preferences/com.apple.commcenter.device_specific_nobackup.plist
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 mv -f /mnt2/mobile/Media/1/Activation/com.apple.commcenter.device_specific_nobackup.plist /mnt2/wireless/Library/Preferences/com.apple.commcenter.device_specific_nobackup.plist 


printg "[*] Repairing permissions"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 $chown_path root:mobile /mnt2/wireless/Library/Preferences/com.apple.commcenter.device_specific_nobackup.plist

./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chmod 755 /mnt2/wireless/Library/Preferences/com.apple.commcenter.device_specific_nobackup.plist 

./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 chflags uchg /mnt2/wireless/Library/Preferences/com.apple.commcenter.device_specific_nobackup.plist


printg "[*] Rebooting"
./sshpass -p alpine ssh -o StrictHostKeyChecking=no root@localhost -p 2222 /sbin/reboot


printg "[*] Script done, your device should be reboot and you can go through setup like normal"
printg "[*] Your device will work like normal but for you can only use trollstore for side loading. If you want to install it you can check out the trollstore guide"

if [ -f $script_path/knownhosts/known_hosts ]
printg " [*] Restoring known_hosts file"
cd $script_path/knownhosts && cp "$script_path/knownhosts/known_hosts" "${HOME}/.ssh/known_hosts"
fi



printg "[*] All done! Enjoy iOS 15."

exit 1
