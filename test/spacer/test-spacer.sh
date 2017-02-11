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
eval $SPACER -m tabs -t 8 -o Test.spaces.tson Test.tson
eval $SPACER -m spaces -t 4 -o Test.tabs.tson Test.tson
eval $SPACER -m tabs -r -o Test.spaces.tson Test.tson
eval $SPACER -m spaces -r -o Test.tabs.tson Test.tson
