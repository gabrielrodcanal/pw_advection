#include "../cpu/cpu.h"
#include "../kernel/device.h"
#include "../kernel/definitions.h"
#include <stdio.h>
#include <stdlib.h>

#include <fstream>

void print_3d_array(double * array, int size_x, int size_y, int size_z, const char * filename = nullptr) {
    FILE * file = filename ? fopen(filename, "w") : stdout;
    if (filename && !file) {
        printf("Error opening file %s\n", filename);
        return;
    }
    
    for (int i = 0; i < size_x; i++) {
        fprintf(file, "X=%d\n", i);
        for (int j = 0; j < size_y; j++) {
            for (int k = 0; k < size_z; k++) {
                fprintf(file, "%f ", array[(i * size_y * size_z) + (j * size_z) + k]);
            }
            fprintf(file, "\n");
        }
        fprintf(file, "\n");
    }
    
    if (filename) fclose(file);
}

void print_3d_array_packed(struct packaged_double * array, int size_x, int size_y, int size_z, const char * filename = nullptr) {
    FILE * file = filename ? fopen(filename, "w") : stdout;
    if (filename && !file) {
        printf("Error opening file %s\n", filename);
        return;
    }
    
    for (int i = 0; i < size_x; i++) {
        fprintf(file, "X=%d\n", i);
        for (int j = 0; j < size_y; j++) {
            for (int k = 0; k < size_z; k++) {
                int index = (i * size_y * size_z) + (j * size_z) + k;
                //printf("---> PRITNING INDEX: %d\n", index);
                int packed_index = index / EXTERNAL_DATA_WIDTH;
                int offset = index % EXTERNAL_DATA_WIDTH;
                fprintf(file, "%f ", array[packed_index].data[offset]);
            }
            fprintf(file, "\n");
        }
        fprintf(file, "\n");
    }
    
    if (filename) fclose(file);
}

