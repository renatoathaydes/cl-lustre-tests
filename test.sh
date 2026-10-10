#! /bin/sh

sbcl --script /dev/stdin <<'EOF'
(load "init.lisp")
(load "cl-lustre-tests.asd")
(asdf:test-system "cl-lustre-tests")
EOF
