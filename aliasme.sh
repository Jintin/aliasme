#!/usr/bin/env bash

_list() {
	while read name
	do
		read value
		echo "$name : $value"
	done < ~/.aliasme/list
}

_add() {
	#read name
	name=$1
	if [ -z $1 ]; then
		read -ep "Input name to add:" name
	fi

	#read path
	path_alias=$2
	if [ -z $2 ]; then
		read -ep "Input path to add:" path_alias
	fi
	path_alias=$(cd $path_alias;pwd)

	echo $name >> ~/.aliasme/list
	echo $path_alias >> ~/.aliasme/list

	_autocomplete
}

_remove() {
	#read name
	name=$1
	if [ -z $1 ]; then
		read -pr "Input name to remove:" name
	fi
	touch ~/.aliasme/listtemp
	# read and replace file
	while read line
	do
		if [ $line = $name ]; then
			read line #skip one more line
		else
			echo $line >> ~/.aliasme/listtemp
		fi
	done < ~/.aliasme/list
	mv ~/.aliasme/listtemp ~/.aliasme/list
	_autocomplete
}

_jump() {
	while read line
	do
		if [ $1 = $line ]; then
			read line
			cd $line
			return
		fi
	done < ~/.aliasme/list
	echo "not found"
}

_bashauto()
{
	local cur prev opts
	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	opts=""
	while read line
	do
		opts+=" $line"
		read line
	done < ~/.aliasme/list
	COMPREPLY=( $(compgen -W "${opts}" ${cur}) )
	return 0
}

_autocomplete()
{
	if [ $ZSH_VERSION ]; then
		# zsh
		opts=""
		while read line
		do
			opts+="$line "
			read line
		done < ~/.aliasme/list
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
			_add $2 $3
		elif [ $1 = "rm" ]; then
			_remove $2
		elif [ $1 = "-h" ]; then
			echo "Usage:"
			echo "al add [name] [value]        # add alias with name and value"
			echo "al rm [name]                 # remove alias by name"
			echo "al ls                        # alias list"
			echo "al [name]                    # execute alias associate with [name]"
			echo "al -h                        # version information"
			echo "al -v                        # help"
		elif [ $1 = "-v" ]; then
			echo "aliasme 1.1.1"
			echo "visit https://github.com/Jintin/aliasme for more information"
		else
			_jump $1
		fi
	fi
}
