#!/usr/bin/env bash

function list() {
	while read line
	do
		echo $line #name
		read line
		echo "   :$line" #value
	done < ~/.aliasme/list
}

function add() {
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

	echo $name >> ~/.aliasme/list
	echo $path >> ~/.aliasme/list
	autocomplete
}

function remove() {
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
	autocomplete
}

function jump() {
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

function bashauto()
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

function autocomplete()
{
	if [ $ZSH_VERSION ]; then
		opts=""
		while read line
		do
			opts+="$line "
			read line
		done < ~/.aliasme/list
		compctl -k "($opts)" al
	else
		complete -F bashauto al
	fi
}

autocomplete

function al(){
	if [ ! -z $1 ]; then
		if [ $1 = "ls" ]; then
			list
		elif [ $1 = "add" ]; then
			add $2 $3
		elif [ $1 = "rm" ]; then
			remove $2
		elif [ $1 = "-h" ]; then
			echo "Usage:"
			echo "al add [name] [value]        # add alias with name and value"
			echo "al rm [name]                 # remove alias by name"
			echo "al ls                        # alias list"
			echo "al [name]                    # execute alias associate with [name]"
			echo "al -h                        # version information"
			echo "al -v                        # help"
		elif [ $1 = "-v" ]; then
			echo "aliasme 1.1"
			echo "visit https://github.com/Jintin/aliasme for more information"
		else
			jump $1
		fi
	fi
}
