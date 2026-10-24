#! /bin/sh

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <Lisp form> (LISP_IMPL=sbcl|abcl|clisp|ecl; default: sbcl)" >&2
    exit 2
fi

form=$1

case "${LISP_IMPL:-sbcl}" in
    sbcl)
        set -- sbcl --no-userinit --non-interactive
        ;;
    abcl)
        set -- abcl --noinit --batch
        ;;
    clisp)
        exec clisp -q -norc -on-error exit -i init.lisp -i cl-lustre-tests.asd -x "$form"
        ;;
    ecl)
        set -- ecl --norc --nodebug
        ;;
    *)
        echo "Unsupported LISP_IMPL: $LISP_IMPL (expected sbcl, abcl, clisp, or ecl)" >&2
        exit 2
        ;;
esac

exec "$@" --eval '(load "init.lisp")' --eval '(load "cl-lustre-tests.asd")' \
    --eval "$form" --eval '(uiop:quit)'
