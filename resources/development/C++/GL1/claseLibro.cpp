#include <iostream>
using namespace std;

class Libro {
private:
  string titulo;
  string autor;
  int anio;

public:
  void Registrar() {
    cout << "Titulo: ";
    getline(cin, titulo);
    cout << "Autor: ";
    getline(cin, autor);
    cout << "Anio de publicacion: ";
    cin >> anio;
    cin.ignore();
  }
  void Mostrar() {
    cout << "Titulo: " << titulo << "\nAutor: " << autor << "\nAnio: " << anio
         << endl;
  }
  void EsNuevo() {
    int actual = 2025;
    if (actual - anio < 5)
      cout << "Es Nuevo" << endl;
    else
      cout << "Es Antiguo" << endl;
  }
};

int main() {
  Libro libro;
  libro.Registrar();
  libro.Mostrar();
  libro.EsNuevo();
  return 0;
}
