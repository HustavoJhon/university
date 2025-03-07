// 1. Crea un programa que pida dos cadenas y las concatene usando strcat().
#include <iostream>
#include <cstring>
using namespace std;
int main() {
    char a[100], b[100];
    cin.getline(a,100);
    cin.getline(b,100);
    strcat(a,b);
    cout<<a<<endl;
    return 0;
}
