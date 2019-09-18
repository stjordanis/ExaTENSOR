NAME = ExaTensor

### THIS IS A SPECIAL TEST, SO YOU ONLY NEED TO READ RIGHT BELOW. ###
### THE ONLY RELEVANT ENVIRONMENT VARIABLES YOU MAY NEED TO RESET ARE:
### 1. WRAP = NOWRAP (default for all compilers except on Cray systems);
###    WRAP = WRAP (activates the use of Cray compiler wrappers: ftn, cc, CC).
### 2. TOOLKIT = {GNU|INTEL|CRAY|IBM}: Choose your compiler suite.
###              Tested compilers: GNU 8.x (other versions have bugs);
###                                INTEL 18.x (previous versions have bugs);
###                                IBM XL 16.1.x (previous versions have bugs).
### 3. MPILIB = MPICH (preferred: Works with MPICH/3.2.1 and higher);
###                   (Cray-MPICH has open bugs, filed with Cray by Cathy Willis).
###    MPILIB = OPENMPI (OpenMPI has bugs, sometimes works with OpenMPI/3.1.0);
###                     (IBM SpectrumMPI based on OpenMPI works fine).
### 4. PATH_MPICH = <path to your MPICH or Cray-MPICH root directory>.
### 5. PATH_OPENMPI = <path to your OpenMPI or SpectrumMPI root directory>.
### YOU MAY SIMPLY EXPORT THE ABOVE ENVIRONMENT VARIABLES AND MAKE AND ###
### YOU DO NOT NEED TO READ ANYTHING ELSE BELOW, OR YOU MAY SET THEM HERE ###


#ADJUST THE FOLLOWING ENVIRONMENT VARIABLES ACCORDINGLY (choices are given)
#until you see "YOU ARE DONE!". The comments will guide you through (read them).
#Alternatively, you can export all relevant environment variables such that this
#Makefile will pick their values, so you will not need to update anything here.

#Cray cross-compiling wrappers (only for Cray): [WRAP|NOWRAP]:
export WRAP ?= NOWRAP
#Compiler: [GNU|PGI|INTEL|CRAY|IBM]:
export TOOLKIT ?= GNU
#Optimization: [DEV|OPT|PRF]:
export BUILD_TYPE ?= DEV
#MPI Library: [MPICH|OPENMPI]:
export MPILIB ?= MPICH
#BLAS: [ATLAS|MKL|ACML|ESSL|NONE]:
export BLASLIB ?= NONE
#Nvidia GPU via CUDA: [CUDA|NOCUDA]:
export GPU_CUDA ?= NOCUDA
#Nvidia GPU architecture (two digits, >=35):
export GPU_SM_ARCH ?= 35
#Operating system: [LINUX|NO_LINUX]:
export EXA_OS ?= LINUX


#ADJUST EXTRAS (optional):

#Fast GPU tensor transpose (cuTT library): [YES|NO]:
export WITH_CUTT ?= NO
#In-place GPU tensor contractions (cuTensor library): [YES|NO]:
export WITH_CUTENSOR ?= NO


#ADJUST PARTIAL BUILD OPTIONS:

#Disable actual build completely (debug): [YES|NO]:
export EXA_NO_BUILD ?= NO
#Only enable TAL-SH build ($EXA_NO_BUILD must be NO): [YES|NO]:
export EXA_TALSH_ONLY ?= NO
#The build is part of ExaTN: [YES|NO]:
export EXATN_SERVICE ?= NO


#SET YOUR LOCAL PATHS (for unwrapped non-Cray builds):

#MPI library (whichever you have, set one):
# Set this if you use MPICH or its derivative (e.g. Cray-MPICH):
export PATH_MPICH ?= /usr/local/mpi/mpich/3.2.1
#  Only reset these if MPICH files are spread in system directories:
 export PATH_MPICH_INC ?= $(PATH_MPICH)/include
 export PATH_MPICH_LIB ?= $(PATH_MPICH)/lib
 export PATH_MPICH_BIN ?= $(PATH_MPICH)/bin
# Set this if you use OPENMPI or its derivative (e.g. IBM Spectrum MPI):
export PATH_OPENMPI ?= /usr/local/mpi/openmpi/3.1.0
#  Only reset these if OPENMPI files are spread in system directories:
 export PATH_OPENMPI_INC ?= $(PATH_OPENMPI)/include
 export PATH_OPENMPI_LIB ?= $(PATH_OPENMPI)/lib
 export PATH_OPENMPI_BIN ?= $(PATH_OPENMPI)/bin

