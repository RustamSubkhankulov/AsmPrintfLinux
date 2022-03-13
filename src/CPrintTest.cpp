extern "C" int RsPrintC(const char*, ...);

int main()
{
    int var = RsPrintC("Hello %x, from %s %c\n", 3565, "Rustam", 33);

    RsPrintC("Return code is %d\n", var);

    return 0;
}