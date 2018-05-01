#!/usr/bin/env bash

_list() {
	if [ -s ~/.aliasme/path ];then
		echo "PATH:"
		while read name
		do
			read value
			echo "$name : $value"
		done < ~/.aliasme/path
	fi

	if [ -s ~/.aliasme/cmd ];then
		echo "CMD:"
		while read name
		do
			read value
			echo "$name : $value"
		done < ~/.aliasme/cmd
	fi
}

_path() {
	#read name
	name=$1
	if [ -z $1 ]; then
		read -ep "Input name to add:" name
	fi

	#read path
	path=$2
	if [ -z $2 ]; then
		read -ep "Input path to add:" path
	fi
	path=$(cd $path;pwd)

	echo $name >> ~/.aliasme/path
	echo $path >> ~/.aliasme/path

	_autocomplete
}

_cmd() {
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

	_autocomplete
}

_remove() {
	#read name
	name=$1
	if [ -z $1 ]; then
		read -pr "Input name to remove:" name
	fi

	# read and replace file
    if [ -s ~/.aliasme/path ];then
        touch ~/.aliasme/pathtemp
    	while read line
    	do
    		if [ $line = $name ]; then
    			read line #skip one more line
    		else
    			echo $line >> ~/.aliasme/pathtemp
    		fi
    	done < ~/.aliasme/path
        mv ~/.aliasme/pathtemp ~/.aliasme/path
    fi
    if [ -s ~/.aliasme/cmd ];then
        touch ~/.aliasme/cmdtemp
    	while read line
    	do
    		if [ $line = $name ]; then
    			read line #skip one more line
    		else
    			echo $line >> ~/.aliasme/cmdtemp
    		fi
    	done < ~/.aliasme/cmd
    	mv ~/.aliasme/cmdtemp ~/.aliasme/cmd
    fi
	_autocomplete
}

_jump() {
    if [ -s ~/.aliasme/path ];then
    	while read line
    	do
    		if [ $1 = $line ]; then
    			read line
    			cd $line
    			return 0
    		fi
    	done < ~/.aliasme/path
    fi
	return 1
}

_excute() {
    if [ -s ~/.aliasme/cmd ];then
    	while read line
    	do
    		if [ $1 = $line ]; then
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
    if [ -s ~/.aliasme/path ];then
    	while read line
    	do
    		opts+=" $line"
    		read line
    	done < ~/.aliasme/path
    fi
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
        if [ -s ~/.aliasme/path ];then
    		while read line
    		do
    			opts+="$line "
    			read line
    		done < ~/.aliasme/path
        fi
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
		elif [ $1 = "path" ]; then
			_path $2 $3
		elif [ $1 = "cmd" ]; then
			_cmd $2 "$3"
		elif [ $1 = "rm" ]; then
			_remove $2
		elif [ $1 = "-h" ]; then
			echo "Usage:"
			echo "al path [name] [value]       # add alias path with name"
			echo "al cmd [name] [command]      # add alias command with name"
			echo "al rm [name]                 # remove alias by name"
			echo "al ls                        # alias list"
			echo "al [name]                    # execute alias associate with [name]"
			echo "al -v                        # version information"
			echo "al -h                        # help"
		elif [ $1 = "-v" ]; then
			echo "aliasme 2.0.0"
			echo "visit https://github.com/Jintin/aliasme for more information"
		else
			if ! _jump $1 && ! _excute $1 ; then
				echo "not found"
			fi
		fi
	fi
}
