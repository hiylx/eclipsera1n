# Activate device downgraded on ios 16 / 17 sep
# Disclamer
If you break your device its your responsibility but you can just fix it by restoring it. 
I am not responsible for data loss if you bork something up.

You can use palen1x if palera1n does not work properly.


# Prerequisites
palera1n and filezilla should be installed on your mac or linux system
Your device should currently be activated on iOS 16 or above
You should probably read this entire guide before trying this and also read every word carefully

- Step 1. Your device should be compatible with palera1n if not then you can't follow this guide :(
- Step 2. Remove all jailbreaks from your device
- Step 3. Connect your device to your system with a lightning cable and enter DFU mode
- Step 4. Run <code>palera1n -cf</code> if you are on mac and <code>sudo palera1n -cf</code> if you are on linux and wait for your device to finish creating fakefs and enter recovery mode
- Step 5. Once your device has entered recovery mode, run <code>palera1n -f</code> if you are on mac and <code>sudo palera1n -f</code> if you are on linux
- Step 6. Open palera1n loader and install sileo. It will ask you for a root password, do NOT forget this.

# Credits
- [Orangera1n](https://github.com/Orangera1n/) - Guide about activating futurerestored idevices on iOS 15
- [Nathan](https://github.com/verygenericname/SSHRD_Script) - SSHRD script
- [Edwin](https://github.com/edwin170) - Guided me through this script and helped me fix few things in it
- [Sasa](https://github.com/sasa8810) - Idea and few parts of code using only sshrd
- [kjutzn](https://github.com/kjutzn/) - Gave this code
