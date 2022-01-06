#include <stdio.h>
#include <string.h>
#include "fat.h"

int checkBootSector(FILE* fp) {
    fseek(fp, 0, 0);
    char boot[512];
    fread(boot, 512, 1, fp);
    return 0;
    if (boot[510] == 0x55) {
        printf("good boot\n");
        return 1;
    } else {
        printf("not boot\n");
        return 0;
    }
}

void getDir(FILE *fp) {
    fseek(fp, 512*19, 0);
    RootDirItem item;
    char name[15];
    char date[20];
    int i,j;

    do {
        fread(&item, sizeof(item), 1, fp);
        if (item.name[0] == '\0' || item.name[0] == 0xE5) {
            fclose(fp);
            break;
        }
        memset(name, 0, sizeof(name));
        for (i=0,j=0;i<11;i++) {
            if (item.name[i] != '\0') {
                name[j++] = item.name[i];
            }
        }

        memset(date, 0, sizeof(date));
        // Bits 0–4: Day of month, valid value range 1-31 inclusive.
        // Bits 5–8: Month of year, 1 = January, valid value range 1–12 inclusive.
        // Bits 9–15: Count of years from 1980, valid value range 0–127 inclusive (1980–2107).
        // Bits 0–4: 2-second count, valid value range 0–29 inclusive (0 – 58 seconds).
        // Bits 5–10: Minutes, valid value range 0–59 inclusive.
        // Bits 11–15: Hours, valid value range 0–23 inclusive.

        date[5] = date[8] = '-';
        sprintf(date, "%4d", (item.lastWriteDate >>8) + 1980);
        sprintf(date+5, "%2d", (item.lastWriteDate & 0x0000ff00) >> 4);
        sprintf(date+8, "%2d", item.lastWriteDate & 0x000000ff);
        date[10] = ' ';

        sprintf(
            date,
            "%4d-%2d-%2d %d:%d%d",
            (item.lastWriteDate >>8) + 1980,
            (item.lastWriteDate & 0x0000ff00) >> 4,
            item.lastWriteDate & 0x000000ff,
            item.lastWriteTime >> 10,
            (item.lastWriteTime & 0x77c) >> 4,
            item.lastWriteTime & 0x7c
        );


        printf("%s\t lastWriteTime:%s firstClust:%d\t FileSize:%d\t", name, date, item.fistClus, item.fileSize);

    } while (1);

    fclose(fp);
}

int main (int argc, char** argv)
{
    FILE* fp = fopen(argv[1], "r");
    
    if (!checkBootSector(fp)) {
        return 0;
    }

    getDir(fp);
    return 0;
}