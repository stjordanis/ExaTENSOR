NAME = ExaTensor

#ADJUST THE FOLLOWING ACCORDINGLY:
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
#Nvidia GPU architecture (two digits):
export GPU_SM_ARCH ?= 35
#Operating system: [LINUX|NO_LINUX]:
export EXA_OS ?= LINUX

#ADJUST EXTRAS (optional):
#Fast GPU tensor transpose (cuTT library): [YES|NO]:
export WITH_CUTT ?= NO

#SET YOUR LOCAL PATHS (for unwrapped non-Cray builds):
#MPI library (whichever you have, set one):
# Set this if you use MPICH or its derivative (e.g. Cray-MPICH):
export PATH_MPICH ?= /usr/local/mpi/mpich/3.2.1
#  Only reset these if MPICH files are spread in the system directories:
 export PATH_MPICH_INC ?= $(PATH_MPICH)/include
 export PATH_MPICH_LIB ?= $(PATH_MPICH)/lib
 export PATH_MPICH_BIN ?= $(PATH_MPICH)/bin
# Set this if you use OPENMPI or its derivative (e.g. Spectrum MPI):
export PATH_OPENMPI ?= /usr/local/mpi/openmpi/3.1.0
#  Only reset these if OPENMPI files are spread in the system directories:
 export PATH_OPENMPI_INC ?= $(PATH_OPENMPI)/include
 export PATH_OPENMPI_LIB ?= $(PATH_OPENMPI)/lib
 export PATH_OPENMPI_BIN ?= $(PATH_OPENMPI)/bin

#BLAS library (whichever you want to use, set one):
# Set this if you do not have a vendor provided BLAS (default Linux BLAS):
export PATH_BLAS_ATLAS ?= /usr/lib
# Set this if you have vendor provided BLAS (choose):
#  MKL BLAS:
export PATH_BLAS_MKL ?= /opt/intel/mkl/lib/intel64
export PATH_BLAS_MKL_DEP ?= /opt/intel/compilers_and_libraries/linux/lib/intel64_lin
#  ACML BLAS:
export PATH_BLAS_ACML ?= /opt/acml/5.3.1/gfortran64_fma4_mp/lib
#  ESSL BLAS (also set PATH_IBM_XL_CPP, PATH_IBM_XL_FOR, PATH_IBM_XL_SMP below):
export PATH_BLAS_ESSL ?= /sw/summit/essl/6.1.0-1/essl/6.1/lib64

#IBM XL (only set these if you use IBM XL and/or ESSL):
export PATH_IBM_XL_CPP ?= /sw/summit/xl/16.1.1-beta4/xlC/16.1.1/lib
export PATH_IBM_XL_FOR ?= /sw/summit/xl/16.1.1-beta4/xlf/16.1.1/lib
export PATH_IBM_XL_SMP ?= /sw/summit/xl/16.1.1-beta4/xlsmp/5.1.1/lib

#CUDA (only if you build with CUDA):
export PATH_CUDA ?= /usr/local/cuda
# Only reset these if CUDA files are spread in the system directories:
 export PATH_CUDA_INC ?= $(PATH_CUDA)/include
 export PATH_CUDA_LIB ?= $(PATH_CUDA)/lib64
 export PATH_CUDA_BIN ?= $(PATH_CUDA)/bin
# cuTT path (only if you use cuTT library):
export PATH_CUTT ?= /home/dima/src/cutt

#YOU ARE DONE! MAKE IT!


$(NAME):
	$(MAKE) -C ./UTILITY
	$(MAKE) -C ./GFC
	$(MAKE) -C ./DDSS
	$(MAKE) -C ./TALSH
	$(MAKE) -C ./DSVP
	$(MAKE) -C ./INTRAVIRT
	$(MAKE) -C ./INTERVIRT
ifeq ($(EXA_OS),LINUX)
	$(MAKE) -C ./TN
endif
	$(MAKE) -C ./QFORCE
#Gather headers and module static libraries:
	rm -f ./include/*
	rm -f ./lib/*
	rm -f ./bin/*
ifeq ($(TOOLKIT),CRAY)
	cp ./INTERVIRT/OBJ/EXATENSOR.mod ./
	cp ./INTERVIRT/OBJ/EXATENSOR.mod ./include/
	cp ./INTRAVIRT/OBJ/TENSOR_RECURSIVE.mod ./include/
	cp ./INTRAVIRT/OBJ/SUBSPACES.mod ./include/
	cp ./TALSH/OBJ/TALSH.mod ./include/
	cp ./TALSH/OBJ/TENSOR_ALGEBRA.mod ./include/
	cp ./TALSH/OBJ/DIL_BASIC.mod ./include/
	cp ./TALSH/OBJ/TALSH.mod ./
else
	cp ./INTERVIRT/exatensor.mod ./
	cp ./INTERVIRT/exatensor.mod ./include/
	cp ./INTRAVIRT/tensor_recursive.mod ./include/
	cp ./INTRAVIRT/subspaces.mod ./include/
	cp ./TALSH/talsh.mod ./include/
	cp ./TALSH/tensor_algebra.mod ./include/
	cp ./TALSH/dil_basic.mod ./include/
	cp ./TALSH/talsh.mod ./
endif
ifeq ($(EXA_OS),LINUX)
	cp -u ./[A-Z]*/*.h ./include/
	cp -u ./[A-Z]*/*.hpp ./include/
	cp -u ./TN/*.cpp ./include/
else
	cp ./[A-Z]*/*.h ./include/
	cp ./[A-Z]*/*.hpp ./include/
	cp ./TN/*.cpp ./include/
endif
	cp ./[A-Z]*/*.a ./lib/
	cp ./[A-Z]*/*.x ./bin/
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
ifeq ($(TOOLKIT),GNU)
	g++ -shared -o libexatensor.so ./lib/*.o
else
	ld -shared -o libexatensor.so ./lib/*.o
endif
	cp ./TALSH/libtalsh.so ./
	cp ./libtalsh.so ./lib/
	cp ./libexatensor.so ./lib/
endif
	cp ./libexatensor.a ./lib/
	rm -rf ./lib/*.o
	echo "Finished successfully!"

.PHONY: clean
clean:
	rm -f ./*.x ./*.a ./*.so ./*.mod ./*/*.x ./*/*.a ./*/*.so ./*/*.mod ./*/OBJ/* ./bin/* ./lib/* ./include/*
