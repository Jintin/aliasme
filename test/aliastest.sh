#!/bin/bash

. ./test/assert.sh

# Run against a throwaway store so the suite never touches the real ~/.aliasme
ALIASME_DIR=$(mktemp -d "${TMPDIR:-/tmp}/aliasme_test.XXXXXX")
export ALIASME_DIR
cleanup() {
  rm -rf "$ALIASME_DIR"
}
trap cleanup EXIT

# zsh's "." does not search the current directory, so keep the "./" prefix
. ./aliasme.sh

failures=0

# Names are prefixed: assert.sh declares "expected"/"actual" as arrays.
check() {
  local _desc="$1" _want="$2" _got="$3"
  if [ "$_want" = "$_got" ]; then
    log_success "$_desc"
  else
    log_failure "$_desc -- expected [$_want] got [$_got]"
    failures=$((failures + 1))
  fi
}

reset_store() {
  rm -f "$ALIASME_CMD"
}

log_header "Add and list"

reset_store
_add hello "echo hello" > /dev/null
_add world "echo world" > /dev/null
check "list renders both entries" \
  "hello : echo hello
world : echo world" "$(_list)"

check "duplicate name is rejected" "1" "$(_add hello "echo other" > /dev/null 2>&1; echo $?)"
# stdin is closed: with no arguments _add prompts for them interactively,
# and the suite must not block waiting on a terminal.
check "empty name is rejected" "1" "$(_add "" "" > /dev/null 2>&1 < /dev/null; echo $?)"

log_header "Remove"

reset_store
_add keep "echo keep" > /dev/null
_add drop "echo drop" > /dev/null
_remove drop > /dev/null
check "removed entry is gone" "keep : echo keep" "$(_list)"
check "removing an unknown name reports failure" "1" "$(_remove ghost > /dev/null 2>&1; echo $?)"

log_header "Execute"

reset_store
_add greet "echo hi" > /dev/null
check "alias runs its command" "hi" "$(al greet)"
check "unknown alias reports not found" "not found: nosuch" "$(al nosuch 2>&1)"
check "unknown alias exits non-zero" "1" "$(al nosuch > /dev/null 2>&1; echo $?)"

reset_store
_add fails "false" > /dev/null
check "failing command propagates its exit code" "1" "$(al fails > /dev/null 2>&1; echo $?)"
_add code "return 3" > /dev/null
check "exit code is passed through verbatim" "3" "$(al code > /dev/null 2>&1; echo $?)"

log_header "Name and command collision"

# A command line whose text equals another alias's name must never be
# mistaken for that name when executing or removing.
reset_store
_add x deploy > /dev/null
_add deploy "echo deploying" > /dev/null
check "lookup skips command lines" "deploying" "$(al deploy)"

_remove deploy > /dev/null
check "removal skips command lines" "x : deploy" "$(_list)"

log_header "Escapes and special characters"

reset_store
_add box 'printf "[%s]\n" done' > /dev/null
_add after "echo STILL_HERE" > /dev/null
check "backslash escapes are stored verbatim" \
  'box : printf "[%s]\n" done
after : echo STILL_HERE' "$(_list)"
check "entry after an escaped command is still reachable" "STILL_HERE" "$(al after)"
check "escaped command runs correctly" "[done]" "$(al box)"

reset_store
_add url "echo http://api.com/x?key=1" > /dev/null
check "literal ? in a command survives" "http://api.com/x?key=1" "$(al url)"
check "literal ? does not fail the command" "0" "$(al url > /dev/null 2>&1; echo $?)"

# Suppressing the "no matches" error must not disable globbing itself.
reset_store
touch "$ALIASME_DIR/globbed.txt"
_add glob "echo $ALIASME_DIR/*.txt" > /dev/null
check "an intentional glob still expands" "$ALIASME_DIR/globbed.txt" "$(al glob)"

log_header "Variable isolation"

reset_store
# shellcheck disable=SC2016  # the command is stored literally, on purpose
_add show 'echo "[$name][$value][$line]"' > /dev/null
name=OUTER
value=OUTER
line=OUTER
check "aliasme internals do not shadow user variables" \
  "[OUTER][OUTER][OUTER]" "$(al show)"

if [ "$failures" -gt 0 ]; then
  log_failure "$failures test(s) failed"
  exit 1
fi

log_success "All tests passed!"
