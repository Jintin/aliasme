#!/bin/bash

. test/assert.sh
. aliasme.sh

testInit() {
  if [[ ! -f ~/.aliasme/path ]]; then
    mkdir -p ~/.aliasme && touch ~/.aliasme/path
  fi
}

testAlias() {

  path_alias=$(pwd)

  name1=testaaa
  cmd1=cmdaaa
  testAdd $name1 $cmd1

  name2=testbbb
  cmd2=cmdbbb
  testAdd $name2 $cmd2

  testRemove $name1
  testRemove $name2
}

testAdd() {
  _add $1 $2
  if [[ $(_list) = *"$1 : $2"* ]]; then
    log_success "path test success"
  else
    log_failure "path test failure"
  fi
}

testRemove() {
  _remove $1
  if [[ $(_list) = *"$1"* ]]; then
    log_failure "remove test failure"
  else
    log_success "remove test success"
  fi
}

testInit
testAlias
