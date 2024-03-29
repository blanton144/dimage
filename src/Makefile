###############################################################################
# Sloan Digital Sky Survey (SDSS)
# IDL support code for products: idlmapper, idlspec2d
#
# S. Burles & D. Schlegel
###############################################################################

SHELL = /bin/sh
#
.c.o :
	$(CC) -c $(CCCHK) $(CFLAGS) $(X_CFLAGS) $*.c
#.f.o :
#	$(F77) -c $(CCCHK) $(CFLAGS) $(X_CFLAGS) $*.f
#
INC = ../../include
CFLAGS  = -O2 -fPIC -fno-common -D_REENTRANT -DCHECK_LEAKS -I$(INC)
X_LD_FLAGS = -shared

UNAME = $(shell uname)
ifeq ($(UNAME), Darwin)
	CFLAGS = -arch x86_64 -O2 -fPIC -dynamic -fno-common -D_REENTRANT -DCHECK_LEAKS -I$(INC)
	X_LD_FLAGS = -arch x86_64 -bundle -flat_namespace -undefined suppress
endif

SO_EXT=so
#LD=libtool -dynamic -L/usr/lib -lc

BIN = $(DIMAGE_DIR)/bin
LIB = $(DIMAGE_DIR)/lib

OBJECTS = \
	idl_dfloodfill.o \
	dfloodfill.o \
	idl_dobjects.o \
	dobjects.o \
	idl_dobjects_multi.o \
	dobjects_multi.o \
	idl_dsmooth.o \
	dsmooth.o \
	idl_dmedsmooth.o \
	dmedsmooth.o \
	idl_dmeansmooth.o \
	dmeansmooth.o \
	idl_dmsmooth.o \
	dfitpsf.o \
	idl_dfitpsf.o \
	simplexy.o \
	idl_simplexy.o \
	dsigma.o \
	idl_dsigma.o \
	dmsmooth.o \
	idl_dtemplates.o \
	dtemplates.o \
	dresample.o \
	dnonneg.o \
	drefine.o \
	dcholdc.o \
	dcholsl.o \
	dselip.o \
	dcen3x3.o \
	dzbrent.o \
	dmidinf.o \
	idl_dcen3x3.o \
	dallpeaks.o \
	idl_dallpeaks.o \
	idl_deblend.o \
	deblend.o \
	dcentral.o \
	idl_dweights.o \
	dweights.o \
	idl_dfluxes.o \
	dfluxes.o \
	idl_dfake.o \
	dfake.o \
	idl_dfind.o \
	dfind.o \
	dpeaks.o \
	dqromo.o \
	dqromo2.o \
	dmidpnt.o \
	dmidpnt2.o \
	dsersic_params.o \
	idl_dsersic_params.o \
	dpolint.o \
	dpolint2.o \
	nmf.o \
	dran3.o \
	dshift.o \
	dkernel_linear.o \
	dkernel_puresinc.o \
	dkernel_dampsinc.o \
	dkernel_bicubic.o \
	dkernel_lanczos.o \
	idl_dshift.o \
	idl_dpeaks.o

all : $(LIB)/libdimage.$(SO_EXT) 

$(LIB)/libdimage.$(SO_EXT): $(OBJECTS) dimage.h
	$(LD) $(X_LD_FLAGS) -o $(LIB)/libdimage.$(SO_EXT) $(OBJECTS) -lm

#
# Install things in their proper places in $(DIMAGE_DIR)
#
install : 
	-@ cp *.c $(DIMAGE_DIR)/src
	-@ cp *.h $(DIMAGE_DIR)/src
	-@ cp Makefile $(DIMAGE_DIR)/src

clean :
	- /bin/rm -f *~ core *.o so_locations
