#!/bin/bash

rm *.cs
rm *.tson
ruby gen_test_files.rb
SPACER="ruby -I../../lib ../../bin/spacer"
eval $SPACER --help
eval $SPACER Test.cs
eval $SPACER Test.tson
eval $SPACER -m spaces -o Test.spaces.cs Test.cs
eval $SPACER -m tabs -o Test.tabs.tson Test.cs
eval $SPACER -m tabs -o Test.spaces.tson Test.tson
eval $SPACER -m spaces -o Test.tabs.tson Test.tson
