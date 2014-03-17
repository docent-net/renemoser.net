#!/bin/bash

read -p "Title (SLUG): " title 
now=$(date +"%Y-%m-%d")
cp ./source/_posts/_template.md ./source/_posts/${now}-${title}.md
echo created ./source/_posts/${now}-${title}.md
