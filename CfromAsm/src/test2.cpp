#include "stdio.h"
#include "stdarg.h"

//===============================================

extern "C" int mysub (int a, int b)
{
    return a - b;
}

//===============================================

extern "C" int kinda_printf(const char* format, ...)
{
    va_list args;

    va_start(args, format);
    int res = vprintf(format, args);

    va_end(args);

    return res;
}