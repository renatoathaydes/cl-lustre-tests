#! /bin/sh

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <Lisp form> (LISP_IMPL=sbcl|abcl|ecl; default: sbcl)" >&2
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
    ecl)
        set -- ecl --norc --nodebug
        ;;
    *)
        echo "Unsupported LISP_IMPL: $LISP_IMPL (expected sbcl, abcl, or ecl)" >&2
        exit 2
        ;;
esac

exec "$@" --eval '(load "init.lisp")' --eval '(load "cl-lustre-tests.asd")' \
    --eval "$form" --eval '(uiop:quit)'
