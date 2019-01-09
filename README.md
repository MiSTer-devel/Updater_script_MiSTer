# Updater script for MiSTer
The script updates all [MiSTer](https://github.com/MiSTer-devel/Main_MiSTer/wiki) cores, including menu.rbf and the main MiSTer Linux executable; it updates scaler filters, GameBoy palettes and scripts; it can (experimental and risky) optionally update the whole Linux system. Simply put [update.sh](https://github.com/MiSTer-devel/Updater_script_MiSTer/blob/master/update.sh?raw=true) (please right click for saving the link) in your SD and launch it through MiSTer main menu OSD (press F12 and then Scripts).<br>
It will always use the latest [mister_updater.sh](https://github.com/MiSTer-devel/Updater_script_MiSTer/blob/master/mister_updater.sh) (where the real update code is) form GitHub, so you will never have to deal with "updater updates". You can make an update.ini (same name as the script and placed in the same directory) file with custom user options: see [mister_updater.sh](https://github.com/MiSTer-devel/Updater_script_MiSTer/blob/master/mister_updater.sh) for user options and their explanations.<br>
You can have many differently named copies of [update.sh](https://github.com/MiSTer-devel/Updater_script_MiSTer/blob/master/update.sh?raw=true) and its ini file, for different updating behaviours:<br>
i.e. you can make an *update_arcade.sh* with its *update_arcade.ini* using these settings
```
REPOSITORIES_FILTER="arcade-cores"
ADDITIONAL_REPOSITORIES=""
```
or you can make an *update_commodore.sh* with its *update_commodore.ini* using these settings
```
REPOSITORIES_FILTER="PET2001 VIC20 C64 C16 Minimig"
ADDITIONAL_REPOSITORIES=""
```
or you can make an *update_additional_repositories.sh* with its *update_additional_repositories.ini* using these settings
```
REPOSITORIES_FILTER="ZZZZZZZZZ"
```
I take no responsibility for any data loss or anything, if your DE10-Nano catches fire it’s up to you: **use the script at your own risk**.
