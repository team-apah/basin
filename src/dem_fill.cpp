/*
 * Team Apah
 * SIUE Computer Science Senior Project
 *
 * dem_fill.cpp
 */

#include <dem_functions.hpp>

void dem_fill(dem_point_t * dem, dem_index_t w, dem_index_t h) {
    dem_point_t current; // Value of current point
    dem_index_t current_i; // Index of current point
    dem_point_t neighbor; // Value of neighbor being inspected

    // Current minimum index and value among the neighbors
    dem_point_t min;

    // Fill all points except edges
    dem_index_t _w = w - 1;
    dem_index_t _h = h - 1;
    for (dem_index_t x = 1; x < _w; x++){
        for (dem_index_t y = 1; y < _h; y++){
            current_i = w * y + x;
            current = dem[current_i];
            min = DEM_POINT_MAX;

            // Find the minimum
            for (int v = 0; v < 8; v++) {
                neighbor = dem[w * (y + D8_ITER_ROW[v]) + (x + D8_ITER_COL[v])];
                if (neighbor < min) {
                    min = neighbor;
                }
            }

            // Fill it if it's a pit (the minimum of it and it's neighbors)
            if (current < min) {
                //printf("Fill @ <%lu, %lu>, %f to %f\n", x, y, current, min);
                dem[current_i] = min;
            }
        }
    }
}

