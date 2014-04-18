#!/bin/bash

# Replace "sculpin generate" with "php sculpin.phar generate" if sculpin.phar
# was downloaded and placed in this directory instead of sculpin having been
# installed globally.

rm -rf ./output_prod

echo "($(git describe --always))" > ./source/_views/git_rev.txt 
sculpin generate --env=prod
if [ $? -ne 0 ]; then echo "Could not generate the site"; exit 1; fi

rsync -avz --delete output_prod/ renemoser.net:/var/www/renemoser.net/www/public
if [ $? -ne 0 ]; then echo "Could not publish the site"; exit 1; fi
