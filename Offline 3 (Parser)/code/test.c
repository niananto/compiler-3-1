#include<stdio.h>

int foo(int a);
int foo(int b);

int main() {
    float a = 10;
    int b = 1.2;

    printf("%f\n", a);
    printf("%d\n", b);
}