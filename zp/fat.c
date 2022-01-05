#include <stdio.h>

typedef struct {
    char name[8],
    char ext[3],
    char save[10],
    unsigned short lastWriteTime,
    unsigned short lastWriteDate,
    unsigned short fistClus,
    unsigned short fileSize,
} RootDirItem __attribute__ ((__packed__));

int main (int argc, char* argv)
{
    FILE* file = fopen(argv[1], "r");
    fseek(file, 512, 0);

    RootDirItem item;
    int i,end;
    do {
        fread(&item, sizeof(item), 1, file);

        end = 1;
        for (i=0;i<8;i++) {
            if (item->name[i] != 0) {
                end = 0;
                break;
            }
        }
        if (end) {
            break;
        }

        printf("%s.%s fistClust:%d, size:%d\n", item->name, item->ext, item->fistClus, item->fileSize);
    } while (1);
    return 0;
}