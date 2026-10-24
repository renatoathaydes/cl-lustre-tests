#! /bin/sh

./run-lisp.sh '(asdf:test-system "cl-lustre-tests")'

exit_code=$?

case "$1" in
    -html)
        if [ ! -f "open-test.jar" ]; then
            curl -o open-test.jar https://repo1.maven.org/maven2/org/opentest4j/reporting/open-test-reporting-cli/0.2.7/open-test-reporting-cli-0.2.7-standalone.jar
        fi
        java -jar open-test.jar html-report unit-tests.xml
        ;;
esac

exit $exit_code
