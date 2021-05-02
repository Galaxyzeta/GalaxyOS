typedef struct String {
	char* content;
	int len;
} String;

String newString(char* content);
void int_to_ascii(int n, char str[]);