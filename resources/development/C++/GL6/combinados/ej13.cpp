// 13. Reemplaza una subcadena por otra y concatena " - Reemplazada" al final.
#include <iostream>
#include <cstring>
using namespace std;
int main() {
    char a[200], b[50], c[50];
    cin.getline(a,200);
    cin.getline(b,50);
    cin.getline(c,50);
    char *p=strstr(a,b);
    if(p) strcpy(p,c);
    strcat(a," - Reemplazada");
    cout<<a<<" "<<strlen(a)<<endl;
    return 0;
}
