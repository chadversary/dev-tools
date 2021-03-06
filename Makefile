# Copyright 2015 Chad Versace <chad@kiwitree.net>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
# * Neither the name of the copyright holder nor the names of copyright
#   holder's contributors may be used to endorse or promote products
#   derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

.DEFAULT_GOAL := all

DESTDIR =
prefix = $(HOME)
bindir = $(prefix)/bin
libdir = $(prefix)/lib

PYTHON3 = python3
PYTHON3_VERSION = $(shell $(PYTHON3) make/print-python-version.py)
PYTHON_PKG_ROOT = $(libdir)/python$(PYTHON3_VERSION)/site-packages

SETUP_PY_INSTALL_ARGS = \
    --force \
    --prefix=$(prefix) \
    --install-lib=$(PYTHON_PKG_ROOT)
ifneq ($(DESTDIR),)
    SETUP_PY_INSTALL_ARGS += --root=$(DESTDIR)
endif

# See file config.mk.example.
-include config.mk

PY_SCRIPTS := \
    libdrm-configure \
    mesa-configure \
    piglit-configure \
    prefix-env \
    waffle-configure \
    $@

.PHONY: all
all:
	@

.PHONY: install
install: install-egg install-py-scripts
	@

.PHONY: install-egg
install-egg:
	$(PYTHON3) make/setup.py install $(SETUP_PY_INSTALL_ARGS)

.PHONY: install-py-scripts
install-py-scripts:
	@

# func install-py-script
#
# params:
# 	$(1): basename of a python script
#
define install-py-script
install-py-scripts: $(DESTDIR)$(bindir)/$(1)

# PHONY forces installation even if the installed file exists and is newer than
# the source file.
.PHONY: $(DESTDIR)$(bindir)/$(1)
$(DESTDIR)$(bindir)/$(1): bin/$(1)
	install -m755 -D $$< $$@
	sed -i 's:@PYTHON_PKG_ROOT@:$$(PYTHON_PKG_ROOT):g' $$@
endef

$(foreach x,$(PY_SCRIPTS),$(eval $(call install-py-script,$(x))))
