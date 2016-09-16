#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#define UNLINK unlink
#define FOPEN fopen

void CWE459_Incomplete_Cleanup__char_01_bad()
{
    {
        char * filename;
        char tmpl[] = "badXXXXXX";
        FILE *pFile;
        /* Establish that this is a temporary file and that it should be deleted */
        filename = mktemp(tmpl);
        if (filename != NULL)
        {
            pFile = FOPEN(filename, "w");
            if (pFile != NULL)
            {
                fprintf(pFile, "Temporary file");
                fclose(pFile);
                /* FLAW: We don't unlink */
            }
        }
    }
}




int main(int argc, char * argv[])
{
    /* seed randomness */
    srand( (unsigned)time(NULL) );

    
    CWE459_Incomplete_Cleanup__char_01_bad();

    return 0;
}

