// 4. Suma de la diagonal secundaria de una matriz 5x5
#include <iostream>
using namespace std;

int main() {
  int mat[5][5], suma = 0;

  cout << "Ingrese los valores de la matriz 5x5:" << endl;
  for (int i = 0; i < 5; i++) {
    for (int j = 0; j < 5; j++) {
      cout << "Valor [" << i << "][" << j << "]: ";
      cin >> mat[i][j];
    }
  }

  for (int i = 0; i < 5; i++) {
    suma += mat[i][4 - i];
  }

  cout << "La suma de la diagonal secundaria es: " << suma << endl;
  return 0;
}
