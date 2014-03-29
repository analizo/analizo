#define BUFFERSIZE 256

int division_by_zero()
{
  int y = 5/0;
  return y;
}

dead_assignment()
{
  int *x;

  x = malloc(sizeof(int)*10);
  free(x);
  x = 10;
}

int main(int argc, char** argv)
{
  char *buf;
  int value;
  buf = (char*) malloc(sizeof(char)*BUFFERSIZE);
  strcpy(buf, argv[1]);

  value = division_by_zero();
  dead_assignment();
  return 0;
}
