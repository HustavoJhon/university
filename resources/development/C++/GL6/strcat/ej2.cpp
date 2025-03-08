// 2. Concatena dos cadenas y muestra la longitud con strlen().
#include <iostream>
#include <cstring>
using namespace std;
int main() {
    char a[100], b[100];
    cin.getline(a,100);
    cin.getline(b,100);
    strcat(a,b);
    cout<<strlen(a)<<endl;
    return 0;
}
