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
    char* tmp1 = text1; //For use in free
    char* tmp2 = text2;
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
    ret = sprinter(str, "Ett tegn: '%c'.", 'x');
    s_ret = sprintf(fasit, "Ett tegn: '%c'.", 'x');
    //RESULT:
    fprintf(stderr, "\nRESULT:\t\'%s\'\nSPRINT:\t\'%s\'\n", str, fasit);
    fprintf(stderr, "Returned size: %d\n Correct size: %d\n", ret, s_ret);

    //FAULT TEST:
/*    memset(str, 'a', 200); //to test that we zero-terminate properly
    fprintf(stderr, "FAULT: Here but no longer due to %%%%%%-, this will not be written \'%s\'\n", text1);
    ret = sprinter(str, "FAULT: Here but no longer due to %%%-, this will not be written %s", text1);
    //FAULT RESULT
    fprintf(stderr, "%s\nReturn value: %d\n", str, ret);*/

    int r1;
    int r2;

    char t1[400];
    char t2[400];
    
    r1 = sprinter(t1, "Ett tegn: '%c'.", 'x');
    r2 = sprintf(t2, "Ett tegn: '%c'.", 'x');
    printf("%s and %s\nres = %d, fasit = %d\n", t1, t2, r1, r2);
    
    r1 = sprinter(t1, "To tegn: '%c', '%c'.", 'x', 'y');
    r2 = sprintf(t2, "To tegn: '%c', '%c'.", 'x', 'y');
    printf("%s and %s\nres = %d, fasit = %d\n", t1, t2, r1, r2);

    r1 = sprinter(t1, "To streng: '%s', '%s'.", "streng 1", "streng 2");
    r2 = sprintf(t2, "To streng: '%s', '%s'.", "streng 1", "streng 2");
    printf("%s and %s\nres = %d, fasit = %d\n", t1, t2, r1, r2);

    /*r1 = sprinter(t1, "En streng ett tegn: '%s', '%c'.", "streng 1", 'x');
    r2 = sprintf(t2, "En streng: '%s', '%c:'.", "streng 1", 'x');
    printf("%s and %s\nres = %d, fasit = %d\n", t1, t2, r1, r2);
*/

    fprintf(stderr, "\nTermination\n");
    
//    free(text1); why not? Guess: pointer has made invalid by sprinter, hmm TODO 
//    free(text2);
    free(tmp1);
    free(tmp2);

    free(fasit);
    free(str);
    return 0;
}