#BLAS library (whichever you have chosen above):
# Set this path if you have chosen ATLAS (default Linux BLAS):
export PATH_BLAS_ATLAS ?= /usr/lib/x86_64-linux-gnu
# Set this path if you have chosen Intel MKL:
export PATH_INTEL ?= /opt/intel
#  Only reset these if Intel MKL libraries are spread in system directories:
export PATH_BLAS_MKL ?= $(PATH_INTEL)/mkl/lib/intel64
export PATH_BLAS_MKL_DEP ?= $(PATH_INTEL)/compilers_and_libraries/linux/lib/intel64_lin
export PATH_BLAS_MKL_INC ?= $(PATH_INTEL)/mkl/include/intel64/lp64
# Set this path if you have chosen ACML:
export PATH_BLAS_ACML ?= /opt/acml/5.3.1/gfortran64_fma4_mp/lib
# Set this path if you have chosen ESSL (also set PATH_IBM_XL_CPP, PATH_IBM_XL_FOR, PATH_IBM_XL_SMP below):
export PATH_BLAS_ESSL ?= /sw/summit/essl/6.1.0-2/essl/6.1/lib64

#IBM XL (only set these if you use IBM XL and/or ESSL):
export PATH_IBM_XL_CPP ?= /sw/summit/xl/16.1.1-1/xlC/16.1.1/lib
export PATH_IBM_XL_FOR ?= /sw/summit/xl/16.1.1-1/xlf/16.1.1/lib
export PATH_IBM_XL_SMP ?= /sw/summit/xl/16.1.1-1/xlsmp/5.1.1/lib

#CUDA (only if you build with CUDA):
export PATH_CUDA ?= /usr/local/cuda
# Only reset these if CUDA files are spread in system directories:
 export PATH_CUDA_INC ?= $(PATH_CUDA)/include
 export PATH_CUDA_LIB ?= $(PATH_CUDA)/lib64
 export PATH_CUDA_BIN ?= $(PATH_CUDA)/bin
 export CUDA_HOST_COMPILER ?= /usr/bin/g++
# cuTT path (only if you use cuTT library):
export PATH_CUTT ?= /home/dima/src/cutt
# cuTensor path (only if you use cuTensor library):
export PATH_CUTENSOR ?= /home/dima/src/cutensor

#YOU ARE DONE! MAKE IT!


$(NAME):
ifeq ($(EXA_NO_BUILD),NO)
ifeq ($(EXA_TALSH_ONLY),NO)
	$(MAKE) -C ./UTILITY
	$(MAKE) -C ./GFC
	$(MAKE) -C ./DDSS
endif
	$(MAKE) -C ./TALSH
ifeq ($(EXA_TALSH_ONLY),NO)
	$(MAKE) -C ./DSVP
	$(MAKE) -C ./INTRAVIRT
	$(MAKE) -C ./INTERVIRT
ifeq ($(EXA_OS),LINUX)
	$(MAKE) -C ./TN
endif
	$(MAKE) -C ./QFORCE
endif
#Gather headers, modules and libraries:
	rm -f ./include/*
	rm -f ./lib/*
	rm -f ./bin/*
ifeq ($(EXA_OS),LINUX)
ifeq ($(TOOLKIT),CRAY)
	cp -u ./[A-Z]*/OBJ/*.mod ./include/
else
	cp -u ./[A-Z]*/*.mod ./include/
endif
	cp -u ./TALSH/*.h ./include/
	cp -u ./TALSH/*.hpp ./include/
else
ifeq ($(TOOLKIT),CRAY)
	cp ./[A-Z]*/OBJ/*.mod ./include/
else
	cp ./[A-Z]*/*.mod ./include/
endif
	cp ./TALSH/*.h ./include/
	cp ./TALSH/*.hpp ./include/
endif
	cp ./[A-Z]*/*.a ./lib/
	cp ./[A-Z]*/*.x ./bin/
ifeq ($(EXA_TALSH_ONLY),NO)
	cp ./QFORCE/Qforce.x ./
#Create static and shared libraries:
	ar x ./lib/libintervirt.a
	ar x ./lib/libintravirt.a
	ar x ./lib/libdsvp.a
	ar x ./lib/libddss.a
	ar x ./lib/libtalsh.a
	ar x ./lib/libgfc.a
	ar x ./lib/libutility.a
	mv ./*.o ./lib/
	ar cr libexatensor.a ./lib/*.o
ifeq ($(EXA_OS),LINUX)
ifeq ($(WRAP),WRAP)
	CC -shared -o libexatensor.so ./lib/*.o
else
ifeq ($(TOOLKIT),IBM)
	$(PATH_$(MPILIB)_BIN)/mpicxx -qmkshrobj -o libexatensor.so ./lib/*.o
else
	$(PATH_$(MPILIB)_BIN)/mpicxx -shared -o libexatensor.so ./lib/*.o
endif
endif
	cp -u ./libexatensor.so ./lib/
	cp -u ./libexatensor.a ./lib/
	cp -u ./TALSH/libtalsh.so ./
	cp -u ./TALSH/libtalsh.so ./lib/
else
	cp ./libexatensor.a ./lib/
endif
	rm -f ./lib/*.o
else
ifeq ($(EXA_OS),LINUX)
	cp -u ./TALSH/libtalsh.so ./
	cp -u ./TALSH/libtalsh.so ./lib/
endif
endif
endif
	echo "Finished successfully!"

.PHONY: clean
clean:
	rm -f ./*.x ./*.a ./*.so ./*.mod ./*/*.x ./*/*.a ./*/*.so ./*/*.mod ./*/OBJ/* ./bin/* ./lib/* ./include/*
