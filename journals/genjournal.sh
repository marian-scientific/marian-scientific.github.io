#!/bin/bash
for INIFILE in src/*.ini; do
	source $INIFILE
	FILENAME=$(basename "$INIFILE")
	NO_EXT="${FILENAME%.*}"
	echo "<html><head><link rel=\"stylesheet\" \
		href=\"style.css\"></head><body> \
		<h1>Journal Entry #${NO_EXT}</h1> \
		<h2>$project_ID - $project</h2> \
		<h3>$date, $author, Marian Scientific, AMDG</h3> \
		<p>$content</p></body></html>" > "${NO_EXT}.html"
done
