int main(void)
{
  int *x;
  x = malloc(10);
  free(x);
  x = 10;
  return 0;
}

