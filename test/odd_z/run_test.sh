#!/bin/sh

./f-odd_z-pw_advection > f.out
./c-test-odd_z ../../bin/pw_advection_kernel.sw_emu.xclbin 6 6 > c.out
python3 diff.py
