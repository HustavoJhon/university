// 2. Escribe un programa que copie una cadena en otra y luego le agregue una subcadena al final usando strcpy() y strcat().
#include <iostream>
#include <cstring>
using namespace std;
int main() {
    char a[100], b[200];
    cin.getline(a,100);
    strcpy(b,a);
    strcat(b," extra");
    cout<<b<<endl;
    return 0;
}
