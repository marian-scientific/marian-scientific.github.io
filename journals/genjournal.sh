#!/bin/bash

rm -rf authors/* projects/*
sudo apt install -y imagemagick

# index file
echo "<html><head><link rel=\"stylesheet\" \
		href=\"style.css\"></head><body> \
		<h1>Marian Scientific Journal Entries</h1>" > "index.html"

IMG_PATTERN="res/*.jpg"
images=($IMG_PATTERN)
for ((i=${#images[@]}-1; i>=0; i--)); do
	IMG="${images[i]}"
	FILENAME=$(basename "$IMG")
	NO_EXT="${FILENAME%.*}"
	convert $IMG -resize 800x "res/thumbs/${NO_EXT}.jpg"
done

IMG_PATTERN="res/*.png"
images=($IMG_PATTERN)
for ((i=${#images[@]}-1; i>=0; i--)); do
	IMG="${images[i]}"
	FILENAME=$(basename "$IMG")
	NO_EXT="${FILENAME%.*}"
	convert $IMG -resize 800x "res/thumbs/${NO_EXT}.png"
done

FILE_PATTERN="src/*.ini"
files=($FILE_PATTERN)
for ((i=${#files[@]}-1; i>=0; i--)); do
	INIFILE="${files[i]}"
	source $INIFILE

    author=$(echo -e "${author}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -d '\r')
	date=$(echo -e "${date}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -d '\r')
	project=$(echo -e "${project}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -d '\r')
	project_ID=$(echo -e "${project_ID}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -d '\r')




# 2. Use 'sed' with an updated regex to capture anything after 'IMG ' and before ']'
	content=$(echo -e "$content" | sed -E 's/\[IMG (.*)\]/<img src="https://marian-scientific.github.io/journals/res/thumbs/="\1"\/>/g')

# 3. Print the new string
echo "$NEW_STRING"


	FILENAME=$(basename "$INIFILE")
	NO_EXT="${FILENAME%.*}"

	author_str="${author// /_}"
	project_ID_str="${project_ID// /_}"

	# author file
	if [ ! -e "authors/${author_str}.html" ]; then
		# create author file
		echo "<html><head><link rel=\"stylesheet\" \
		href=\"../style.css\"></head><body> \
		<h1>$author Journal Entries, AMDG</h1>" > "authors/${author_str}.html"
	fi
	# append to author file
	echo "<h3><a href=\"../${NO_EXT}.html\">#${NO_EXT} ($date):</a> <a href="../projects/${project_ID_str}.html">$project_ID ($project)</a></h3> \
	<p>$content</p><hr>" >> "authors/${author_str}.html"

	# project file
	if [ ! -e "projects/${project_ID_str}.html" ]; then
		# create project file
		echo "<html><head><link rel=\"stylesheet\" \
		href=\"../style.css\"></head><body> \
		<h1>$project_ID ($project) Journal Entries, <a href=\"../authors/${author_str}.html\">$author</a>, AMDG</h1>" > "projects/${project_ID_str}.html"
	fi
	# append to project file
	echo "<h3><a href=\"../${NO_EXT}.html\">#${NO_EXT} ($date):</a></h3> \
	<p>$content</p><hr>" >> "projects/${project_ID_str}.html"

	# append to index file
	echo "<h3><a href=\"${NO_EXT}.html\">#${NO_EXT} ($date):</a> <a href=\"authors/${author_str}.html\">$author</a> - <a href="projects/${project_ID_str}.html">$project_ID ($project)</a></h3> \
	<p>$content</p><hr>" >> "index.html"

	# standalone file
	echo "<html><head><link rel=\"stylesheet\" \
		href=\"style.css\"></head><body> \
		<h1>Journal Entry #${NO_EXT}</h1> \
		<h2><a href="projects/${project_ID_str}.html">$project_ID ($project)</a></h2> \
		<h3>$date, <a href=\"authors/${author_str}.html\">$author</a>, Marian Scientific, AMDG</h3> \
		<p>$content</p></body></html>" > "${NO_EXT}.html"

done

echo "</body></html>" >> "index.html"