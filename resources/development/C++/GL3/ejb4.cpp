// 4. Crear una matriz de 3x3 numeros enteros. Ingresar valores y mostrar el
// valor maximo y su posicion.
#include <iostream>
using namespace std;

int main() {
  int mat[3][3];
  int maxVal, fila = 0, col = 0;

  cout << "Ingrese los valores de la matriz 3x3:" << endl;
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      cout << "Valor [" << i << "][" << j << "]: ";
      cin >> mat[i][j];
      if (i == 0 && j == 0) {
        maxVal = mat[i][j];
      } else if (mat[i][j] > maxVal) {
        maxVal = mat[i][j];
        fila = i;
        col = j;
      }
    }
  }
  cout << "El valor maximo es: " << maxVal << " en la posicion [" << fila
       << "][" << col << "]" << endl;
  return 0;
}
