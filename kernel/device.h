#include "definitions.h"

void pw_advection(struct packaged_double * u, struct packaged_double * v, struct packaged_double * w, struct packaged_double * su, struct packaged_double * sv, struct packaged_double * sw,
    REAL_TYPE * tzc1, REAL_TYPE * tzc2, REAL_TYPE * tzd1, REAL_TYPE * tzd2, REAL_TYPE tcx, REAL_TYPE tcy, unsigned int size_x, unsigned int size_y, unsigned int size_z);