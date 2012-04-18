#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>

extern int sprinter(char* res, char* format, ...);


int main ( void )
{
    fprintf(stderr, "\n**********\tINIT\t**********\n");
    
    char* str = malloc(200);
//    char* pattern = malloc(200);
    char* text1 = malloc(200);
    char* text2 = malloc(200);
    
    char test_char = 'X';
    char test_char2 = 'Z';
    int test_int = 52;
    int test_hex = 0xad1; // 2769 dec

//    memset(pattern, 0, 200);
    memset(text1, 0, 200);
    memset(text2, 0, 200);


//    pattern = "Test %s sprinter %s";
    text1 = "<of the>";
    text2 = "<complete.>";
    
    int ret = 0;

    fprintf(stderr, "sprinter(str, <pattern>, %s, %x, %c, %s)\n", text1, test_hex, test_char2, text2);

    //TODO alter here for more testes
    ret = sprinter(str, "Test %s sprinter %x %c, %s", text1, test_hex, test_char2, text2);


    fprintf(stderr, "\nres: \'%s\'\n", str);
    printf("Returned size: %d\n", ret);
    
    //MEMORY LEAK! TODO, spør armen? 
    
//    free(text1);
//    free(text2);
//    free(pattern);


    free(str);
    return 0;
}
