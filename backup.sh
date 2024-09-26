#!/bin/bash
error=0
unameOut="$(uname -s)"
script_path="$(cd "$(dirname "$0")" && pwd)"
if [ -d "$script_path/sshpass" ];
then
    printg "Removing $script_path/sshpass"
    rm -rf "$script_path/sshpass"
fi
cp "$script_path/SSHRD_Script/$unameOut/sshpass" "$script_path/"
printg() {
  printf "\e[32m$1\e[m\n"
}

printy() {
  printf "\e[33;1m%s\n" "$1"
}

printr() {
  echo -e "\033[1;31m$1\033[0m"
}

if [ -d "$script_path/Activation/" ];
then
    printy " [*] Activation backup already exists!"
    printy "     It is located in $script_path/Activation"
    printy "     It will get deleted if you choose to proceed."
    printy "     Proceed [Y/N] (Y)"
    read wannadelete
    if [ "$wannadelete" == no ] || [ "$wannadelete" == No ] || [ "$wannadelete" == n ] || [ "$wannadelete" == N ];
    then
        exit
    fi
fi

printg " [*] Deleting directory $script_path/Activation"
rm -rf "$script_path/Activation"

printg " [*] Creating directory $script_path/Activation"
mkdir "$script_path/Activation"

printy " [*] Make sure that your device and your computer are connected to the same Wi-Fi network"
printg " [*] Enter your device's IP address"
read devip

printg " [*] Enter your device's Terminal Password"
read termpw

if [ -f "${HOME}/.ssh/known_hosts" ];
then
    printg "[*] Automatically getting hosts file location and copying it to script path"
    if [ ! -d "$script_path/knownhosts" ];
    then
        mkdir "$script_path"/knownhosts
    fi
    cd $script_path && cp "${HOME}/.ssh/known_hosts" "$script_path/knownhosts/"  
fi

sleep 2 

printy " [*] Removing old known_hosts"         
rm -rf ${HOME}/.ssh/known_hosts

printg " [*] Downloading FairPlay folder"
./sshpass -p "$termpw" sftp -o StrictHostKeyChecking=no -r mobile@$devip:/private/var/mobile/Library/FairPlay ./Activation

sidb=$(./sshpass -p "$termpw" ssh -o StrictHostKeyChecking=no mobile@$devip find /private/var/mobile/Library/FairPlay -name "IC-Info.sidb")
sido=$(./sshpass -p "$termpw" ssh -o StrictHostKeyChecking=no mobile@$devip find /private/var/mobile/Library/FairPlay -name "IC-Info.sido")
sidt=$(./sshpass -p "$termpw" ssh -o StrictHostKeyChecking=no mobile@$devip find /private/var/mobile/Library/FairPlay -name "IC-Info.sidt")
sisb=$(./sshpass -p "$termpw" ssh -o StrictHostKeyChecking=no mobile@$devip find /private/var/mobile/Library/FairPlay -name "IC-Info.sisb")

if [ -e "$script_path/Activation/FairPlay/iTunes_Control/iTunes/IC-Info.sidb" ]; then
    printg " [*] IC-Info.sidb downloaded successfully"
elif [[ "$sidb" == *"fairplay"* ]]; then
    printr " [!] IC-Info.sidb failed downloading. Download it manually."
    error=1
fi

if [ -e "$script_path/Activation/FairPlay/iTunes_Control/iTunes/IC-Info.sido" ]; then
    printg " [*] IC-Info.sido downloaded successfully"
elif [[ "$sido" == *"fairplay"* ]]; then
    printr " [!] IC-Info.sido failed downloading. Download it manually."
    error=1
fi

if [ -e "$script_path/Activation/FairPlay/iTunes_Control/iTunes/IC-Info.sidt" ]; then
    printg " [*] IC-Info.sidt downloaded successfully"
elif [[ "$sidt" == *"fairplay"* ]]; then
    printr " [!] IC-Info.sidt failed downloading. Download it manually."
    error=1
fi 

if [ -e "$script_path/Activation/FairPlay/iTunes_Control/iTunes/IC-Info.sisb" ]; then
    printg " [*] IC-Info.sisb downloaded successfully"
elif [[ "$sisb" == *"fairplay"* ]]; then
    printr " [!] IC-Info.sisb failed downloading. Download it manually."
    error=1
fi

if [ -e "$script_path/Activation/FairPlay/iTunes_Control/iTunes/IC-Info.sisv" ]; then
    printg " [*] IC-Info.sisv downloaded successfully"
else 
    printr " [!] IC-Info.sisv failed downloading. Download it manually."
    error=1
fi

printg " [*] Finding data_ark.plist"
data_arkpath=$(./sshpass -p "$termpw" ssh -o StrictHostKeyChecking=no mobile@$devip find /private/var/containers/Data/System -name "data_ark.plist")

printg " [*] Downloading data_ark.plist"
./sshpass -p "$termpw" sftp -o StrictHostKeyChecking=no -r mobile@$devip:$data_arkpath ./Activation

if [ -e "$script_path/Activation/data_ark.plist" ]; then
    printg " [*] data_ark.plist downloaded successfully"
else
    printr " [!] data_ark.plist failed downloading. Download it manually."
    error=1
fi

printg " [*] Downloading com.apple.commcenter.device_specific_nobackup.plist "
./sshpass -p "$termpw" sftp -oPort=2222 mobile@$devip:/private/var/wireless/Library/Preferences/com.apple.commcenter.device_specific_nobackup.plist "$script_path/Activation"

if [ -e "$script_path/Activation/com.apple.commcenter.device_specific_nobackup.plist" ]; then
    printg " [*] com.apple.commcenter.device_specific_nobackup.plist downloaded successfully"
else
    printr " [!] com.apple.commcenter.device_specific_nobackup.plist failed downloading. Download it manually."
    error=1
fi

printg " [*] Finding activation_record.plist"
actrecpath=$(./sshpass -p "$termpw" ssh -o StrictHostKeyChecking=no mobile@$devip find /private/var/containers/Data/System -name "activation_record.plist")

printg " [*] Downloading activation_record.plist"
./sshpass -p "$termpw" sftp -o StrictHostKeyChecking=no -r mobile@$devip:$actrecpath ./Activation

if [ -e "$script_path/Activation/activation_record.plist" ]; then
    printg " [*] activation_record.plist downloaded successfully"
else
    printr " [!] activation_record.plist downloading. Download it manually."
    error=1
fi
if [ "$error" -eq 1 ]; then
    printr "     Backup completed with errors :("
else
    printg "     Backup completed with no errors :)"
fi
exit
