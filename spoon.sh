#!/usr/bin/env bash

# Spoon - a tiny and bashful static site generator.
# Love from Noah xx

name="Spoon"
version="0.1 alpha"

title=A Spoon of Vanilla
subtitle=The default Spoon setup
author=Spoon
url="http://example.com/
license="copyleft

# create files
write() {
	# check if an editor variable is set. If not, just use vi.
	[[ -z $EDITOR ]] && echo "\$EDITOR not exported in .bashrc; defaulting to vi." && EDITOR=vi

	
	# cuz i'm lazy, using -p stops any already created errors, and saves lines.
	mkdir -p .posts
	
	# if a slug isn't specified, exit
	[[ -z $2 ]] && echo "Please specify a url slug for your post." && exit
	# create a file var so the dir can easily be changed
	file=.posts/$(date -I)-$2.txt
	# if the file exists then exit
	[[ -f $file ]] && echo "That slug is already in use." && exit
	echo "Creating post with slug $2"
	# open in the text editor
	
	echo Write a page title here >> $file
	$EDITOR $file
	
	build		
	exit
}

edit(){
	[[ -z $2 ]] && echo Please specify a post to edit. && exit
	[[ -z $EDITOR ]] && echo "\$EDITOR not exported in .bashrc; defaulting to vi." && EDITOR=vi
	
	[[ -f .posts/$2.txt ]] && $EDITOR .posts/$2.txt && build || echo The post you specified does not exist. 
	
	exit
}

# build site
build() {
	echo Building posts:
	for filename in .posts/*.txt; do
		pagefile=$(basename $filename .txt)
		echo "    Building post $pagefile..."
		
		template=$(<assets/template.html)
		page=${template//"{TITLE}"/$title}
		page=${page//"{SUBTITLE}"/$subtitle}
		page=${page//"{AUTHOR}"/$author}
		page=${page//"{URL}"/$url}
		page=${page//"{LICENSE}"/$license}
		page=${page//"{PAGE_TITLE}"/$(head -n 1 .posts/$pagefile.txt)}
		page=${page//"{PAGE_DATE}"/$(echo $pagefile | cut -d - -f 1-3)}
		page=${template//"{PAGE_URL}"/$(basename $filename .txt | cut -d - -f 4-).html}
		page=${page//"{CONTENT}"/$(tail -n $(($(wc -l < .posts/$pagefile.txt)-1)) .posts/$pagefile.txt)}
		echo $page > $(echo $pagefile | cut -d - -f 4-).html
		
		# write each post to a placeholder index.
		echo "<li>$(echo $pagefile | cut -d - -f 1-3)&nbsp;<a href=\"$(basename $filename .txt | cut -d - -f 4-).html\">$(head -n 1 .posts/$pagefile.txt)</a></li>" >> .index.txt
	done
	echo Building index...
	
	template=$(<assets/template.html)
	page=${template//"{TITLE}"/$title}
	page=${page//"{SUBTITLE}"/$subtitle}
	page=${page//"{AUTHOR}"/$author}
	page=${page//"{URL}"/$url}
	page=${page//"{LICENSE}"/$license}
	page=${page//"{PAGE_TITLE}"/"Home"}
	page=${page//"{PAGE_DATE}"/generated $(date -I)}
	page=${template//"{PAGE_URL}"/$url}
	page=${page//"{CONTENT}"/$(tac .index.txt)}
	echo $page > index.html
	rm .index.txt
	echo Build complete.
	exit
}

[[ $1 == "post" ]] && write $@
[[ $1 == "edit" ]] && edit $@
#[[ $1 == "delete" ]] && delete $@
[[ $1 == "build" ]] && build

# putting exits above means this will only run if nothing specified
echo "$name version $version"
echo "To use: $0 [post/build]"
echo ""
echo "Commands:"
echo "    'post slug' creates a post with url slug."
echo "    'build' rebuilds the site."