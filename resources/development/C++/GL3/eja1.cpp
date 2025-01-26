// 1. Ingresar varias matrices m x n y calcular la suma total
#include <iostream>
using namespace std;

int main() {
  int m, n, cant;
  cout << "Ingrese la cantidad de matrices a sumar: ";
  cin >> cant;
  cout << "Ingrese el numero de filas (m): ";
  cin >> m;
  cout << "Ingrese el numero de columnas (n): ";
  cin >> n;

  int suma[m][n];
  for (int i = 0; i < m; i++) {
    for (int j = 0; j < n; j++) {
      suma[i][j] = 0;
    }
  }

  for (int k = 0; k < cant; k++) {
    cout << "Ingrese los valores de la matriz " << k + 1 << ":" << endl;
    for (int i = 0; i < m; i++) {
      for (int j = 0; j < n; j++) {
        int valor;
        cout << "Valor [" << i << "][" << j << "]: ";
        cin >> valor;
        suma[i][j] += valor;
      }
    }
  }

  cout << "Matriz suma total:" << endl;
  for (int i = 0; i < m; i++) {
    for (int j = 0; j < n; j++) {
      cout << suma[i][j] << " ";
    }
    cout << endl;
  }

  return 0;
}
