# give some default values
DESTDIR ?= /
ifeq (, $(PYTHON))
PYTHON=python
endif
PREFIX ?= $(shell $(PYTHON) -c 'import sys; print(sys.prefix)')

build: build-stamp

build-stamp: src/pykcs11_wrap.cpp
	$(PYTHON) setup.py build
	touch build-stamp

install: build
	$(PYTHON) setup.py install --prefix=$(PREFIX) --root=$(DESTDIR)

clean distclean:
	$(PYTHON) setup.py clean
	rm -f src/pykcs11_wrap.cpp
	rm -rf build
	rm -f *.pyc PyKCS11/*.pyc
	rm -f PyKCS11/LowLevel.py
	rm -f build-stamp

rebuild: clean build

src/pykcs11_wrap.cpp: src/pykcs11.i
	cd src ; swig -c++ -python pykcs11.i ; mv pykcs11_wrap.cxx pykcs11_wrap.cpp ; mv LowLevel.py ../PyKCS11/

src/pykcs11.i: src/opensc/pkcs11.h src/pkcs11lib.h src/pykcs11string.h src/ck_attribute_smart.h
	touch $@

dist: clean
	$(PYTHON) setup.py sdist

pypi: clean
	$(PYTHON) setup.py sdist upload

test: build
	cd PyKCS11 ; ln -sf ../build/*/PyKCS11/_LowLevel.so
	$(PYTHON) -m unittest discover

doc: build
	rm -rf html
	epydoc --verbose PyKCS11

doc-upload: doc
	mv html api
	scp -r api ludov@web.sourceforge.net:/home/project-web/pkcs11wrap/htdocs

.PHONY: build install clean rebuild dist doc
