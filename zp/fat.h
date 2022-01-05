typedef struct {

} BootSector;

typedef struct {

} FatEntry;

typedef struct {

} Fat;

typedef struct {
    char name[8],
    char ext[3],
    char save[10],
    unsigned short lastWriteTime,
    unsigned short lastWriteDate,
    unsigned short fistClus,
    unsigned short fileSize,
} RootDirItem __attribute__ ((__packed__));