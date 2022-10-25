/* https://www.doc.ic.ac.uk/~eedwards/compsys/float/ */
/* https://www.h-schmidt.net/FloatConverter/IEEE754.html */
/* Floating point multiplication */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#define S(a) (a>>31)
#define E(a) ((a>>23)&((1<<8)-1))
#define M(a) (a&((1<<23)-1))
#define NormM(a) (a|(1<<23))
#define bias  127

void printBits(size_t const size, void const * const ptr)
{
    unsigned char *b = (unsigned char*) ptr;
    unsigned char byte;
    int i, j;
    
    for (i = size-1; i >= 0; i--) {
        for (j = 7; j >= 0; j--) {
            byte = (b[i] >> j) & 1;
            printf("%u", byte);
        }
    }
    puts("");
}

void fp_print(int a){
    printf("    Sign : %d\n",S(a));
    printf("Exponent : %d\n",E(a));
    printf("Mantissa : %d\n",M(a));
}

int fp_add(int a, int b){
  if (a == 0) return b;
  if (b == 0) return a;
  int sa, ea, ma , sb, eb, mb ;
  sa = S(a);
  ea = E(a) - bias;
  ma = M(a);
  sb = S(b);
  eb = E(b) - bias;
  /* mb = M(b)>>1 |(); */
  // check how much shifting is required
  int shifting = ea - eb;
  printf("shifting : %d\n",shifting);
  uint32_t ma_norm = NormM(ma);
  uint32_t mb_norm = NormM(mb);

  if (shifting == 0) {
      int mc_norm = ma_norm + mb_norm;
      int mc = M(mc_norm);
      printf("    Sign : %d\n",0);
      printf("Exponent : %d\n",ea+eb);
      printf("Mantissa : %d\n",mc);
  }
  else if (shifting > 0) {
      printf("ok\n");
      printBits(sizeof(mb_norm),&mb_norm);
      mb_norm = mb_norm >> shifting;
      printBits(sizeof(mb_norm),&mb_norm);
      int mc_norm = ma_norm + mb_norm;
      int mc = M(mc_norm);
      printf("    Sign : %d\n",0);
      printf("Exponent : %d\n",E(a));
      printf("Mantissa : %d\n",mc);

  }
  else if (shifting < 0) {
      ma_norm = ma_norm >>abs(shifting);
      printBits(sizeof(ma_norm),&ma_norm);
      int mc_norm = ma_norm + mb_norm;
      printBits(sizeof(mc_norm),&mc_norm);
      int mc = M(mc_norm);
      printf("    Sign : %d\n",0);
      printf("Exponent : %d\n",E(b));
      printf("Mantissa : %d\n",mc);
    
  }
  return a+b;
}

int fp_mult(int a,int b){
  return a*b;
}

int main(){
  float a = 9.75;
  float b = 0.5625;
  float c = a+b;
  
  int fa = *(uint32_t*)(&a);
  int fb = *(uint32_t*)(&b);
  int fc = *(uint64_t*)(&c);
  fp_print(fa);
  fp_print(fb);
  fp_print(fc);
  fc = fp_add(fa,fb);
  /* printf("%d\n",fc); */
}

