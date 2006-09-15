###############################################################################
# Sloan Digital Sky Survey (SDSS)
# IDL support code for products: idlmapper, idlspec2d
#
# S. Burles & D. Schlegel
###############################################################################

SHELL = /bin/sh
#
all :;

#
# Install things in their proper places in $(DIMAGE_DIR)
#
install :
	- cp *.dylib $(DIMAGE_DIR)/lib
	- cp *.so $(DIMAGE_DIR)/lib
	- cp *.a $(DIMAGE_DIR)/lib
	- cp Makefile $(DIMAGE_DIR)/lib

clean :
	- /bin/rm -f *~ core *.so *.a *.dylib

