void main() {
    char* video_memory = (char*)0xb8000;
    
    // Clear the screen
    for (int i = 0; i < 80 * 25 * 2; i += 2) {
        video_memory[i] = ' ';
        video_memory[i + 1] = 0x07; // White on black
    }

    const char* str = "Hello from C Kernel!";
    
    for (int i = 0; str[i] != '\0'; i++) {
        video_memory[i * 2] = str[i];
        video_memory[i * 2 + 1] = 0x07; // White on black
    }
}
