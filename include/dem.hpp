/*
 * Team Apah
 * SIUE Computer Science Senior Project
 *
 * dem.hpp
 *
 * Contains basic DEM types and const values
 */

#ifndef CAHOKIA_DEM_HEADER
#define CAHOKIA_DEM_HEADER

// C Standard Library
#include <cfloat>
#include <cstdint>

/*
 * DEM Types
 */
typedef uint32_t dem_index_t;
typedef float dem_point_t;

#define DEM_POINT_MAX FLT_MAX
#define DEM_POINT_MIN FLT_MIN

// Direction Values
#define D8_PIT 0
#define D8_NE 1
#define D8_E 2
#define D8_SE 4
#define D8_S 8
#define D8_SW 16
#define D8_W 32
#define D8_NW 64
#define D8_N 128

/*
 * Arrays for directions and iterating through neighbors
 */
const int D8_VALUES[9] = {
    D8_N, D8_E, D8_S, D8_W, D8_NE, D8_SE, D8_SW, D8_NW
};

const int D8_VALUES_OPPOSITE[9] = {
    D8_S, D8_W, D8_N, D8_E, D8_SW, D8_NW, D8_SE, D8_SE
};

const int D8_ITER_COL[8] = {
    0, 1, 0, -1, 1, 1, -1, -1
};

const int D8_ITER_ROW[8] = {
    -1, 0, 1, 0, -1, 1, 1, -1
};

#endif
