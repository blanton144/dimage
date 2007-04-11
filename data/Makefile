###############################################################################
# Sloan Digital Sky Survey (SDSS)
# IDL support code for products: idlmapper, idlspec2d
#
# S. Burles & D. Schlegel
###############################################################################

SHELL = /bin/sh
#
SUBDIRS = .

all :;

#
# Install things in their proper places in $(DIMAGE_DIR)
#
install :
	@ /bin/rm -rf $(DIMAGE_DIR)/data
	@ mkdir $(DIMAGE_DIR)/data
	@ for f in $(SUBDIRS); do \
		(echo Copying ; \
                cp *.par $(DIMAGE_DIR)/data/); \
	done
	-@ cp Makefile $(DIMAGE_DIR)/data

clean :
	- /bin/rm -f *~ core
	@ for f in $(SUBDIRS); do \
		(/bin/rm -f core *~ ); \
	done
