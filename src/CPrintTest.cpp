extern "C" int RsPrintC(const char*, ...);

int main()
{
    int var = RsPrintC("Hello %x, from %s %c\n", 3565, "Rustam", 33);

    RsPrintC("Return code is %d and %d %d %d %d %d %d\n I %s %x %d%%%c%b\n", var, 1, 2, 3, 4, 5, 6, "love", 3802, 100, 33, 15);

    return 0;
}