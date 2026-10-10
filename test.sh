#! /bin/sh

sbcl --non-interactive --load init.lisp --load cl-lustre-tests.asd --eval '(asdf:test-system "cl-lustre-tests")'
