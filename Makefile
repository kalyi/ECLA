SCRIPT = ecla.sh
BIN ?= ecla
PREFIX ?= $(HOME)

install:
	cp $(SCRIPT) $(PREFIX)/bin/$(BIN)

uninstall:
	rm -f $(PREFIX)/bin/$(BIN)
