#!/bin/bash

. test/assert.sh
. aliasme.sh

testInit() {
  if [[ ! -f ~/.aliasme/list ]]; then
    mkdir -p ~/.aliasme && touch ~/.aliasme/list
  fi
}

testAlias() {

  path_alias=$(pwd)
  name1=testaaa
  name2=testbbb
  data=$(_list)
  testAdd $name1 $path_alias "$data"
  data1=$(_list)
  testAdd $name2 $path_alias "$data1"

  testRemove $name2 "$data1"
  testRemove $name1 "$data"

  assert_end
}

testAdd() {
  _add $1 $2
  if [[ ! -z $3 ]]; then
    assert _list "$3\n$1 : $2"
  else
    assert _list "$1 : $2"
  fi
}

testRemove() {
  _remove $1
  assert _list "$2"
}

testInit
testAlias
