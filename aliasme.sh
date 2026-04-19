#!/usr/bin/env bash

_list() {

	if [ -s "$HOME/.aliasme/cmd" ];then
		while read -r name
		do
			if ! read -r value; then break; fi
			echo "$name : $value"
		done < "$HOME/.aliasme/cmd"
	fi
}

_add() {
	#read name
	name=$1
	if [ -z "$1" ]; then
		read -rep "Input name to add:" name
	fi

	#read path
	cmd="$2"
	if [ -z "$2" ]; then
		read -rep "Input cmd to add:" cmd
	fi

	echo "$name" >> "$HOME/.aliasme/cmd"
	echo "$cmd" >> "$HOME/.aliasme/cmd"
    echo "add: $name -> $cmd"

	_autocomplete
}

_remove() {
	#read name
	name=$1
	if [ -z "$1" ]; then
		read -pr "Input name to remove:" name
	fi

	# read and replace file
    if [ -s "$HOME/.aliasme/cmd" ];then
        touch "$HOME/.aliasme/cmdtemp"
    	while read -r line
    	do
    		if [ "$line" = "$name" ]; then
    			read -r _ #skip one more line
                echo "remove $name"
    		else
    			echo "$line" >> "$HOME/.aliasme/cmdtemp"
    		fi
    	done < "$HOME/.aliasme/cmd"
    	mv "$HOME/.aliasme/cmdtemp" "$HOME/.aliasme/cmd"
    fi
	_autocomplete
}

_excute() {
    if [ -s "$HOME/.aliasme/cmd" ];then
        while read -u9 -r line; do
            if [ "$1" = "$line" ]; then
                read -u9 -r line
    			eval "$line"
    			return 0
            fi
        done 9< "$HOME/.aliasme/cmd"
    fi
	return 1
}

_bashauto()
{
	local cur opts
	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"

	opts=""
    if [ -s "$HOME/.aliasme/cmd" ];then
    	while read -r line
    	do
    		opts+=" $line"
    		read -r _
    	done < "$HOME/.aliasme/cmd"
    fi
	# shellcheck disable=SC2207
	COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
	return 0
}

_autocomplete()
{
	if [ -n "$ZSH_VERSION" ]; then
		# zsh
		opts=""
        if [ -s "$HOME/.aliasme/cmd" ];then
    		while read -r line
    		do
    			opts+="$line "
    			read -r _
    		done < "$HOME/.aliasme/cmd"
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
			echo "aliasme 3.0.0"
			echo "visit https://github.com/Jintin/aliasme for more information"
		else
			if ! _excute "$1" ; then
				echo "not found"
			fi
		fi
	fi
}
