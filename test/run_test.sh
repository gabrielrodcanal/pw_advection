#!/bin/sh

# All even
printf "&DIMENSIONS\nnx=8\nny=8\nnz=8\n/\n" > dimensions.nml
./f-test > f.out
./c-test ../../bin/pw_advection_kernel.sw_emu.xclbin 6 6 8 > c.out
python3 diff.py

# Odd X
printf "&DIMENSIONS\nnx=9\nny=8\nnz=8\n/\n" > dimensions.nml
./f-test > f.out
./c-test ../../bin/pw_advection_kernel.sw_emu.xclbin 7 6 8 > c.out
python3 diff.py

# Odd Y
printf "&DIMENSIONS\nnx=8\nny=15\nnz=8\n/\n" > dimensions.nml
./f-test > f.out
./c-test ../../bin/pw_advection_kernel.sw_emu.xclbin 6 13 8 > c.out
python3 diff.py

# Odd Z
printf "&DIMENSIONS\nnx=8\nny=8\nnz=15\n/\n" > dimensions.nml
./f-test > f.out
./c-test ../../bin/pw_advection_kernel.sw_emu.xclbin 6 6 15 > c.out
python3 diff.py

printf "&DIMENSIONS\nnx=8\nny=8\nnz=17\n/\n" > dimensions.nml
./f-test > f.out
./c-test ../../bin/pw_advection_kernel.sw_emu.xclbin 6 6 17 > c.out
python3 diff.py
