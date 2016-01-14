#!/bin/bash

. test/assert.sh
. aliasme.sh

testAlias() {
  data=$(list)
  path=$(pwd)
  name=testaaa

  add $name $path
  assert list "$data\n$name\n   :$path"
  remove $name
  assert list "$data"

  assert_end
}

testAlias
