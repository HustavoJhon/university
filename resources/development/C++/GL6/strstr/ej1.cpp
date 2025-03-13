// 1. Recibe una cadena y una subcadena, muestra la posición donde se encuentra usando strstr().
#include <iostream>
#include <cstring>
using namespace std;
int main() {
    char a[100], b[100];
    cin.getline(a,100);
    cin.getline(b,100);
    char *p=strstr(a,b);
    if(p) cout<<p-a<<endl; else cout<<"No"<<endl;
    return 0;
}
