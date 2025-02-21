lint:
	swiftlint --strict

build:
	swift build

test:
	swift test

build-wampproto:
	git clone https://github.com/xconnio/wampproto-cli.git
	cd wampproto-cli/ && make build && sudo cp ./wampproto /usr/local/bin/

run-xconn:
	git clone https://github.com/xconnio/xconn-aat-setup.git
	cd xconn-aat-setup/xconn && make run
