all: quantulaba

build:
	make C=ifort

debug:
	make C=ifortDEBUG

zeus:
	make C=ifortZEUS

# -----------------------------------
# Uzyj polecenia
# UMFPACK_MACRO=-DUSE_UMF_PACK
# aby skompilowac z UMFPACKIEM
UMFPACK_MACRO=-DUSE_PARDISO
#-DUSE_UMF_PACK
#-DUSE_PARDISO

#UMFPACK_MACRO=
ifeq ($(C),ifort)
FC=ifort

BASEDIR=/home/mkk/libs
FBFLAGS=  -O3  -132 -I$(BASEDIR)/XC


ifeq ($(UMFPACK_MACRO),-DUSE_UMF_PACK)
LIBS= $(BASEDIR)/libumfpack.a $(BASEDIR)/libamd.a
FCFLAGS= -c -O3  -132  $(UMFPACK_MACRO) -I$(BASEDIR)/XC
FCCFLAGS= -c -O3
SUPERLU_FILES=
UMFPACK_FILES=umfpack.o
else ifeq ($(UMFPACK_MACRO),-DUSE_PARDISO)
LIBS=
FCFLAGS= -c -O3  -132  $(UMFPACK_MACRO) -I$(BASEDIR)/XC
FCCFLAGS= -c -O3
SUPERLU_FILES=
UMFPACK_FILES=
else
LIBS= $(BASEDIR)/libsuperlu_4.3.a
FCFLAGS= -c -O3  -132  -I$(BASEDIR)/SuperLU_4.3/SRC $(UMFPACK_MACRO) -I$(BASEDIR)/XC
FCCFLAGS= -c -O3 -I$(BASEDIR)/SuperLU_4.3/SRC
SUPERLU_FILES=zgssv.o
UMFPACK_FILES=
endif
FLIBS=   $(LIBS)  -mkl -static-intel $(BASEDIR)/libxc.a

else ifeq ($(C),ifortDEBUG)
FC=ifort
BASEDIR =/home/mkk/libs
FBFLAGS =  -O0 -132

ifeq ($(UMFPACK_MACRO),-DUSE_UMF_PACK)
FCFLAGS = -c -132 -traceback -O0 -check all -fpe0 -warn -traceback -debug extended  $(UMFPACK_MACRO) -I$(BASEDIR)/XC
FCCFLAGS= -c -O0 -Wall -g
LIBS= $(BASEDIR)/libumfpack.a $(BASEDIR)/libamd.a
SUPERLU_FILES=
UMFPACK_FILES=umfpack.o
else ifeq ($(UMFPACK_MACRO),-DUSE_PARDISO)
LIBS=
FCFLAGS = -c -132 -traceback -O0 -check all -fpe0 -warn -traceback -debug extended  $(UMFPACK_MACRO) -I$(BASEDIR)/XC
FCCFLAGS= -c -O0 -Wall -g
SUPERLU_FILES=
UMFPACK_FILES=
else
LIBS= $(BASEDIR)/libsuperlu_4.3.a
FCFLAGS = -c -132 -traceback -O0 -check all -fpe0 -warn -traceback -debug extended -I$(BASEDIR)/SuperLU_4.3/SRC $(UMFPACK_MACRO) -I$(BASEDIR)/XC
FCCFLAGS= -c -O0 -Wall -g -I$(BASEDIR)/SuperLU_4.3/SRC
SUPERLU_FILES=zgssv.o
UMFPACK_FILES=
endif
FLIBS=   $(LIBS)  -mkl -static-intel  $(BASEDIR)/libxc.a

else ifeq ($(C),ifortZEUS)
FC=ifort
BASEDIR=/people/gjkolasi
FBFLAGS =  -O0 -132

ifeq ($(UMFPACK_MACRO),-DUSE_UMF_PACK)
LIBS= $(BASEDIR)/libumfpack.a $(BASEDIR)/libamd.a
FCFLAGS= -c -O3  -132  $(UMFPACK_MACRO) -I$(BASEDIR)/XC
FCCFLAGS= -c -O3
SUPERLU_FILES=
UMFPACK_FILES=umfpack.o
else ifeq ($(UMFPACK_MACRO),-DUSE_PARDISO)
LIBS=
FCFLAGS= -c -O3  -132  $(UMFPACK_MACRO) -I$(BASEDIR)/XC
FCCFLAGS= -c -O3
SUPERLU_FILES=
UMFPACK_FILES=
else
LIBS= $(BASEDIR)/libsuperlu_4.3.a
FCFLAGS= -c -O3  -132  -I$(BASEDIR)/SuperLU_4.3/SRC $(UMFPACK_MACRO) -I$(BASEDIR)/XC
FCCFLAGS= -c -O3 -I$(BASEDIR)/SuperLU_4.3/SRC -I$(BASEDIR)/XC
SUPERLU_FILES=zgssv.o
UMFPACK_FILES=
endif
FLIBS=   $(LIBS)  -mkl $(BASEDIR)/libxc.a

endif



quantulaba: main.f90 $(UMFPACK_FILES) modsys.o
	$(FC) $(FBFLAGS)  main.f90 *.o $(FLIBS)   -o $@

modsys.o: modsys.f90
	$(FC) $(FCFLAGS) modsys.f90 -o $@

zgssv.o:c_fortran_zgssv.c
	gcc   $(FCCFLAGS) c_fortran_zgssv.c -o $@

umfpack.o:umfpack.f90
	$(FC) $(FCFLAGS) umfpack.f90 -o $@

clean:
	rm *.o *.mod
