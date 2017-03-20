/*
 * Team Apah
 * SIUE Computer Science Senior Project
 *
 * flow.cpp
 *
 * Does not actually work at the moment, only considers flow on a point by
 * point basis, not as a whole.
 */

#include <dem_functions.hpp>

float * flow(int * dir, dem_index_t w, dem_index_t h) {
    dem_index_t _w = w - 2;
    dem_index_t _h = h - 2;

    // Flow Accumulation
    float * acc = (float *) malloc(sizeof(float) * w * h);
    int neighbor;
    dem_index_t i;

    for (dem_index_t x = 2; x < _w; x++){
        for (dem_index_t y = 2; y < _h; y++){
            i = w * y + x;
            acc[i] = 0;
            for (int v = 0; v < 8; v++) {
                neighbor = dir[w * (y + D8_ITER_ROW[v]) + (x + D8_ITER_COL[v])];
                if (neighbor == D8_VALUES_OPPOSITE[v]) {
                    acc[i] = acc[i] + 1;
                }
            }
        }
    }
    
    return acc;
}

