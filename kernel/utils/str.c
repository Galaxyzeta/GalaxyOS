#include "./str.h"

String newString(char* content) {
	int i = -1;
	while(content[++i] != '\0');
	String str = {.content=content, .len=i};
	return str;
}

String reverse(String* str) {
	int i = 0;
	int halfLen = str->len / 2;
	while(i < halfLen) {
		char tmp = str->content[str->len-1-i];
		str->content[str->len-1-i] = str->content[i];
		str->content[i++] = tmp;
	}
}

/**
 * K&R implementation
 */
void int_to_ascii(int n, char str[]) {
    int i, sign;
    if ((sign = n) < 0) n = -n;
    i = 0;
    do {
        str[i++] = n % 10 + '0';
    } while ((n /= 10) > 0);

    if (sign < 0) str[i++] = '-';
    str[i] = '\0';

    /* TODO: implement "reverse" */
}
