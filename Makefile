all:
	@echo Usage: 	make publish

clean:
	rm -rf ./output_prod
	rm -rf ./output_dev

generate: clean
	sculpin generate --env=prod

publish: generate
	bash -c 'echo "($$(git describe --always))" > ./source/_views/git_rev.txt'
	rsync -avz --delete output_prod/ renemoser.net:/var/www/renemoser.net/www/public

post:
	./new.sh

watch:
	sculpin generate --watch --server 
