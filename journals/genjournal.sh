#!/bin/bash

# index file
echo "<html><head><link rel=\"stylesheet\" \
		href=\"style.css\"></head><body> \
		<h1>Marian Scientific Journal Entries</h1>" > "index.html"

FILE_PATTERN="src/*.ini"
files=($FILE_PATTERN)
for ((i=${#files[@]}-1; i>=0; i--)); do
	INIFILE="${files[i]}"
	source $INIFILE
	FILENAME=$(basename "$INIFILE")
	NO_EXT="${FILENAME%.*}"

	# append to index file
	echo "<h3><a href=\"${NO_EXT}.html\">Entry ${NO_EXT} ($date):</a> $author: $project_ID ($project)</h3> \
	<p>$content</p><hr>" >> "index.html"

	# standalone file
	echo "<html><head><link rel=\"stylesheet\" \
		href=\"style.css\"></head><body> \
		<h1>Journal Entry #${NO_EXT}</h1> \
		<h2>$project_ID - $project</h2> \
		<h3>$date, $author, Marian Scientific, AMDG</h3> \
		<p>$content</p></body></html>" > "${NO_EXT}.html"

done

echo "</body></html>" >> "index.html"