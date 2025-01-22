#include <iostream>
#include <string>
using namespace std;

class Libro {
private:
  string titulo;
  string autor;
  int anioPublicacion;

public:
  void Registrar() {
    cout << "Ingrese titulo: ";
    getline(cin, titulo);
    cout << "Ingrese autor: ";
    getline(cin, autor);
    cout << "Ingrese año de publicación: ";
    cin >> anioPublicacion;
    cin.ignore(); // limpiar buffer
  }

  void Mostrar() {
    cout << "\n--- Información del Libro ---\n";
    cout << "Titulo: " << titulo << endl;
    cout << "Autor: " << autor << endl;
    cout << "Año: " << anioPublicacion << endl;
  }

  void EsNuevo() {
    int actual = 2025;
    if ((actual - anioPublicacion) < 5)
      cout << "Es Nuevo\n";
    else
      cout << "Es Antiguo\n";
  }
};

int main() {
  Libro libro1;
  libro1.Registrar();
  libro1.Mostrar();
  libro1.EsNuevo();
  return 0;
}
