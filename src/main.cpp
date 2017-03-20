/*
 * Team Apah
 * SIUE Computer Science Senior Project
 *
 * main.cpp
 */

/*
 * Headers
 */

// C Standard Library
#include <cstdio>
#include <cstdint>
#include <cstdlib>
#include <cmath>

// GDAL
#include <gdal_priv.h>
#include <cpl_conv.h> // for CPLMalloc()

// Local
#include <dem.hpp>
#include <dem_functions.hpp>

/*
 * Almost all of main is from GDAL's tutorial on reading data:
 * http://www.gdal.org/gdal_tutorial.html
 */
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
    
    return EXIT_SUCCESS;
}
