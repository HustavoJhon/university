// 6. Busca la primera palabra que comience con mayúscula.
#include <iostream>
#include <cstring>
#include <cctype>
using namespace std;
int main() {
    char a[200];
    cin.getline(a,200);
    for(char *p=a;*p;p++){
        if(isupper(*p)){cout<<p<<endl;break;}
    }
    return 0;
}
