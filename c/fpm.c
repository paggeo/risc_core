/* Floating point multiplication */
#include <stdio.h>
#include <stdint.h>

#define S(a) (a>>31)
#define E(a) ((a>>23)&((1<<8)-1))
#define M(a) (a&((1<<23)-1))

void fp_print(int a){
    printf("    Sign : %d\n",S(a));
    printf("Exponent : %d\n",E(a));
    printf("Mantissa : %d\n",M(a));
}

int fp_add(int a, int b){
  return a+b;
}

int fp_mult(int a,int b){
  return a*b;
}

int main(){
  float a = 1.3;
  float b = 4.5;
  float c = a*b;
  
  int fa = *(uint32_t*)(&a);
  int fb = *(uint32_t*)(&b);
  int fc = *(uint64_t*)(&c);
  printf("%f * %f = %f\n",a,b,c);
  float d = a+b;
  printf("%f + %f = %f\n",a,b,d);
  printf("%x * %x = %x\n",fa,fb,fc);
  fp_print(fa);
  fp_print(fb);
  fp_print(fc);
  fc = fp_add(fa,fb);
  fp_print(fa);
  fp_print(fb);
  fp_print(fc);

}
