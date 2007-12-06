###############################################################################
# Sloan Digital Sky Survey (SDSS)
# kcorrect
# M. Blanton
###############################################################################

SHELL = /bin/sh
#
all :
	idl mk_doc

#
# Install things in their proper places in $(DIMAGE_DIR)
#
install :
	- cp -r mk_doc html $(DIMAGE_DIR)/docs

clean :
	- /bin/rm -f *~ core www/*~ www/core


