#!/bin/bash

rm *.txt
ruby gen_ender_test_files.rb
ENDER="ruby -e 'load(\$0=ARGV.shift);Ender.new.execute' -- ../../lib/ender.rb"
eval $ENDER -?
eval $ENDER cr.txt
eval $ENDER lf.txt
eval $ENDER crlf.txt
eval $ENDER mixed1.txt
eval $ENDER mixed2.txt
eval $ENDER mixed3.txt
eval $ENDER mixed4.txt
eval $ENDER -m lf -o cr2lf.txt cr.txt
eval $ENDER -m cr -o lf2cr.txt lf.txt
eval $ENDER -m lf -o crlf2lf.txt crlf.txt
eval $ENDER -m cr -o crlf2cr.txt crlf.txt
eval $ENDER -m auto mixed1.txt
eval $ENDER -m auto mixed2.txt
eval $ENDER -m auto mixed3.txt
eval $ENDER -m auto mixed4.txt
