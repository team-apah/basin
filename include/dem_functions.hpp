/*
 * Team Apah
 * SIUE Computer Science Senior Project
 *
 * dem_functions.cpp
 *
 * Contains functions for manipulating DEMs and finding
 * flow values.
 */

#ifndef CAHOKIA_DEM_FUNCTIONS_HEADER
#define CAHOKIA_DEM_FUNCTIONS_HEADER

// C Standard Library
#include <cstdlib>
#include <cstdio>
#include <cmath>

// Local
#include <dem.hpp>

/*
 * Fill dem pits to simplify model
 */
void dem_fill(dem_point_t * dem, dem_index_t w, dem_index_t h);

/*
 * Return the flow direction of each point in the DEM
 */
int * d8(dem_point_t * dem, dem_index_t w, dem_index_t h);

/*
 * Return a float matrix of the total flow at each point
 */
float * flow(int * dir, dem_index_t w, dem_index_t h);

/*
 * Misc Functions
 */
void dem_print(dem_point_t * dem, dem_index_t w, dem_index_t h);
void dem_dir_print(int * dir, dem_index_t w, dem_index_t h);

#endif
