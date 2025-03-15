// 3. Cuenta cuántas veces aparece una subcadena en la cadena.
#include <iostream>
#include <cstring>
using namespace std;
int main() {
    char a[200], b[50];
    cin.getline(a,200);
    cin.getline(b,50);
    int c=0;
    char *p=a;
    while((p=strstr(p,b))!=NULL){c++;p++;}
    cout<<c<<endl;
    return 0;
}
