// 3. Escribe un programa que reciba una cadena, la invierta y la copie en otra con strcpy().
#include <iostream>
#include <cstring>
using namespace std;
int main() {
    char a[100], b[100], temp[100];
    int i,j;
    cin.getline(a,100);
    int n=strlen(a);
    for(i=0,j=n-1;i<n;i++,j--) temp[i]=a[j];
    temp[n]='\0';
    strcpy(b,temp);
    cout<<b<<endl;
    return 0;
}
