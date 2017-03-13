/*
 * Team Apah
 * SIUE Computer Science Senior Project
 * 
 * D8 Implementing Experiement using GDAL
 *
 * Almost all of main is from GDAL's tutorial on reading data:
 * http://www.gdal.org/gdal_tutorial.html
 */

// C Standard Library
#include <cstdio>
#include <cstdint>
#include <cstdlib>
#include <cfloat>
#include <cmath>

// GDAL
#include <gdal_priv.h>
#include <cpl_conv.h> // for CPLMalloc()

/*
 * DEM Types
 */
typedef uint32_t dem_index_t;
typedef float dem_point_t;
#define DEM_POINT_MAX FLT_MAX

/*
 * Implementation of D8 Algorithm (O'Callaghan and Mark, 1984)
 */

#define D8_PIT 0
#define D8_NE 1
#define D8_E 2
#define D8_SE 4
#define D8_S 8
#define D8_SW 16
#define D8_W 32
#define D8_NW 64
#define D8_N 128

const int D8_VALUES[9] = {
    D8_N, D8_E, D8_S, D8_W, D8_NE, D8_SE, D8_SW, D8_NW
};

const int D8_ITER_COL[8] = {
    0, 1, 0, -1, 1, 1, -1, -1
};

const int D8_ITER_ROW[8] = {
    -1, 0, 1, 0, -1, 1, 1, -1
};

void dem_print(dem_point_t * dem, dem_index_t w, dem_index_t h) {
    for (dem_index_t x = 0; x < w; x++){
        for (dem_index_t y = 0; y < h; y++){
            printf("%3.2f,", dem[w*y+x]);
        }
        printf("\n");
    }
}

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
                printf("Fill @ <%lu, %lu>\n", x, y);
                dem[current_i] = min;
            }
        }
    }
}

