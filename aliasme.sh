#!/usr/bin/env bash

list() {
	while read line
	do
    echo $line #name
    read line
    echo "   :$line" #value
	done < ~/.aliasme/list
}

add() {
  #read name
  name=$1
  if [ -z $1 ]; then
    read -r "Input name to add:" name
  fi

  #read path
	path=$2
	if [ -z $2 ]; then
		read -pr "Input path to add:" path
	fi
	path=$(cd $path;pwd)

	echo $name >> ~/.aliasme/list
	echo $path >> ~/.aliasme/list
}

remove() {
  #read name
  name=$1
  if [ -z $1 ]; then
    read -pr "Input name to remove:" name
  fi

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
}

jump() {
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

if [ ! -z $1 ]; then
  if [ $1 = "ls" ]; then
	  list
  elif [ $1 = "add" ]; then
    add $2 $3
  elif [ $1 = "rm" ]; then
	  remove $2
  else
	  jump $1
  fi
fi
