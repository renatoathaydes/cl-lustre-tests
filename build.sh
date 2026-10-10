#! /bin/sh

sbcl --script /dev/stdin <<'EOF'
(load "init.lisp")
(load "cl-lustre-tests.asd")
(asdf:make "cl-lustre-tests")
EOF
