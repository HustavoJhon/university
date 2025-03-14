// 2. Verifica si una palabra está en la cadena usando strstr().
#include <iostream>
#include <cstring>
using namespace std;
int main() {
    char a[100], b[100];
    cin.getline(a,100);
    cin.getline(b,100);
    if(strstr(a,b)) cout<<"Si"<<endl; else cout<<"No"<<endl;
    return 0;
}
