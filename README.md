# Updater script for MiSTer
The script updates all [MiSTer](https://github.com/MiSTer-devel/Main_MiSTer/wiki) cores, including menu.rbf and the main MiSTer Linux executable; it updates scaler filters, GameBoy palettes and scripts; it can (experimental and risky) optionally update the whole Linux system.<br>
Simply put [update.sh](https://github.com/MiSTer-devel/Updater_script_MiSTer/blob/master/update.sh?raw=true) in your SD and launch it through MiSTer main menu OSD (press F12 and then Scripts). Please right click on the links in this README or on the RAW button in GitHub pages in order to actually download the raw Bash script, otherwise you could download an HTML page which isn’t a script and won’t be executed by MiSTer (you will see no output and just an OK button in MiSTer Script menu interface).<br>
[update.sh](https://github.com/MiSTer-devel/Updater_script_MiSTer/blob/master/update.sh?raw=true) will download from GitHub and execute the latest [mister_updater.sh](https://github.com/MiSTer-devel/Updater_script_MiSTer/blob/master/mister_updater.sh?raw=true) (where the real update code is) from GitHub, so you will never have to deal with "updater updates". You can make an update.ini (same name as the script and placed in the same directory) file with custom user options: see [mister_updater.sh USER OPTIONS section](https://github.com/MiSTer-devel/Updater_script_MiSTer/blob/1aea60d610601f1e5e88472157ac0dd4851a74dc/mister_updater.sh#L41-L90) (please click the link) for all user options and their detailed explanations.<br>
If you feel uncomfortable with a script which downloads and executes another script from the Internet, for security reasons, you can directly download and use mister_updater.sh and it will work the same, all .ini considerations will still be valid, but you will have to update the script manually.
You can have many differently named copies of [update.sh](https://github.com/MiSTer-devel/Updater_script_MiSTer/blob/master/update.sh?raw=true) (or [mister_updater.sh](https://github.com/MiSTer-devel/Updater_script_MiSTer/blob/master/mister_updater.sh?raw=true) if you prefer) and its ini file, for different updating behaviours:<br>
i.e. you can make an *update_arcade.sh* with its *update_arcade.ini* using these settings (simply copy this code in an empty text file named *update_arcade.ini* and put it in the same directory as *update_arcade.sh*):
```
REPOSITORIES_FILTER="arcade-cores"
ADDITIONAL_REPOSITORIES=""
```
or you can make an *update_commodore.sh* with its *update_commodore.ini* using these settings:
```
REPOSITORIES_FILTER="PET2001 VIC20 C64 C16 Minimig"
ADDITIONAL_REPOSITORIES=""
```
or you can make an *update_additional_repositories.sh* with its *update_additional_repositories.ini* using these settings:
```
REPOSITORIES_FILTER="ZZZZZZZZZ"
```
I take no responsibility for any data loss or anything, if your DE10-Nano catches fire it’s up to you: **use the script at your own risk**.
