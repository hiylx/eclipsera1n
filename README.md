# Activate device downgraded on ios 16 / 17 sep
# Disclamer
This script is for educational purposes. I am aware people might use this to bypass iCloud, but I am NOT encouraging you to bypass iCloud and you **shouldn't do that**. This guide is **legitimately** activating it!
ALSO: This script is for advanced users, i am not responsible if your device becomes broken (idk how but just in case) or if your known_hosts get reseted. **If you have important saved hosts in known_hosts file save them manually (script already saves it but this is just in case).**

You can use palen1x if palera1n does not work properly.


# Prerequisites
palera1n and filezilla should be installed on your mac or linux system
Your device should currently be activated on iOS 16 or above

- Step 1. Your device should be compatible with palera1n if not then you can't follow this guide :(
- Step 2. Remove all jailbreaks from your device
- Step 3. Connect your device to your system with a lightning cable and enter DFU mode
- Step 4. Run <code>palera1n -cf</code> if you are on mac and <code>sudo palera1n -cf</code> if you are on linux and wait for your device to finish creating fakefs and enter recovery mode
- Step 5. Once your device has entered recovery mode, run <code>palera1n -f</code> if you are on mac and <code>sudo palera1n -f</code>
- Step 6. Open palera1n loader and install sileo. It will ask you for a root password, do NOT forget this.

# Credits
- [Orangera1n](https://github.com/Orangera1n/) - Guide about activating futurerestored idevices on iOS 15
- [Nathan](https://github.com/verygenericname/SSHRD_Script) - SSHRD script
- [Edwin](https://github.com/edwin170) - Guided me through this script and helped me fix few things in it
- [Sasa](https://github.com/sasa8810) - Idea and few parts of code using only sshrd
- [kjutzn](https://github.com/kjutzn/) - Gave this code
