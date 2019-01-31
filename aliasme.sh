#!/usr/bin/env bash

_list() {

	if [ -s ~/.aliasme/cmd ];then
		while read name
		do
			read value
			echo "$name : $value"
		done < ~/.aliasme/cmd
	fi
}

_add() {
	#read name
	name=$1
	if [ -z $1 ]; then
		read -ep "Input name to add:" name
	fi

	#read path
	cmd="$2"
	if [ -z "$2" ]; then
		read -ep "Input cmd to add:" cmd
	fi

	echo $name >> ~/.aliasme/cmd
	echo $cmd >> ~/.aliasme/cmd
    echo "add: $name -> $cmd"

	_autocomplete
}

_remove() {
	#read name
	name=$1
	if [ -z $1 ]; then
		read -pr "Input name to remove:" name
	fi

	# read and replace file
    if [ -s ~/.aliasme/cmd ];then
        touch ~/.aliasme/cmdtemp
    	while read line
    	do
    		if [ "$line" = "$name" ]; then
    			read line #skip one more line
                echo "remove $name"
    		else
    			echo $line >> ~/.aliasme/cmdtemp
    		fi
    	done < ~/.aliasme/cmd
    	mv ~/.aliasme/cmdtemp ~/.aliasme/cmd
    fi
	_autocomplete
}

_excute() {
    if [ -s ~/.aliasme/cmd ];then
        while read line; do
            if [ "$1" = "$line" ]; then
                read line
    			eval $line
    			return 0
            fi
        done < ~/.aliasme/cmd
    fi
	return 1
}

_bashauto()
{
	local cur opts
	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"

	opts=""
    if [ -s ~/.aliasme/cmd ];then
    	while read line
    	do
    		opts+=" $line"
    		read line
    	done < ~/.aliasme/cmd
    fi
	COMPREPLY=( $(compgen -W "${opts}" ${cur}) )
	return 0
}

_autocomplete()
{
	if [ $ZSH_VERSION ]; then
		# zsh
		opts=""
        if [ -s ~/.aliasme/cmd ];then
    		while read line
    		do
    			opts+="$line "
    			read line
    		done < ~/.aliasme/cmd
        fi
		compctl -k "($opts)" al
	else
		# bash
		complete -F _bashauto al
	fi
}

_autocomplete

al(){
	if [ ! -z $1 ]; then
		if [ $1 = "ls" ]; then
			_list
		elif [ $1 = "add" ]; then
			_add $2 "$3"
		elif [ $1 = "rm" ]; then
			_remove $2
		elif [ $1 = "-h" ]; then
			echo "Usage:"
			echo "al add [name] [command]      # add alias command with name"
			echo "al rm [name]                 # remove alias by name"
			echo "al ls                        # alias list"
			echo "al [name]                    # execute alias associate with [name]"
			echo "al -v                        # version information"
			echo "al -h                        # help"
		elif [ $1 = "-v" ]; then
			echo "aliasme 3.0.0"
			echo "visit https://github.com/Jintin/aliasme for more information"
		else
			if ! _excute $1 ; then
				echo "not found"
			fi
		fi
	fi
}
