// 5. Generar matriz identidad de n x n
#include <iostream>
using namespace std;

int main() {
  int n;
  cout << "Ingrese el tamano de la matriz identidad: ";
  cin >> n;

  int identidad[n][n];

  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      if (i == j) {
        identidad[i][j] = 1;
      } else {
        identidad[i][j] = 0;
      }
    }
  }

  cout << "Matriz identidad de " << n << "x" << n << ":" << endl;
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      cout << identidad[i][j] << " ";
    }
    cout << endl;
  }

  return 0;
}
