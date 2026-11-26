// c/c++ libraries
#include <iostream>
#include <cstdlib>
#include <cstdio>
#include <cmath>

// custom functions
#include "../../nvtx_functions.h"

int main() {

    uint32_t green = 0x00FF00FF;
    nvtxRangeId_t flag_TOTAL_ID = pushNvtxRangeWithColor("Total time", green);

    // Sample points, limited by the max unsigned int
    constexpr unsigned int sample_points = 1<<25;

    unsigned int counter = 0;

    // Code-block to be tested with nsys
    uint32_t blue = 0xFF0000FF;

    // TODO: Generate sample_points random points (x,y) and check if they are
    //	     inside the quarter circle on the positive quadrant

    //	     rand() generates a pseude-random integer \in [0, RAND_MAX]
    //	     https://cplusplus.com/reference/cstdlib/rand/
    for (unsigned int i = 0; i < sample_points; i++) {
        float x = static_cast<float>(rand()) / RAND_MAX;
        float y = static_cast<float>(rand()) / RAND_MAX;

        // Check if the point is inside the quarter circle
        if (x*x + y*y < 1.0f)  ++counter;
    }

    // End of code-block

    // Calculate pi using ratio: points inside divided by total points
    double pi = 4.0f * static_cast<double>(counter) / sample_points;
    popNvtxRange(flag_TOTAL_ID);
    printf("%u sample points\n PI = %.15lf\n~PI = %.15lf\n", sample_points, pi, M_PI);
}

