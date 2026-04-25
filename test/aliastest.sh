#!/bin/bash

. test/assert.sh
# Mock ALIASME_DIR for testing to avoid touching user's real aliases
export ALIASME_DIR="/tmp/aliasme_test_$(date +%s)"
export ALIASME_CMD="$ALIASME_DIR/cmd"
mkdir -p "$ALIASME_DIR"

. aliasme.sh

testAdd() {
  local name="$1"
  local cmd="$2"
  _add "$name" "$cmd" > /dev/null
  if [[ $(_list) = *"$name : $cmd"* ]]; then
    log_success "Add $name success"
  else
    log_failure "Add $name failure"
    exit 1
  fi
}

testRemove() {
  local name="$1"
  _remove "$name" > /dev/null
  if [[ $(_list) = *"$name"* ]]; then
    log_failure "Remove $name failure"
    exit 1
  else
    log_success "Remove $name success"
  fi
}

testExecute() {
  local name="$1"
  shift
  local expected="${@: -1}" # last argument is expected output
  # All arguments except the last one are passed to 'al'
  local args=("${@:1:$#-1}")
  
  # Capture output of execution
  local actual
  actual=$(al "$name" "${args[@]}")
  
  if [ "$actual" == "$expected" ]; then
    log_success "Execute $name with args [${args[*]}] -> $actual"
  else
    log_failure "Execute $name: expected [$expected], but got [$actual]"
    exit 1
  fi
}

# Cleanup function
cleanup() {
  rm -rf "$ALIASME_DIR"
}
trap cleanup EXIT

log_header "Basic Operations"
testAdd "hello" "echo hello"
testAdd "world" "echo world"
testRemove "hello"
testRemove "world"

log_header "Dynamic Arguments (Append)"
testAdd "say" "echo"
testExecute "say" "hello" "hello"
testExecute "say" "hello world" "hello world"

log_header "Dynamic Arguments (Fill ?)"
testAdd "greet" "echo hello ?"
testExecute "greet" "Alice" "hello Alice"
testExecute "greet" "Alice and Bob" "hello Alice and Bob"

log_header "Dynamic Arguments (Multi-Fill ?1 ?2)"
testAdd "swap" "echo ?2 ?1"
testExecute "swap" "A" "B" "B A"
testExecute "swap" "first" "second" "second first"

log_header "Mixed Dynamic Arguments"
testAdd "mix" "echo ?2 ? ?1"
testExecute "mix" "one" "two" "three" "two one two three one" 
# Note: ? replaces with all arguments "$*", so "one two three"
# ?2 is "two", ?1 is "one"
# Result: "two one two three one"

log_success "All tests passed!"
