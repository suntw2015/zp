typedef struct __attribute__ ((__packed__)) {

} BootSector;

typedef struct __attribute__ ((__packed__)) {

} FatEntry;

typedef struct __attribute__ ((__packed__)) {

} Fat;

typedef struct __attribute__ ((__packed__)) {
    char name[8];
    char ext[3];
    char atrr;
    char save[10];
    unsigned short lastWriteTime;
    unsigned short lastWriteDate;
    unsigned short fistClus;
    unsigned int fileSize;
} RootDirItem;