// 4. Determina si la subcadena es prefijo de la cadena.
#include <iostream>
#include <cstring>
using namespace std;
int main() {
    char a[100], b[100];
    cin.getline(a,100);
    cin.getline(b,100);
    if(strstr(a,b)==a) cout<<"Prefijo"<<endl; else cout<<"No"<<endl;
    return 0;
}
