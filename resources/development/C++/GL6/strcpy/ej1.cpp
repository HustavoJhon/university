// 1. Pide al usuario una cadena de texto y cópiala a otra variable usando strcpy(). Luego, imprime ambas cadenas y verifica que se haya copiado correctamente.
#include <iostream>
#include <cstring>
using namespace std;
int main() {
    char a[100], b[100];
    cin.getline(a,100);
    strcpy(b,a);
    cout<<a<<endl;
    cout<<b<<endl;
    return 0;
}