void d8(dem_point_t * dem, dem_index_t w, dem_index_t h) {
    dem_index_t size = w * h;

    // Flow Direction Matrix (DDIRN) Init
    int * dir = (int *) malloc(sizeof(int) * size);

    //// Square Root Matrix Init
    //dem_point_t * sqrt = (dem_point_t *) malloc(sizeof(dem_point_t) * size);
    //if (dir == NULL || sqrt == NULL) {
    //    fprintf(stderr, "Memory Error in D8!\n");
    //    exit(EXIT_FAILURE);
    //}

    //// Fill Squre Root Matrix
    //for (dem_index_t i = 0; i < size; i++){
    //    sqrt[i] = dem[i] * M_SQRT1_2;
    //}

    // Need to avoid edge
    dem_index_t _w = w - 1;
    dem_index_t _h = h - 1;
    dem_point_t point, min, cur;
    dem_index_t i, min_i;
    for (dem_index_t x = 1; x < _w; x++){
        for (dem_index_t y = 1; y < _h; y++){
            i = w * y + x;
            point = dem[i];

            // Find min
            min = point;
            min_i = 8;
            for (int v = 0; v < 4; v++) {
                cur = dem[w * (y + D8_ITER_ROW[v]) + (x + D8_ITER_COL[v])];
                if (cur < min) {
                    min = cur;
                    min_i = v;
                }
            }
            for (int v = 4; v < 8; v++) {
                //cur = sqrt[w * (y + D8_ITER_ROW[v]) + (x + D8_ITER_COL[v])];
                cur = dem[w * (y + D8_ITER_ROW[v]) + (x + D8_ITER_COL[v])];
                if (cur < min) {
                    min = cur;
                    min_i = v;
                }
            }

            if (min_i == 8) {
                dir[i] = D8_PIT;
            } else {
                dir[i] = D8_VALUES[min_i];
            }
        }
    }

    for (dem_index_t x = 1; x < _w; x++){
        for (dem_index_t y = 1; y < _h; y++){
            switch (dir[w * y + x]) {
                case D8_N:
                    printf(" ↑");
                    break;
                case D8_E:
                    printf(" →");
                    break;
                case D8_NE:
                    printf(" ↗");
                    break;
                case D8_SE:
                    printf(" ↘");
                    break;
                case D8_SW:
                    printf(" ↙");
                    break;
                case D8_NW:
                    printf(" ↖");
                    break;
                case D8_W:
                    printf(" ←");
                    break;
                case D8_S:
                    printf(" ↓");
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

int main(int argc, char *argv[]) {
    // Open File
    GDALDataset *poDataset;
    GDALAllRegister();

    if (argc != 2) {
        fprintf(stderr, "usage: %s FILEPATH\n", argv[0]);
        return EXIT_FAILURE;
    }
    
    poDataset = (GDALDataset *) GDALOpen(argv[1], GA_ReadOnly);
    if (poDataset == NULL) {
        fprintf(stderr, "Could not open file: \"%s\"\n", argv[1]);
        return EXIT_FAILURE;
    }

    // Print Information about the file's contents
    double adfGeoTransform[6];

    printf(
        "Driver: %s/%s\n",
        poDataset->GetDriver()->GetDescription(),
        poDataset->GetDriver()->GetMetadataItem(GDAL_DMD_LONGNAME)
    );

    printf(
        "Size is %dx%dx%d\n",
        poDataset->GetRasterXSize(),
        poDataset->GetRasterYSize(),
        poDataset->GetRasterCount()
    );

    if (poDataset->GetProjectionRef() != NULL) {
        printf("Projection is `%s'\n", poDataset->GetProjectionRef());
    }

    if (poDataset->GetGeoTransform(adfGeoTransform) == CE_None) {
        printf("Origin = (%.6f,%.6f)\n", adfGeoTransform[0], adfGeoTransform[3]);
        printf("Pixel Size = (%.6f,%.6f)\n", adfGeoTransform[1], adfGeoTransform[5]);
    }

    // Prepare to extract data from the file
    GDALRasterBand  *poBand;
    int nBlockXSize, nBlockYSize;
    int bGotMin, bGotMax;
    double adfMinMax[2];
    poBand = poDataset->GetRasterBand(1);
    poBand->GetBlockSize( &nBlockXSize, &nBlockYSize );
    printf( "Block=%dx%d Type=%s, ColorInterp=%s\n",
            nBlockXSize, nBlockYSize,
            GDALGetDataTypeName(poBand->GetRasterDataType()),
            GDALGetColorInterpretationName(
                poBand->GetColorInterpretation()) );
    adfMinMax[0] = poBand->GetMinimum( &bGotMin );
    adfMinMax[1] = poBand->GetMaximum( &bGotMax );
    if( ! (bGotMin && bGotMax) )
        GDALComputeRasterMinMax((GDALRasterBandH)poBand, TRUE, adfMinMax);
    printf( "Min=%.3fd, Max=%.3f\n", adfMinMax[0], adfMinMax[1] );
    if( poBand->GetOverviewCount() > 0 )
        printf( "Band has %d overviews.\n", poBand->GetOverviewCount() );
    if( poBand->GetColorTable() != NULL )
        printf( "Band has a color table with %d entries.\n",
                 poBand->GetColorTable()->GetColorEntryCount() );

    // Extract the data
    dem_point_t * matrix;
    dem_index_t x = 345;
    dem_index_t y = 400;
    dem_index_t w = 20;
    dem_index_t h = 20;
    matrix = (dem_point_t *) CPLMalloc(sizeof(float) * w * h);

    // Documentation for this method is located here:
    // http://www.gdal.org/classGDALDataset.html#a80d005ed10aefafa8a55dc539c2f69da
    poBand->RasterIO(
        GF_Read, // Read/Write Flag (GDALRWFlag)
        x, y, // Position
        w, h, // Size
        matrix, // Destination of data
        w, h, // Buffer Size
        GDT_Float32, // Element Type
        0, // nBandCount (Which Band?)
        0 // panBandCount (?)
    );

    // Process the data
    dem_fill(matrix, w, h);
    d8(matrix, w, h);
    dem_print(matrix, w, h);
    
    return EXIT_SUCCESS;
}
