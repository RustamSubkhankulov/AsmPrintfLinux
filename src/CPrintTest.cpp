#include <stdio.h>

extern "C" int RsPrintC(const char*, ...);

int main()
{
    int var = RsPrintC("Hello %x, from %s %c\n", 3565, "Rustam", 33);

    printf("Return code is %d and %d %d %d %d %d %d\n", var, 1, 2, 3, 4, 5, 6, 7, 8);

    RsPrintC("Return code is %d and %d %d %d %d %d %d\n", var, 1, 2, 3, 4, 5, 6, 7, 8);

    return 0;
}