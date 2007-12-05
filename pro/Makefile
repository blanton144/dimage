###############################################################################
# Sloan Digital Sky Survey (SDSS)
# IDL support code for products: idlmapper, idlspec2d
#
# S. Burles & D. Schlegel
###############################################################################

SHELL = /bin/sh
#
SUBDIRS = utils 

all :;

#
# Install things in their proper places in $(DIMAGE_DIR)
#
install :
	@ /bin/rm -rf $(DIMAGE_DIR)/pro
	@ mkdir $(DIMAGE_DIR)/pro
	@ for f in $(SUBDIRS); do \
		(echo Copying ; \
                cp *.pro $(DIMAGE_DIR)/pro/); \
	done
	-@ cp Makefile $(DIMAGE_DIR)/pro

clean :
	- /bin/rm -f *~ core
	@ for f in $(SUBDIRS); do \
		(/bin/rm -f core *~ ); \
	done
