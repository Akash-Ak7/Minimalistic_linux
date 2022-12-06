build:
	@echo "Building the mini_linux"
	./source/mini_linux

run:
	@echo "Starting mini_linux"
	./run.sh

clean:
	@echo "Removing all downloads."
	rm -rf ./downloads
	@echo "Removing all builds."
	rm -rf ./build
	@echo "Remove run script if exists."
	rm -f ./run.sh

all:
	@echo "Making mini_linux"
	./source/mini_linux
	@echo "Starting mini_linux"
	./run.sh