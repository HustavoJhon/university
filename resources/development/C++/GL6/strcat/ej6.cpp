// 6. Pide una cadena y un sufijo, concaténalos con strcat() y muestra el resultado.
#include <iostream>
#include <cstring>
using namespace std;
int main() {
    char a[100], sufijo[50];
    cin.getline(a,100);
    cin.getline(sufijo,50);
    strcat(a,sufijo);
    cout<<a<<endl;
    return 0;
}
