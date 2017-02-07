# Brute force watershed algorithm

#import gdal
#f = gdal.Open('../dem/elev48i0100a.tif')

import sys

import numpy as np
from scipy.misc import imread, imsave

output = sys.argv[4]
image = imread(sys.argv[1], True)
print(image.shape)
result = np.zeros(image.shape, np.int8)

start_x = int(sys.argv[2])
start_y = int(sys.argv[3])
result[start_x, start_y] = 1
stack = [(start_x, start_y)]

select = [
    (-1, -1), (0, -1), (1, -1),
    (-1, 0), (1, 0),
    (-1, 1), (0, 1), (1, 1),
    #(-2, -2), (-2, -1), (-2, 0), (-2, 1), (-2, 2),
    #(-1, -2), (0, -2), (1, -2),
    #(-1, 2), (0, 2), (1, 2),
    #(2, -2), (2, -1), (2, 0), (2, 1), (2, 2),
]

mx = image.shape[0]
my = image.shape[1]
n = 0
N = 1

while stack:
    n += 1
    this_point = stack.pop()
    this_value = image[this_point]
    for i in select:
        index = this_point[0] + i[0], this_point[1] + i[1]
        
        # Out of Bounds
        if not (0 <= index[0] < mx and 0 <= index[1] < my):
            continue

        # Lower than current point and not ever in stack
        value = image[index]
        if all([
            result[index] == 0,
            value >= this_value
        ]):
            N += 1
            result[index] = 1
            stack.append(index)
            print('n:', n, 'N:', N, 'Stack:', len(stack))

# Write Result to file
imsave(output, result)
