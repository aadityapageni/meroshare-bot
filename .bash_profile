#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    export MOZ_ENABLE_WAYLAND=1
	export XDG_SESSION_TYPE=wayland
	export WLR_NO_HARDWARE_CURSORS=1
	#export WLR_NO_HARDWARE_CURSORS=0
	export WLR_RENDERER_ALLOW_SOFTWARE=1
fi

