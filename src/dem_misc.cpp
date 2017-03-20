/*
 * Team Apah
 * SIUE Computer Science Senior Project
 *
 * dem_misc.cpp
 */

#include <dem_functions.hpp>

void dem_print(dem_point_t * dem, dem_index_t w, dem_index_t h) {
    for (dem_index_t x = 0; x < w; x++){
        for (dem_index_t y = 0; y < h; y++){
            printf("%3.2f,", dem[w*y+x]);
        }
        printf("\n");
    }
}

void dem_dir_print(int * dir, dem_index_t w, dem_index_t h) {
    dem_index_t _w = w - 1;
    dem_index_t _h = h - 1;

    // Print Flow directions
    for (dem_index_t x = 1; x < _w; x++){
        for (dem_index_t y = 1; y < _h; y++){
            switch (dir[w * y + x]) {
                case D8_N:
                    printf(" ⇑");
                    break;
                case D8_E:
                    printf(" ⇒");
                    break;
                case D8_NE:
                    printf(" ⇗");
                    break;
                case D8_SE:
                    printf(" ⇘");
                    break;
                case D8_SW:
                    printf(" ⇙");
                    break;
                case D8_NW:
                    printf(" ⇖");
                    break;
                case D8_W:
                    printf(" ⇐");
                    break;
                case D8_S:
                    printf(" ⇓");
                    break;
                case D8_PIT: 
                    printf(" *");
                    break;
                default:
                    printf(" ?");
            }
        }
        printf("\n");
    }
}

