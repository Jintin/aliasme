#!/usr/bin/env bash

# Storage path
ALIASME_DIR="${ALIASME_DIR:-$HOME/.aliasme}"
ALIASME_CMD="$ALIASME_DIR/cmd"

_list() {
	local name value
	if [ -s "$ALIASME_CMD" ];then
		while IFS= read -r name
		do
			if ! IFS= read -r value; then break; fi
			printf '%s : %s\n' "$name" "$value"
		done < "$ALIASME_CMD"
	fi
}

_find() {
	local name
	if [ -s "$ALIASME_CMD" ];then
		while IFS= read -r name
		do
			if [ "$1" = "$name" ]; then
				return 0
			fi
			if ! IFS= read -r _; then break; fi
		done < "$ALIASME_CMD"
	fi
	return 1
}

_add() {
	# Ensure directory exists
	mkdir -p "$ALIASME_DIR"

	local name cmd
	name=$1
	if [ -z "$1" ]; then
		printf "Input name to add: "
		IFS= read -r name
	fi

	cmd="$2"
	if [ -z "$2" ]; then
		printf "Input cmd to add: "
		IFS= read -r cmd
	fi

	if [ -z "$name" ] || [ -z "$cmd" ]; then
		echo "name and command must not be empty"
		return 1
	fi

	if _find "$name"; then
		printf '%s already exists, remove it first: al rm %s\n' "$name" "$name"
		return 1
	fi

	printf '%s\n%s\n' "$name" "$cmd" >> "$ALIASME_CMD"
	printf 'add: %s -> %s\n' "$name" "$cmd"

	_autocomplete
}

_remove() {
	local name value line found
	name=$1
	if [ -z "$1" ]; then
		printf "Input name to remove: "
		IFS= read -r name
	fi

	found=1
	if [ -s "$ALIASME_CMD" ];then
		: > "$ALIASME_DIR/cmdtemp"
		while IFS= read -r line
		do
			if ! IFS= read -r value; then break; fi
			if [ "$line" = "$name" ]; then
				printf 'remove %s\n' "$name"
				found=0
			else
				printf '%s\n%s\n' "$line" "$value" >> "$ALIASME_DIR/cmdtemp"
			fi
		done < "$ALIASME_CMD"
		mv "$ALIASME_DIR/cmdtemp" "$ALIASME_CMD"
	fi
	if [ "$found" -ne 0 ]; then
		printf 'not found: %s\n' "$name"
	fi
	_autocomplete
	return "$found"
}

_excute() {
	# Prefixed names: the stored command is eval'd in this scope, so plain
	# names like "name" would shadow the user's own variables.
	local _al_name _al_value _al_found
	# zsh aborts on a glob that matches nothing, which would break any stored
	# command containing a literal ? or * (a URL query string, typically).
	if [ -n "$ZSH_VERSION" ]; then
		setopt local_options no_nomatch
	fi
	_al_found=1
	if [ -s "$ALIASME_CMD" ];then
		while IFS= read -u9 -r _al_name; do
			if ! IFS= read -u9 -r _al_value; then break; fi
			if [ "$1" = "$_al_name" ]; then
				_al_found=0
				break
			fi
		done 9< "$ALIASME_CMD"
	fi
	[ "$_al_found" -eq 0 ] || return 1

	# Run with the storage file closed so the command cannot inherit fd 9.
	eval "$_al_value"
}

_bashauto()
{
	local cur opts line
	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"

	opts=""
	if [ -s "$ALIASME_CMD" ];then
		while IFS= read -r line
		do
			opts+=" $line"
			if ! IFS= read -r _; then break; fi
		done < "$ALIASME_CMD"
	fi
	# shellcheck disable=SC2207
	COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
	return 0
}

_autocomplete()
{
	local opts line
	if [ -n "$ZSH_VERSION" ]; then
		# zsh
		opts=""
		if [ -s "$ALIASME_CMD" ];then
			while IFS= read -r line
			do
				opts+="$line "
				if ! IFS= read -r _; then break; fi
			done < "$ALIASME_CMD"
		fi
		# shellcheck disable=SC2154
		compctl -k "($opts)" al
	else
		# bash
		complete -F _bashauto al
	fi
}

_autocomplete

al(){
	if [ -n "$1" ]; then
		if [ "$1" = "ls" ]; then
			_list
		elif [ "$1" = "add" ]; then
			_add "$2" "$3"
		elif [ "$1" = "rm" ]; then
			_remove "$2"
		elif [ "$1" = "-h" ]; then
			echo "Usage:"
			echo "al add [name] [command]      # add alias command with name"
			echo "al rm [name]                 # remove alias by name"
			echo "al ls                        # alias list"
			echo "al [name]                    # execute alias associate with [name]"
			echo "al -v                        # version information"
			echo "al -h                        # help"
		elif [ "$1" = "-v" ]; then
			echo "aliasme 3.1.1"
			echo "visit https://github.com/Jintin/aliasme for more information"
		else
			if _find "$1"; then
				_excute "$1"
			else
				printf 'not found: %s\n' "$1"
				return 1
			fi
		fi
	fi
}
