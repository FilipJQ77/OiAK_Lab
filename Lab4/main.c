#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>


const int NUMBER_AMOUNT=8192;
const int VECTOR_SIZE=2048; // = NUMBER_AMOUNT / 4
bool simd=true;

struct vector {
  float x1;
  float x2;
  float x3;
  float x4;
};

struct vector addSIMD(struct vector v1, struct vector v2){
  struct vector v3;
  asm(
    "movups %[v1], %%xmm0\n\t"
    "movups %[v2], %%xmm1\n\t"
    "addps %%xmm1, %%xmm0\n\t"
    "movups %%xmm0, %[v3]\n\t"
    : [v3] "=rm" (v3)
    : [v1] "rm" (v1), [v2] "rm" (v2)
  );
  return v3;
}

struct vector subSIMD(struct vector v1, struct vector v2){
  struct vector v3;
  asm(
    "movups %[v1], %%xmm0\n\t"
    "movups %[v2], %%xmm1\n\t"
    "subps %%xmm1, %%xmm0\n\t"
    "movups %%xmm0, %[v3]\n\t"
    : [v3] "=rm" (v3)
    : [v1] "rm" (v1), [v2] "rm" (v2)
  );
  return v3;
}

struct vector multSIMD(struct vector v1, struct vector v2){
  struct vector v3;
  asm(
    "movups %[v1], %%xmm0\n\t"
    "movups %[v2], %%xmm1\n\t"
    "mulps %%xmm1, %%xmm0\n\t"
    "movups %%xmm0, %[v3]\n\t"
    : [v3] "=rm" (v3)
    : [v1] "rm" (v1), [v2] "rm" (v2)
  );
  return v3;
}

struct vector divSIMD(struct vector v1, struct vector v2){
  struct vector v3;
  asm(
    "movups %[v1], %%xmm0\n\t"
    "movups %[v2], %%xmm1\n\t"
    "divps %%xmm1, %%xmm0\n\t"
    "movups %%xmm0, %[v3]\n\t"
    : [v3] "=rm" (v3)
    : [v1] "rm" (v1), [v2] "rm" (v2)
  );
  return v3;
}

float addSISD(float a, float b){
  float c;
  asm(
    "fld %[a]\n\t"
    "fadd %[b]\n\t"
    "fstp %[c]\n\t"
    : [c] "=m" (c)
    : [a] "rm" (a), [b] "rm" (b)
  );
  return c;
}

float subSISD(float a, float b){
  float c;
  asm(
    "fld %[a]\n\t"
    "fsub %[b]\n\t"
    "fstp %[c]\n\t"
    : [c] "=m" (c)
    : [a] "rm" (a), [b] "rm" (b)
  );
  return c;
}

float multSISD(float a, float b){
  float c;
  asm(
    "fld %[a]\n\t"
    "fmul %[b]\n\t"
    "fstp %[c]\n\t"
    : [c] "=m" (c)
    : [a] "rm" (a), [b] "rm" (b)
  );
  return c;
}

float divSISD(float a, float b){
  float c;
  asm(
    "fld %[a]\n\t"
    "fdiv %[b]\n\t"
    "fstp %[c]\n\t"
    : [c] "=m" (c)
    : [a] "rm" (a), [b] "rm" (b)
  );
  return c;
}

double measureTimeSIMD(struct vector (*func)(struct vector, struct vector), struct vector v1, struct vector v2){
  struct vector v3;
  clock_t start, end;
  start=clock();
  v3=func(v1,v2);
  end=clock();
  return ((double)end-start)/CLOCKS_PER_SEC;
}

double measureTimeSISD(float (*func)(float, float), float a, float b){
  float c;
  clock_t start, end;
  start=clock();
  c=func(a,b);
  end=clock();
  return ((double)end-start)/CLOCKS_PER_SEC;
}

// generuje losowa liczbe float w zakresie [-1 milion, 1 milion]
float randomFloat(){
  return (float)rand() * (2000000) / (float)RAND_MAX - 1000000;
}

void vectorRandomNumbers(struct vector* v){
  v->x1=randomFloat();
  v->x2=randomFloat();
  v->x3=randomFloat();
  v->x4=randomFloat();
}

int main(){
  srand(time(NULL));
  double averageTimeAdd=0;
  double averageTimeSub=0;
  double averageTimeMult=0;
  double averageTimeDiv=0;

  if(simd){
    struct vector v1[VECTOR_SIZE];
    struct vector v2[VECTOR_SIZE];
    for (int i = 0; i < 10; ++i) {
      for (int j = 0; j < VECTOR_SIZE; ++j) {
        vectorRandomNumbers(&v1[j]);
        vectorRandomNumbers(&v2[j]);
        averageTimeAdd+=measureTimeSIMD(addSIMD,v1[j],v2[j]);
        averageTimeSub+=measureTimeSIMD(subSIMD,v1[j],v2[j]);
        averageTimeMult+=measureTimeSIMD(multSIMD,v1[j],v2[j]);
        averageTimeDiv+=measureTimeSIMD(divSIMD,v1[j],v2[j]);
      }
    }
  }
  else{
    float a1[NUMBER_AMOUNT];
    float a2[NUMBER_AMOUNT];
    for (int i = 0; i < 10; ++i) {
      for (int j = 0; j < NUMBER_AMOUNT; ++j) {
        a1[j]=randomFloat();
        a2[j]=randomFloat();
        averageTimeAdd+=measureTimeSISD(addSISD,a1[j],a2[j]);
        averageTimeSub+=measureTimeSISD(subSISD,a1[j],a2[j]);
        averageTimeMult+=measureTimeSISD(multSISD,a1[j],a2[j]);
        averageTimeDiv+=measureTimeSISD(divSISD,a1[j],a2[j]);
      }
    }
  }
  averageTimeAdd/=10;
  averageTimeSub/=10;
  averageTimeMult/=10;
  averageTimeDiv/=10;
  FILE *file;
  file = fopen("output.txt","a");
  fprintf(file, "Typ obliczen: ");
  if(simd){
    fprintf(file, "SIMD\nLiczba liczb: %d\n", VECTOR_SIZE*4);
  } else {
    fprintf(file, "SISD\nLiczba liczb: %d\n", NUMBER_AMOUNT);
  }
  fprintf(file, "Sredni czas [s]:\n+ %f\n- %f\n* %f\n/ %f\n", averageTimeAdd, averageTimeSub, averageTimeMult, averageTimeDiv);
  return 0;
}
