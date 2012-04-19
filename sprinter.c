/*****************************************************************
    Test program for sprinter function with sprintf for comparison
    Oblig 2 inf2270, catod
*****************************************************************/
//#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int sprinter(char* res, char* format, ...);


int main ( void )
{
    //data
    char* str = malloc(200);
    char* fasit = malloc(200);

    char* text1 = malloc(200);
    char* text2 = malloc(200);
    
    char test_char = 'X';
    char test_char2 = 'Z';
    
    int tint1 = -54;
    int tint2 = 52;
    int test_hex = 0xdfff22; 
    
    memset(text1, 0, 200);
    memset(text2, 0, 200);

    text1 = "<of the>";
    text2 = "<complete.>";
    
    int ret = 0;
    int s_ret = 0;

    //info:
    fprintf(stderr, "\n**********\tINIT\t**********\n");
    fprintf(stderr, "TO TEST:\tsprinter(str, <pattern>, %d, %d, %s, %x, %c, %s)\n", tint1, tint2, text1, test_hex, test_char2, text2);

    //TEST:
    ret = sprinter(str, "Neg: %d Pos: %d Test %s sprinter %s. Char %c, Hex %x, Char %c", tint1, tint2, text1, text2, test_char, test_hex, test_char2);
    s_ret = sprintf(fasit, "Neg: %d Pos: %d Test %s sprinter %s. Char %c, Hex %x, Char %c", tint1, tint2, text1, text2, test_char, test_hex, test_char2);
    
    fprintf(stderr, "\nRESULT:\t\'%s\'\nSPRINT:\t\'%s\'\n", str, fasit);
    printf("Returned size: %d\n Correct size: %d\n", ret, s_ret);
    
    //MEMORY LEAK! TODO? 
    
//    free(text1);
//    free(text2);
//    free(pattern);


    free(str);
    return 0;
}
