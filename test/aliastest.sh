#!/bin/bash

. test/assert.sh
. aliasme.sh

testInit() {
  if [[ ! -f ~/.aliasme/list ]]; then
    mkdir -p ~/.aliasme && touch ~/.aliasme/list
  fi
}

testAlias() {

  path=$(pwd)
  name1=testaaa
  name2=testbbb
  data=$(list)
  testAdd $name1 $path "$data"
  data1=$(list)
  testAdd $name2 $path "$data1"

  testRemove $name2 "$data1"
  testRemove $name1 "$data"

  assert_end
}

testAdd() {
  add $1 $2
  if [[ ! -z $3 ]]; then
    assert list "$3\n$1\n   :$2"
  else
    assert list "$1\n   :$2"
  fi
}

testRemove() {
  remove $1
  assert list "$2"
}

testInit
testAlias
