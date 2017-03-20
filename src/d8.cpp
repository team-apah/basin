/*
 * Team Apah
 * SIUE Computer Science Senior Project
 *
 * d8.cpp
 */

#include <dem_functions.hpp>

int * d8(dem_point_t * dem, dem_index_t w, dem_index_t h) {
    dem_index_t size = w * h;

    // First we need to get the flows for each cell

    // Flow Direction Matrix (DDIRN) Init
    int * dir = (int *) malloc(sizeof(int) * size);

    // Need to avoid edge
    dem_index_t _w = w - 1;
    dem_index_t _h = h - 1;
    dem_point_t point, max, cur;
    dem_index_t i, max_i;

    dem_point_t drops[8];
    for (dem_index_t x = 1; x < _w; x++){
        for (dem_index_t y = 1; y < _h; y++){
            i = w * y + x;
            point = dem[i];

            // Get drops
            for (int v = 0; v < 4; v++) {
                cur = dem[w * (y + D8_ITER_ROW[v]) + (x + D8_ITER_COL[v])];
                drops[v] = point - cur;
            }
            for (int v = 4; v < 8; v++) { // Diagonal neigbors (NE, NW, SE, SW)
                cur = dem[w * (y + D8_ITER_ROW[v]) + (x + D8_ITER_COL[v])];
                drops[v] = (point - cur)/M_SQRT2; // Weight by distance
            }

            // Get larget weighted drop in elevation
            max = drops[0];
            max_i = 0;
            for (int v = 1; v < 8; v++) {
                cur = drops[v];
                if (cur > max) {
                    max = cur;
                    max_i = v;
                } else if (cur == max) {
                    max_i = v;
                }
            }

            if (max < 0) { // undifined direction (3a)
                dir[i] = -1;
            } else if (max >= 0) { // 
                dir[i] = D8_VALUES[max_i];
            }
        }
    }

    return dir;
}
