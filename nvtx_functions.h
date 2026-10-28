#include "nvtx3/nvToolsExt.h"

/*
Color in ARGB format
uint32_t green = 0xFF00FF00;
uint32_t purple = 0xFF800080;
uint32_t yellow= = 0xFFFFFF00;
uint32_t blue = 0xFF0000FF;
uint32_t red = 0xFFFF0000;
uint32_t cyan = 0xFF00FFFF;
uint32_t magenta = 0xFFFF00FF;
uint32_t white = 0xFFFFFFFF;
uint32_t black = 0xFF000000;
uint32_t gray = 0xFF808080;
*/

// Create and push a range with custom color
nvtxRangeId_t pushNvtxRangeWithColor(const char* name, uint32_t color) {
    nvtxEventAttributes_t eventAttrib = {};
    eventAttrib.version = NVTX_VERSION;
    eventAttrib.size = NVTX_EVENT_ATTRIB_STRUCT_SIZE;
    eventAttrib.messageType = NVTX_MESSAGE_TYPE_ASCII;
    eventAttrib.message.ascii = name;
    eventAttrib.colorType = NVTX_COLOR_ARGB;
    eventAttrib.color = color;

    // Color definition can be directly set, but it would set the same color
    // for all NVTX functions and color argument is useless      
//    eventAttrib.color = COLOR_RED;

    nvtxRangeId_t rangeId = nvtxRangeStartEx(&eventAttrib);
    return rangeId;
}

// Pop the range
void popNvtxRange(nvtxRangeId_t rangeId) {
    nvtxRangeEnd(rangeId);
}

