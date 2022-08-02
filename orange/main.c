int main() {
    char *video = (char*)0xB8000;

    *video = 'X';

    while (1) {
    };

    return 0;
}
