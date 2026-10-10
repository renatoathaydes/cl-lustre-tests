#! /bin/sh

sbcl --non-interactive --load init.lisp --load cl-lustre-tests.asd --eval '(asdf:make "cl-lustre-tests")'
