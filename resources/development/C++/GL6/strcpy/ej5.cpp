// 5. Crea una función que copie una cadena a otra usando strcpy().
#include <iostream>
#include <cstring>
using namespace std;
void copiar(char *d,char *s){strcpy(d,s);}
int main() {
    char a[100], b[100];
    cin.getline(a,100);
    copiar(b,a);
    cout<<b<<endl;
    return 0;
}
