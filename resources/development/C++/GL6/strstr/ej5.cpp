// 5. Reemplaza la primera aparición de una subcadena por otra.
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
    cout<<a<<endl;
    return 0;
}
