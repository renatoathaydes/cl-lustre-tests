#! /bin/sh
set -eu

repo=$(CDPATH='' cd "$(dirname "$0")/.." && pwd)
work=$(mktemp -d "${TMPDIR:-/tmp}/lustre-script-tests.XXXXXX")
trap 'rm -rf "$work"' 0
trap 'exit 1' 1 2 15
mkdir "$work/bin"
cp "$repo/build.sh" "$repo/test.sh" "$repo/run-lisp.sh" "$work/"
cd "$work"
touch init.lisp cl-lustre-tests.asd open-test.jar

for impl in sbcl abcl ecl; do
    cat > "bin/$impl" <<'LISP'
#! /bin/sh
printf '%s\n' "${0##*/}" "$@" > "$LISP_LOG"
exit "${LISP_EXIT:-0}"
LISP
done
cat > bin/java <<'JAVA'
#! /bin/sh
printf '%s\n' "$@" > "$JAVA_LOG"
exit "${JAVA_EXIT:-0}"
JAVA
printf '%s\n' '#! /bin/sh' 'echo "Unexpected download" >&2; exit 99' > bin/curl
chmod +x bin/*
export PATH="$work/bin:$PATH"
export LISP_LOG="$work/lisp.log" JAVA_LOG="$work/java.log"
unset LISP_IMPL LISP_EXIT JAVA_EXIT
checks=0

expect_status() {
    expected=$1
    shift
    actual=0
    "$@" > output.log 2>&1 || actual=$?
    if [ "$actual" -ne "$expected" ]; then
        echo "FAIL: $* returned $actual, expected $expected" >&2
        cat output.log >&2
        exit 1
    fi
    checks=$((checks + 1))
}

expect_args() {
    impl=$1
    operation=$2
    case "$impl" in
        sbcl) set -- --no-userinit --non-interactive ;;
        abcl) set -- --noinit --batch ;;
        ecl) set -- --norc --nodebug ;;
    esac
    printf '%s\n' "$impl" "$@" --load init.lisp --load cl-lustre-tests.asd \
        --eval "(asdf:$operation \"cl-lustre-tests\")" \
        --eval '(uiop:quit)' > expected.log
    cmp expected.log "$LISP_LOG"
    checks=$((checks + 1))
}

for selection in default sbcl abcl ecl; do
    if [ "$selection" = default ]; then
        unset LISP_IMPL
        selected=sbcl
    else
        export LISP_IMPL=$selection
        selected=$selection
    fi
    expect_status 0 ./build.sh
    expect_args "$selected" make
    expect_status 0 ./test.sh
    expect_args "$selected" test-system

    export LISP_EXIT=7
    expect_status 7 ./build.sh
    expect_status 7 ./test.sh
    expect_status 7 ./test.sh -html
    printf '%s\n' -jar open-test.jar html-report unit-tests.xml > expected.log
    cmp expected.log "$JAVA_LOG"
    checks=$((checks + 1))
    unset LISP_EXIT
done

rm -f "$LISP_LOG"
export LISP_IMPL=unknown
expect_status 2 ./build.sh
expect_status 2 ./test.sh
[ ! -e "$LISP_LOG" ]
checks=$((checks + 1))
export LISP_IMPL=sbcl
expect_status 2 ./run-lisp.sh
expect_status 2 ./run-lisp.sh '(print :one)' '(print :two)'
[ ! -e "$LISP_LOG" ]
checks=$((checks + 1))

printf 'Build/test launcher checks passed: %s\n' "$checks"
