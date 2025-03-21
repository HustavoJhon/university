// 14. Genera una URL a partir de un dominio y extensión, reemplaza "http" por "https://" si existe.
#include <iostream>
#include <cstring>
using namespace std;
int main() {
    char dominio[100], ext[20], url[200];
    cin.getline(dominio,100);
    cin.getline(ext,20);
    strcpy(url,dominio);
    if(strstr(url,"http")) strcpy(url,"https://");
    strcat(url,ext);
    cout<<url<<" "<<strlen(url)<<endl;
    return 0;
}
