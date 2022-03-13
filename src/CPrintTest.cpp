
void RsPrintC(const char*, ...);

int main()
{
    RsPrintC("Hello %x, from %s %c\n", 3565, "Rustam", 33);
    return 0;
}