int main() {
	//int size_x=atoi(argv[1]), size_y=atoi(argv[2]), iterations=atoi(argv[3]), size_z=64;
    int size_x = 8;
    int size_y = 8;
    int size_z = 16;
    int iterations = 1;

	int hs=3;
	int start_x=hs, end_x=size_x+hs, start_y=hs, end_y=size_y+hs;
	int field_x=size_x+(hs*2), field_y=size_y+(hs*2), field_z=size_z+(hs*2);
    double * su=(double *) malloc(sizeof(double) * field_x * field_y * field_z);
    double * sv=(double *) malloc(sizeof(double) * field_x * field_y * field_z);
    double * sw=(double *) malloc(sizeof(double) * field_x * field_y * field_z);
    double * u=(double *) malloc(sizeof(double) * field_x * field_y * field_z);
    double * v=(double *) malloc(sizeof(double) * field_x * field_y * field_z);
    double * w=(double *) malloc(sizeof(double) * field_x * field_y * field_z);
    double * tzc1=(double *) malloc(sizeof(double) * field_z);
    double * tzc2=(double *) malloc(sizeof(double) * field_z);
    double * tzd1=(double *) malloc(sizeof(double) * field_z);
    double * tzd2=(double *) malloc(sizeof(double) * field_z);

    struct packaged_double * su_rtl=(struct packaged_double *) malloc(sizeof(struct packaged_double) * field_x * field_y * field_z);
    struct packaged_double * sv_rtl=(struct packaged_double *) malloc(sizeof(struct packaged_double) * field_x * field_y * field_z);
    struct packaged_double * sw_rtl=(struct packaged_double *) malloc(sizeof(struct packaged_double) * field_x * field_y * field_z);
    struct packaged_double * u_rtl=(struct packaged_double *) malloc(sizeof(struct packaged_double) * field_x * field_y * field_z);
    struct packaged_double * v_rtl=(struct packaged_double *) malloc(sizeof(struct packaged_double) * field_x * field_y * field_z);
    struct packaged_double * w_rtl=(struct packaged_double *) malloc(sizeof(struct packaged_double) * field_x * field_y * field_z);
    double * tzc1_rtl=(double *) malloc(sizeof(double) * field_z);
    double * tzc2_rtl=(double *) malloc(sizeof(double) * field_z);
    double * tzd1_rtl=(double *) malloc(sizeof(double) * field_z);
    double * tzd2_rtl=(double *) malloc(sizeof(double) * field_z);

    int i;
    int packed_counter = 0;
    srand(42);
    int total_elements = field_x * field_y * field_z;
    for (i = 0; i < total_elements; i+=EXTERNAL_DATA_WIDTH) {
        for (int j = 0; j < EXTERNAL_DATA_WIDTH; j++) {
            double rand_val_u = (double)rand() / RAND_MAX;
            double rand_val_v = (double)rand() / RAND_MAX;
            double rand_val_w = (double)rand() / RAND_MAX;
            u[i+j] = 23.4;
            u_rtl[packed_counter].data[j] = 23.4;
            v[i+j] = 18.8;
            v_rtl[packed_counter].data[j] = 18.8;
            w[i+j] = 3.1;
            w_rtl[packed_counter].data[j] = 3.1;
        }
        packed_counter++;
    }

    //tzc1_data[i]=12.3;
    //tzc2_data[i]=1.9;
    //tzd1_data[i]=5.6;
    //tzd2_data[i]=23.8;

    for (i = 0; i < field_z; i++) {
        double tzc1_val = (double)rand() / RAND_MAX;
        double tzc2_val = (double)rand() / RAND_MAX;
        double tzd1_val = (double)rand() / RAND_MAX;
        double tzd2_val = (double)rand() / RAND_MAX;

        // Constants
        tzc1[i] = 12.3;
        tzc1_rtl[i] = 12.3;
        tzc2[i] = 1.9;
        tzc2_rtl[i] = 1.9;
        tzd1[i] = 5.6;
        tzd1_rtl[i] = 5.6;
        tzd2[i] = 23.8;
        tzd2_rtl[i] = 23.8;
    }

	printf("Advecting over a single thread (CPU) with compute domain X=%d Y=%d Z=%d, total domain size of X=%d Y=%d Z=%d\n", size_x, size_y, size_z, field_x, field_y, field_z);

    // CPU version
    long start=getEpoch();
    for (i=0;i<iterations;i++) {
       advect_flow_fields_c(su, sv, sw, u, v, w, tzc1, tzc2, tzd1, tzd2, 99.4, 12.3, field_x, field_y, field_z, start_x, end_x, start_y, end_y, hs);
    }
    double overalltime=getTiming(getEpoch(), start);
    printf("Runtime is %f ms\n", overalltime);

    double kernelFLOPS=(getTotalFLOPS(size_x, size_y, size_z, iterations) / (overalltime / 1000)) / 1024 / 1024 / 1024;
    printf("Overall GFLOPS %.2f\n", kernelFLOPS);

    //// RTL version
    //for (i=0;i<iterations;i++) {
    //    pw_advection(u_rtl, v_rtl, w_rtl, su_rtl, sv_rtl, sw_rtl, tzc1_rtl, tzc2_rtl, tzd1_rtl, tzd2_rtl, 99.4, 12.3, field_x, field_y, size_z);
    //}

    // Compare results
    int mismatches = 0;
    packed_counter = 0;
    for (i = 0; i < total_elements; i+=EXTERNAL_DATA_WIDTH) {
        for (int j = 0; j < EXTERNAL_DATA_WIDTH; j++) {
            if (su[i+j] != su_rtl[packed_counter].data[j] || sv[i+j] != sv_rtl[packed_counter].data[j] || sw[i+j] != sw_rtl[packed_counter].data[j]) {
                mismatches++;
                if (mismatches <= 10) {
                    printf("Mismatch at index %d: CPU su=%f, RTL su=%f; CPU sv=%f, RTL sv=%f; CPU sw=%f, RTL sw=%f\n", i+j, su[i+j], su_rtl[packed_counter].data[j], sv[i+j], sv_rtl[packed_counter].data[j], sw[i+j], sw_rtl[packed_counter].data[j]);
                }
            }
        }
        packed_counter++;
    }
    if (mismatches == 0) {
        printf("All results match between CPU and RTL versions.\n");
    } else {
        printf("Total mismatches: %d\n", mismatches);
    }

    int non_zero_su = 0;
    for(int i = 0; i < total_elements; i++) { 
        if(su[i] != 0.0) {
            non_zero_su++;
        }
    }
    printf("Non-zero elements in su: %d\n", non_zero_su);

    print_3d_array(su, field_x, field_y, field_z, "cpu_su_output.txt");
    print_3d_array_packed(su_rtl, field_x, field_y, field_z, "rtl_su_output.txt");
    print_3d_array(sv, field_x, field_y, field_z, "cpu_sv_output.txt");
    print_3d_array_packed(sv_rtl, field_x, field_y, field_z, "rtl_sv_output.txt");
    print_3d_array(sw, field_x, field_y, field_z, "cpu_sw_output.txt");
    print_3d_array_packed(sw_rtl, field_x, field_y, field_z, "rtl_sw_output.txt");

	return 0;
}
