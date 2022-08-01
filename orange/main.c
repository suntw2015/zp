int main() {
    char *video = (char*)0xb8000;
    char *str = "main function";
    for (int i=0;i<10;i++) {
 	*video = str[i];
	video++;
    }

    while (1) {
    };

    return 0;
}
