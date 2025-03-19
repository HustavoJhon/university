// 12. Pide cadena y subcadena, si aparece concaténala al final y muestra la nueva cadena y su longitud.
#include <iostream>
#include <cstring>
using namespace std;
int main() {
    char a[200], b[100];
    cin.getline(a,200);
    cin.getline(b,100);
    if(strstr(a,b)) strcat(a,b);
    cout<<a<<" "<<strlen(a)<<endl;
    return 0;
}
