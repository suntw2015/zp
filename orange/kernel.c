void main() {
    printLine();
    while (1) {
    };
}

void printLine() {
    char *video = (char*)0x8b00;
    int offset = 1440*10;
    for (int i=0;i<20;i++) {
        //一个字符占用4个字节,分别是rgb alpha
        *(video+offset+i*4+0) = 0xff;
        *(video+offset+i*4+1) = 0x00;
        *(video+offset+i*4+2) = 0x00;
        *(video+offset+i*4+2) = 0x00;
    }
}