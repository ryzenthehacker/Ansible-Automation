#include <stdio.h>

int main()
{
    int n, first, second,third, a,fourth,fifth;
    printf("Enter Fibonacci series upto which term");
    scanf("%d",&n);
    first=0; second=1;
    printf("%d %d",first,second);
    
    for(int i=0; i < n-2; i++){
        third=first+second;  
        printf(" %d",third);
        first = second;
        second = third;
        }
    return 0;
}
