#include <stdio.h>

typedef struct _twoIntStruct
{
  int intOne;
  int intTwo;
}twoIntsStruct;
void CWE457_Use_of_Uninitialized_Variable__struct_pointer_03_bad()
{
    twoIntsStruct * data;
    if(5==5)
    {
        ; /* empty statement needed for some flow variants */
    }
    if(5==5)
    {
        printf(data->intOne);
        printf(data->intTwo);
    }
}
int main(int argc, char * argv[])
{
    CWE457_Use_of_Uninitialized_Variable__struct_pointer_03_bad();
    return 0;
}

