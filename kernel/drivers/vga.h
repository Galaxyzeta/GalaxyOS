
#define VIDEO_MEMORY (char*)0xb8000
#define WHITE_ON_BLACK 0x0f

#define MAX_COLS 80
#define MAX_ROWS 25
#define MAX_OFFSET 80*25*2

#define REG_SCREEN_CTRL 0x3d4
#define REG_SCREEN_DATA 0x3d5

typedef char VGAPattern;

void printk(char* str);
void newLine();
void println(char* str);
void cls();