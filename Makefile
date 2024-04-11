.RECIPEPREFIX +=
#######################################################################################
.PHONY: help
help:
  @echo "Makefile Usage:"
  @echo "  make build TARGET=<sw_emu/hw_emu/hw>"
  @echo "      Command to generate the design for specified Target and Device."
  @echo ""
  @echo "  make host "
  @echo "      Command to generate host."
  @echo ""
  @echo "  make device "
  @echo "      Command to generate hardware platform files(xo,xclbin)."
  @echo ""
  @echo "  make clean "
  @echo "      Command to remove the generated files."
  @echo ""
#######################################################################################
TARGET := sw_emu
PLATFORM := xilinx_u280_xdma_201920_3
HOST_EXE := host
XO := pw_advection_kernel.$(TARGET).xo
XCLBIN := pw_advection_kernel.$(TARGET).xclbin

KERNEL_NAME := pw_advection_kernel

DEVICE_SRCDIR:=kernel
TEMP_DIR := ./_x.$(TARGET)

SOURCES  := $(wildcard $(DEVICE_SRCDIR)/*.cpp)
INCLUDES := $(wildcard $(DEVICE_SRCDIR)/*.h)
OBJECTS  := $(SOURCES:$(DEVICE_SRCDIR)/%.cpp=%.xo)

# Host building global settings
CXXFLAGS := -I$(XILINX_XRT)/include/ -I$(XILINX_VIVADO)/include/ -Wall -O3 -std=c++11 -L$(XILINX_XRT)/lib/ -lpthread -lrt -lstdc++
CXXFLAGS2 := -lOpenCL

# Kernel compiler & linker global settings
KRNL_COMPILE_OPTS := -t $(TARGET) --config ../design.cfg --save-temps -j 26
KRNL_LINK_OPTS := -t $(TARGET) --config ../link.cfg -j 26

build:  $(XO) $(XCLBIN) $(HOST_EXE) emconfig
  
.PHONY: device
.ONESHELL:
device: mkrefdir $(OBJECTS) $(XCLBIN)
  cp reference_files_$(TARGET)/$(XCLBIN) bin/.

mkrefdir:
  rm -Rf reference_files_$(TARGET)
  mkdir -p reference_files_$(TARGET)
  mkdir -p bin

# Building kernel
.PHONY: $(OBJECTS)
$(OBJECTS): %.xo : $(DEVICE_SRCDIR)/%.cpp
  cd reference_files_$(TARGET) ; v++ $(KRNL_COMPILE_OPTS) -c -k pw_advection -I'../include' -I'../$(<D)' -o'$@' ../$<

.PHONY: $(XCLBIN)
$(XCLBIN): $(OBJECTS)
  cd reference_files_$(TARGET) ; v++ $(KRNL_LINK_OPTS) -l -o'$@' $(+)

.PHONY: $(HOST_EXE)
# Building Host
$(HOST_EXE): host/host.cpp
  g++ $(CXXFLAGS) -o bin/host '$<' $(CXXFLAGS2)

# Building tests
test: test-odd_z

test-odd_z: test/odd_z/odd_z.cpp
  g++ $(CXXFLAGS) -o test/odd_z/c-test-odd_z '$<' $(CXXFLAGS2)
  gfortran test/odd_z/odd_z-pw_advection.f90 -o test/odd_z/f-odd_z-pw_advection 

.PHONY: cpu
cpu: cpu/cpu_code.c
  g++ $(CXXFLAGS) -o bin/cpu_code '$<' $(CXXFLAGS2) -fopenmp

.PHONY: emconfig
emconfig:
  emconfigutil --platform $(PLATFORM)

# Cleaning stuff
.PHONY: clean
clean:
  rm -f $(HOST_EXE) *mmult.$(TARGET).$(PLATFORM).* *.log *.json *.xo
