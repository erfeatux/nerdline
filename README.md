# nerdline
A simple powerline style prompt generator for Bash, written 100% in pure Bash.
![screenshot](screenshot.avif)

## ✨ Features

nerdline provides a customizable prompt with multiple **segments**, inspired by powerline.  
All segments are implemented in **pure Bash** — no external dependencies required.  

### Supported segments:
- 🌀 **git** — branch name, files changed counter  
- 📜 **hist** — displays history writing state (_for built-in `histoff` command_) 
- 🖥 **hostname** — current hostname  
- ⚙️ **jobs** — background jobs counter  
- 📂 **pwd** — current working directory  
- 🐍 **python** — current venv or conda notifier  
- 🟥 **retcode** — last command exit code  
- 👤 **user** — current username

### Supported modules:
Modules extend the functionality of nerdline.
- 🔑 **ssh** — when connecting to a remote host via SSH, nerdline automatically deploys itself to that host and starts
- 🔒 **sudo** — when running `sudo su`, nerdline is automatically launched for the elevated session  

## 📦 Installation

Clone the repository:
```bash
git clone https://github.com/erfeatux/nerdline.git ~/.local/share/nerdline
```
Add to `~/.bash.rc`
```
if [[ -z $__nerdline_pfx ]]
then
  ~/.local/share/nerdline/nerdline.sh test && source ~/.local/share/nerdline/nerdline.sh
fi
```
After install to run immediately
```bash
~/.local/share/nerdline/nerdline.sh test && source ~/.local/share/nerdline/nerdline.sh
```
## 🔧 Configuration

⚠️ **Note:** to properly display the special symbols from the default config, your terminal must use a font from [Nerd Fonts](https://www.nerdfonts.com/).

The configuration file can be placed in one of the following locations (checked in order):

- `/etc/nerdline.cfg`  
- `$XDG_CONFIG_HOME/nerdline.cfg`  
- `~/.config/nerdline.cfg`  

This file allows you to override default settings, customize segments, modules, colors, and symbols.

Example:
```ini
[nerdline]
segments=user hostname python hist git pwd jobs retcode
modules=ssh sudo
separator=' '
separator_same_bg='░ '

[user]
color_fg=238:238:238
color_bg=1:1:1
color_root=#ff0000
color_user=#00f
sign_root='󰐣 '
sign_sudo='󰀅 '
sign_user='󰀄 '

[hostname]
color_bg=9:9:9
color_fg=0:255:0
color_sign=153:153:153
color_sign_ssh=0:255:0
# show ip on remote host
showip=false
# show hostname on localhost
showlocal=false
sign=' '
sign_ssh='󱫋 '

[python]
color_bg=9:9:9
color_fg=0:255:0
color_sign=0:255:0
color_sign_conda=0:255:0
sign='󰌠 '
sign_conda='󱔎 '

[hist]
color_bg=9:9:9
color_fg=170:0:0
sign=󱙄

[git]
color_add=0:255:0
color_bg=9:9:9
color_fg=0:255:0
color_ignore=136:136:136
color_mod=255:170:0
color_rm=255:0:0
color_rn=0:0:255
color_sign=0:255:0
sign_add=

[pwd]
color_bg=9:9:9
color_fg=153:153:153
color_sign=238:238:238
home_sign=

[jobs]
color_bg=34:34:34
color_running=0:255:0
color_stopped=255:0:0
sign_running=󱑠
sign_stopped=󱤳

[retcode]
color_bg=34:34:34
color_err=170:0:0
color_fg=0:170:0
sign_err=󱎘
sign_ok=󰸞
```
