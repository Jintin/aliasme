PREFIX ?= /usr/local

.PHONY: all test clean install

test:
	test/aliastest.sh

install:
	install -d $(DESTDIR)$(PREFIX)/bin
	install -m 755 aliasme.sh $(DESTDIR)$(PREFIX)/bin/aliasme
