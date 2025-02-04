/*
Ejercicio 3: Registro de Libros y Descuento

Crea un programa donde se cree un registro para almacenar el título, autor, año de publicación y precio de n libros. Si el libro tiene más de 20 años, se debe aplicar un descuento del 10% sobre el precio y mostrar el precio con descuento. El programa debe mostrar los registros ingresados por pantalla junto con el precio final de cada libro (con o sin descuento).
*/
#include <iostream>
using namespace std;

struct Libro {
  string titulo;
  string autor;
  int anio;
  float precio;
  float precioFinal;
};

int main() {
  int n;
  cout << "Ingrese la cantidad de libros: ";
  cin >> n;
  Libro l[n];
  int actual = 2025;
  for (int i = 0; i < n; i++) {
    cout << "\nLibro " << i + 1 << endl;
    cout << "Titulo: ";
    cin >> l[i].titulo;
    cout << "Autor: ";
    cin >> l[i].autor;
    cout << "Anio: ";
    cin >> l[i].anio;
    cout << "Precio: ";
    cin >> l[i].precio;
    if (actual - l[i].anio > 20)
      l[i].precioFinal = l[i].precio * 0.9;
    else
      l[i].precioFinal = l[i].precio;
  }
  cout << "\n--- Libros ---\n";
  for (int i = 0; i < n; i++) {
    cout << l[i].titulo << " | Autor: " << l[i].autor
         << " | Precio Final: " << l[i].precioFinal << endl;
  }
  return 0;
}
