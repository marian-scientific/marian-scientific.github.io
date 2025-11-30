#!/bin/bash

rm -rf authors/* projects/* catalog/*
sudo apt install -y imagemagick

# index file
echo "<html><head><title>Marian Scientific Journal Entries</title><link rel=\"stylesheet\" \
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

index_file_10_post_string=""
num_index_posts=0;
author_list=""
project_list=""
month_list=""

CURRENT_MONTH_KEY=""

FILE_PATTERN="src/*.ini"
files=($FILE_PATTERN)
for ((i=${#files[@]}-1;i>=0;i--)); do
	INIFILE="${files[i]}"
	source $INIFILE

    author=$(echo -e "${author}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -d '\r')
	date=$(echo -e "${date}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -d '\r')
	project=$(echo -e "${project}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -d '\r')
	project_ID=$(echo -e "${project_ID}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -d '\r')

	content=$(echo "$content" | sed -E 's/\[IMG ([^]]*)\]/<br\/><a href="https:\/\/marian-scientific.github.io\/journals\/res\/\1"><center><img src="https:\/\/marian-scientific.github.io\/journals\/res\/thumbs\/\1"\/><\/center><\/a>/g')
	
	echo "$content"

	FILENAME=$(basename "$INIFILE")
	NO_EXT="${FILENAME%.*}"

	author_str="${author// /_}"
	project_ID_str="${project_ID// /_}"

	MONTH_KEY=$(echo "$date" | cut -d'-' -f1,2)

	if [ "$MONTH_KEY" != "$CURRENT_MONTH_KEY" ]; then

		CURRENT_MONTH_KEY="$MONTH_KEY"
		
		
		READABLE_MONTH=$(date -d "${MONTH_KEY}-01" +"%B %Y" 2>/dev/null)

		# catalog index file
		if [ ! -e "catalog/index.html" ]; then
			# create catalog index file
			echo "<html><head><title>Journal Entry Archive</title><link rel=\"stylesheet\" \
			href=\"../style.css\"></head><body> \
			<h1>Journal Entry Archive</h1>" > "catalog/index.html"
		fi
		# append to catalog index file
		if [ $num_index_posts -eq 0 ]; then
			month_list="${month_list}<h3><a href=\"${CURRENT_MONTH_KEY}.html\">${READABLE_MONTH}"
		else
			month_list="${month_list} (${CURRENT_MONTH_ENTRIES} entries)</a></h3><hr><h3><a href=\"${CURRENT_MONTH_KEY}.html\">${READABLE_MONTH}"
		fi

		CURRENT_MONTH_ENTRIES=0

	fi

	# month file
	if [ ! -e "catalog/${CURRENT_MONTH_KEY}.html" ]; then
		# create month file
		echo "<html><head><title>$READABLE_MONTH Entries</title><link rel=\"stylesheet\" \
		href=\"../style.css\"></head><body> \
		<h1>$READABLE_MONTH Journal Entries</h1>" > "catalog/${CURRENT_MONTH_KEY}.html"
	fi
	# append to month file
	echo "<h3><a href=\"${NO_EXT}.html\">#${NO_EXT} ($date):</a> <a href=\"../authors/${author_str}.html\">$author</a> - <a href="../projects/${project_ID_str}.html">$project_ID ($project)</a></h3> \
	<p>$content</p><hr>" >> "catalog/${CURRENT_MONTH_KEY}.html"
	CURRENT_MONTH_ENTRIES=$((CURRENT_MONTH_ENTRIES + 1))

	# author file
	if [ ! -e "authors/${author_str}.html" ]; then
		# create author file
		echo "<html><head><title>$author Entries</title><link rel=\"stylesheet\" \
		href=\"../style.css\"></head><body> \
		<h1>$author Journal Entries, AMDG</h1>" > "authors/${author_str}.html"
		if [ $num_index_posts -eq 0 ]; then
			author_list="${author_list}<a href=\"authors/${author_str}.html\">$author</a>"
		else
			author_list="${author_list},  <a href=\"authors/${author_str}.html\">$author</a>"
		fi
	fi
	# append to author file
	echo "<h3><a href=\"../${NO_EXT}.html\">#${NO_EXT} ($date):</a> <a href="../projects/${project_ID_str}.html">$project_ID ($project)</a></h3> \
	<p>$content</p><hr>" >> "authors/${author_str}.html"

	# project file
	if [ ! -e "projects/${project_ID_str}.html" ]; then
		# create project file
		echo "<html><head><title>Project #$project_ID</title><link rel=\"stylesheet\" \
		href=\"../style.css\"></head><body> \
		<h1>$project_ID ($project) Journal Entries</h1>" > "projects/${project_ID_str}.html"
		if [ $num_index_posts -eq 0 ]; then
			project_list="${project_list}<a href=\"projects/${project_ID_str}.html\">$project_ID ($project)</a>"
		else
			project_list="${project_list},  <a href=\"projects/${project_ID_str}.html\">$project_ID ($project)</a>"
		fi
	fi
	# append to project file
	echo "<h3><a href=\"../${NO_EXT}.html\">#${NO_EXT} ($date):</a> <a href=\"../authors/${author_str}.html\">$author</a></h3> \
	<p>$content</p><hr>" >> "projects/${project_ID_str}.html"

	# append to index file
	if [ $num_index_posts -lt 10 ]; then
		index_file_10_post_string="${index_file_10_post_string}<h3><a href=\"${NO_EXT}.html\">#${NO_EXT} ($date):</a> <a href=\"authors/${author_str}.html\">$author</a> - <a href="projects/${project_ID_str}.html">$project_ID ($project)</a></h3> \
		<p>$content</p><hr>"
	fi

	num_index_posts=$((num_index_posts + 1))

	# standalone file
	echo "<html><head><title>Entry #$NO_EXT</title><link rel=\"stylesheet\" \
		href=\"style.css\"></head><body> \
		<h1>Journal Entry #${NO_EXT}</h1> \
		<h2><a href="projects/${project_ID_str}.html">$project_ID ($project)</a></h2> \
		<h3>$date, <a href=\"authors/${author_str}.html\">$author</a>, Marian Scientific, AMDG</h3> \
		<p>$content</p></body></html>" > "${NO_EXT}.html"

done

echo "${month_list} (${CURRENT_MONTH_ENTRIES} entries)</a></h3><hr>" >> "catalog/index.html"

echo "<h2>Projects</h2><h3>${project_list}</h3> \
	<hr><h2>Contributors</h2><h3>${author_list}</h3> \
	<hr><h2>Recent Journal Entries   (<a href=\"catalog/index.html\">full ${num_index_posts}-post archive</a>)</h2> \
	${index_file_10_post_string}</body></html>" >> "index.html"