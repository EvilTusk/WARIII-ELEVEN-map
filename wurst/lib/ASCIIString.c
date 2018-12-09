#include <stdio.h>
#include <string.h>

#define HEAD_STR "package ASCIIString\n\npublic string ASCII_CHARSET = \""

int main()
{
    FILE *f = fopen("ASCIIString.wurst", "w");
    fwrite(HEAD_STR, 1, strlen(HEAD_STR), f);
    for (int i = 1; i<=0xff; i++)
    {
        if (i == '\n')
            fwrite("\\n", 1, 2, f);
        else if (i == '\r')
            fwrite("\\r", 1, 2, f);
        else if (i == '\\')
            fwrite("\\\\", 1, 2, f);
        else if (i == '\"')
            fwrite("\\\"", 1, 2, f);
        else
            fwrite(&i, 1, 1, f);
    }
    fwrite("\"", 1, 1, f);
    fclose(f);
}