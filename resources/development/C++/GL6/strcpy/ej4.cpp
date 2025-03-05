// 4. Modifica el anterior para que la cadena copiada sea convertida a mayúsculas antes de copiarla en la segunda cadena.
#include <iostream>
#include <cstring>
#include <cctype>
using namespace std;
int main() {
    char a[100], b[100], temp[100];
    int i,j;
    cin.getline(a,100);
    int n=strlen(a);
    for(i=0,j=n-1;i<n;i++,j--) temp[i]=toupper(a[j]);
    temp[n]='\0';
    strcpy(b,temp);
    cout<<b<<endl;
    return 0;
}
