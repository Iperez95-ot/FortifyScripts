#!/bin/bash

# Script that creates or updates a Fortify ToolsConnectToken token for the user specified via input.
if [ -f "./$0.pid" ] ; then
	exit
else
	echo $$ >$0.pid
fi

date

python3 ./ManageFortifyToolsToken.py

rm -f ./$0.pid
