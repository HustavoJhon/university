// 4. Pide nombre y apellido y concaténalos con un espacio en medio usando strcat().
#include <iostream>
#include <cstring>
using namespace std;
int main() {
    char nombre[50], apellido[50];
    cin.getline(nombre,50);
    cin.getline(apellido,50);
    strcat(nombre," ");
    strcat(nombre,apellido);
    cout<<nombre<<endl;
    return 0;
}
