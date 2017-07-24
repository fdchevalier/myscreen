# myscreen

Make it easier to reattach a screen session by either automatically reattaching the only active session or, if several active sessions, by reattaching a session designated by its number.

## Prerequisites

Obviously the GNU screen program is required for this script to work. A GNU screen package should be present in the repository of your distribution (e.g. `sudo apt-get install screen` on any Debian-like). If you are not allowed to install packages, ask your system administrator to install it.

## What are the scripts for?

Here are some details on the two scripts available:

* `myscreen.sh` (mandatory): this script lists the active screen sessions. If only one is present, it reattaches it automatically. If several sessions are found, they are listed with a corresponding number and the script prompts the user to enter the number of the session to reattach. If nothing is entered, the script exits. Three options are also available:
  * `-s`: when this option is followed by the session number (if known), the session is reattached without listing all the other sessions,
  * `-r`: to switch from reattaching to renaming a session (require `sty-updater.sh` to work properly),
  * `-h`: the help message printing the command usage and the options available.

* `sty-updater.sh` (optional): this script is required for the option `-r` of `myscreen.sh`  to work properly. The purpose of this script is to update the value of STY variable within each screen's windows after the screen session has been renamed (and therefore the corresponding socket). This script has to be run in each window of the renamed session. Otherwise no new window will be created within the session due to unexisting socket.

## Installing

To download the lastest version of the scritps:
```
git clone https://github.com/fdchevalier/myscreen
```

For convenience, the scripts should be accessible system wide by either including the folder in your `$PATH` or by moving the scripts in a folder present in your path (e.g. `$HOME/local/bin/`).

## License

This project is licensed under the [GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html).

