#!/usr/bin/env bash

# Storage path
ALIASME_DIR="${ALIASME_DIR:-$HOME/.aliasme}"
ALIASME_CMD="$ALIASME_DIR/cmd"

_list() {
	if [ -s "$ALIASME_CMD" ];then
		while read -r name
		do
			if ! read -r value; then break; fi
			echo "$name : $value"
		done < "$ALIASME_CMD"
	fi
}

_add() {
	# Ensure directory exists
	mkdir -p "$ALIASME_DIR"

	name=$1
	if [ -z "$1" ]; then
		read -rep "Input name to add:" name
	fi

	cmd="$2"
	if [ -z "$2" ]; then
		read -rep "Input cmd to add:" cmd
	fi

	echo "$name" >> "$ALIASME_CMD"
	echo "$cmd" >> "$ALIASME_CMD"
    echo "add: $name -> $cmd"

	_autocomplete
}

_remove() {
	name=$1
	if [ -z "$1" ]; then
		read -pr "Input name to remove:" name
	fi

    if [ -s "$ALIASME_CMD" ];then
        touch "$ALIASME_DIR/cmdtemp"
    	while read -r line
    	do
    		if [ "$line" = "$name" ]; then
    			read -r _ #skip one more line
                echo "remove $name"
    		else
    			echo "$line" >> "$ALIASME_DIR/cmdtemp"
    		fi
    	done < "$ALIASME_CMD"
    	mv "$ALIASME_DIR/cmdtemp" "$ALIASME_CMD"
    fi
	_autocomplete
}

_excute() {
    local alias_name="$1"
    if [ -s "$ALIASME_CMD" ];then
        while read -u9 -r line; do
            if [ "$alias_name" = "$line" ]; then
                read -u9 -r cmd
                shift # Remove alias name, $@ now has arguments
                
                local final_cmd="$cmd"
                local has_placeholder=false
                
                # Handle ?1, ?2, etc. (Positional)
                local i=1
                for arg in "$@"; do
                    if [[ "$final_cmd" == *"?"$i* ]]; then
                        final_cmd="${final_cmd//\?$i/$arg}"
                        has_placeholder=true
                    fi
                    ((i++))
                done
                
                # Handle ? (All arguments)
                if [[ "$final_cmd" == *"?"* ]]; then
                    # Double check it's not a positional one we missed (e.g. ?99)
                    local tmp_cmd="${final_cmd//\?[0-9]/}"
                    if [[ "$tmp_cmd" == *"?"* ]]; then
                        final_cmd="${final_cmd//\?/"$*"}"
                        has_placeholder=true
                    fi
                fi

                if [ "$has_placeholder" = true ]; then
                    eval "$final_cmd"
                else
                    # Default: append arguments if any
                    eval "$cmd" "$@"
                fi
    			return 0
            fi
        done 9< "$ALIASME_CMD"
    fi
	return 1
}

_bashauto()
{
	local cur opts
	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"

	opts=""
    if [ -s "$ALIASME_CMD" ];then
    	while read -r line
    	do
    		opts+=" $line"
    		read -r _
    	done < "$ALIASME_CMD"
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
        if [ -s "$ALIASME_CMD" ];then
    		while read -r line
    		do
    			opts+="$line "
    			read -r _
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
			echo "al [name] [args]             # execute alias associate with [name]"
			echo "                             # use ? for all args, ?1, ?2 for positional args"
			echo "al -v                        # version information"
			echo "al -h                        # help"
		elif [ "$1" = "-v" ]; then
			echo "aliasme 3.1.0"
			echo "visit https://github.com/Jintin/aliasme for more information"
		else
			if ! _excute "$@"; then
				echo "not found"
			fi
		fi
	fi
}
