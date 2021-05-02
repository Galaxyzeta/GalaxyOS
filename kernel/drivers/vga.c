#include "../utils/str.h"
#include "./vga.h"
#include "./ports.h"

//#########################################
//			Private Declaration
//#########################################

int coord2offset(int row, int col);
void printAt(int row, int col, char c, VGAPattern color);
void printAtCursor(char c, VGAPattern color);
int offset2ctxrow(int offset);
int offset2ctxcol(int offset);
int getCursorOffset();
int setCursorOffset(int offset);
int moveCursorForward();
int moveCursorBackward();

//#########################################
//			Public Implementation
//#########################################

char* vga = VIDEO_MEMORY;

void printk(char* str) {
	String s = newString(str);
	for(int i=0; i<s.len; i++) {
		if(str[i] == '\n') {
			newLine();
			continue;
		}
		printAtCursor(str[i], WHITE_ON_BLACK);
		moveCursorForward();
	}
}

void println(char* str) {
	printk(str);
	newLine();
}

void newLine() {
	int offset = getCursorOffset();
	int row = offset2ctxrow(offset);
	setCursorOffset(coord2offset(row+1>=MAX_ROWS?0:row+1, 0));
}

void cls() {
	setCursorOffset(0);
	int i=0, j=0;
	while(i<MAX_ROWS) {
		while(j<MAX_COLS) {
			printAt(i, j++, '.', WHITE_ON_BLACK);
		}
		j = 0;
		i++;
	}
}

//#########################################
//			Private Implementation
//#########################################

int coord2offset(int row, int col) {return (row * MAX_COLS * 2 + col);}

int offset2ctxrow(int offset) {return offset / (MAX_COLS*2);}

int offset2ctxcol(int offset) {return offset % (MAX_COLS*2);}

void printAt(int row, int col, char c, VGAPattern color) {
	int offset = coord2offset(row, col*2);
	vga[offset] = c;
	vga[offset+1] = color;
}

void printAtCursor(char c, VGAPattern color) {
	int offset = getCursorOffset();
	vga[offset] = c;
	vga[offset+1] = color;
}

int getCursorOffset() {
	port_byte_out(REG_SCREEN_CTRL, 14);
	int offset = port_byte_in(REG_SCREEN_DATA) << 8;
	port_byte_out(REG_SCREEN_CTRL, 15);
	offset += port_byte_in(REG_SCREEN_DATA) & 0x00ff;
	return 2 * offset;
}

int setCursorOffset(int offset) {
	offset /= 2;
	port_byte_out(REG_SCREEN_CTRL, 14);
	port_byte_out(REG_SCREEN_DATA, (unsigned char)(offset >> 8));
	port_byte_out(REG_SCREEN_CTRL, 15);
	port_byte_out(REG_SCREEN_DATA, (unsigned char)(offset & 0x00ff));
}

int moveCursorForward() {
	int offset = getCursorOffset() + 2;
	if(offset >= MAX_OFFSET) {
		setCursorOffset(0);
	}
	setCursorOffset(offset);
}


int moveCursorBackward() {
	int offset = getCursorOffset() - 2;
	if(offset < 0) {
		setCursorOffset(MAX_OFFSET-1);
	}
	setCursorOffset(offset);
}