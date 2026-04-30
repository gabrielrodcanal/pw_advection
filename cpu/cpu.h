void advect_flow_fields_c(double*, double*, double*, double*, double*, double* , double*, double*,double*, double*, double, double,int, int, int, int, int, int, int, int);
void advect_u_flow_field_c(double*, double*, double*, double* , double*, double*, double, double,int, int, int, int, int, int, int, int);
void advect_v_flow_field_c(double*, double*, double*, double* , double*, double*, double, double,int, int, int, int, int, int, int, int);
void advect_w_flow_field_c(double*, double*, double*, double* , double*, double*, double, double,int, int, int, int, int, int, int, int);
long getEpoch();
double getTiming(long, long);
long long getTotalFLOPS(int, int, int, int);