#!/bin/bash
#
# Bash completion enhances usability with tab-complete commands and arguments.
#

_sli_completions() {
	local cur prev commands chan_cmds fees_cmds tools wallet_cmds 
	local pkg_cmds packages daemons
	COMPREPLY=()  # Array for completion suggestions
	cur="${COMP_WORDS[COMP_CWORD]}"  # Current word being completed
	prev="${COMP_WORDS[COMP_CWORD-1]}"  # Previous word

	# Main SLi commandssli
	commands="init start stop restart show-config edit logs status version node-health sign connect chan fees"
	chan_cmds="open close list"
	fees_cmds="check set adjust bump"
	wallet_cmds="init logs new send list-addresses balance invoice qr-invoice remove-qr pay-invoice"
	tools="macaroon-hex gen-passwords node-backup node-restore node-extract security-check wallet"
	pkgs_cmds="install upgrade list clean-cache remove"
	daemons="albyhub litd lnd loopd poold"

	# Fetch installed and available packages dynamically (if possible)
	packages="albyhub lit loop pool lndconnect"  # Static list; could parse $PKGS_LIST

	# Top-level command completion
	if [ "$COMP_CWORD" -eq 1 ]; then
		COMPREPLY=($(compgen -W "$commands $tools $pkgs_cmds" -- "$cur"))
	# Second-level completion based on first argument
	elif [ "$COMP_CWORD" -eq 2 ]; then
		case "$prev" in
			init)
				COMPREPLY=($(compgen -W "wallet lit" -- "$cur")) ;;
			start|stop|restart|logs|status)
				COMPREPLY=($(compgen -W "$daemons" -- "$cur")) ;;
			show-config|edit)
				COMPREPLY=($(compgen -W "albyhub lit lnd sli" -- "$cur")) ;;
			chan)
				COMPREPLY=($(compgen -W "$chan_cmds" -- "$cur")) ;;
			fees)
				COMPREPLY=($(compgen -W "$fees_cmds" -- "$cur")) ;;
			wa|wallet)
				COMPREPLY=($(compgen -W "$wallet_cmds" -- "$cur")) ;;
			install|remove)
				COMPREPLY=($(compgen -W "$packages" -- "$cur")) ;;
			macaroon-hex)
				COMPREPLY=($(compgen -W "admin readonly invoice" -- "$cur")) ;;
		esac
	fi
	return 0
}

# Register the completion function for 'sli'
complete -F _sli_completions sli
