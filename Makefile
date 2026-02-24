
build:
	odin build . -out:tasks

install:
	sudo cp tasks /usr/local/bin
