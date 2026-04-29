open_project -reset proj

# Add kernel and testbench
add_files kernel/device.cpp
add_files -tb test/testbench.cpp
add_files -tb cpu/cpu_code.cpp
add_files -tb kernel/device.cpp

# Tell the top
set_top pw_advection

# Open a solution and remove any existing data
open_solution -reset solution1

# Set the target device
set_part "xcvu37p-fsvh2892-2L-e"

# Create a virtual clock for the current solution
create_clock -period "300MHz"

# Compile and runs pre-synthesis C simulation using the provided C test bench
csim_design

## Synthesize to RTL
#csynth_design
#
## Execute post-synthesis co-simulation of the synthesized RTL with the original C/C++-based test bench
#cosim_design

exit
