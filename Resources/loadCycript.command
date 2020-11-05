#!/bin/bash

if [ $# -gt 0 ]; then
	ssh -t root@localhost -p 2222 "bash -ic 'clear; cycript -p \"'$1'\"'"
else
	#/Users/moranander00/Library/Application-Support/Dolosoft/selectedApp.txt
	parent_path="/Users/$USER/Library/Application-Support/Dolosoft/"

	selected_app=$(head -n 1 $parent_path/selectedApp.txt) # this is the executable name, not the display name
	echo $selected_app
	ssh -t root@localhost -p 2222 "bash -ic 'clear; cycript -p \"'$selected_app'\"'"
	 
	# NOT SURE IF THE LINE BELOW IS STILL TRUE
	# Added the escaped quotes for apps with spaces in their names
	# however this did not work and I can't cycript apps with
	# a space in the executable name	
fi