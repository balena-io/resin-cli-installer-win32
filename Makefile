all: build/resin-cli-setup.exe

NODE_VERSION=0.12.0

build/node-x86.msi:
	mkdir -p `dirname $@`
	curl "http://nodejs.org/dist/v$(NODE_VERSION)/node-v$(NODE_VERSION)-x86.msi" -o $@

build/node-x64.msi:
	mkdir -p `dirname $@`
	curl "http://nodejs.org/dist/v$(NODE_VERSION)/x64/node-v$(NODE_VERSION)-x64.msi" -o $@

build/resin-cli-setup.exe: resin-cli.nsi build/node-x86.msi build/node-x64.msi
	makensis $<

clean:
	rm -rf build/
