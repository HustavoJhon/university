#include <iostream>
#include <string>
using namespace std;

class Libro {
private:
  string titulo;
  string autor;
  int AnioPublicacion;
  int NumeroPaginas;

public:
  void registrar(string _titulo, string _autor, int _AnioPublicacion,
                 int _NumeroPaginas) {
    titulo = _titulo;
    autor = _autor;
    AnioPublicacion = _AnioPublicacion;
    NumeroPaginas = _NumeroPaginas;
  }

  void mostrar() {
    cout << "Titulo: " << titulo << endl;
    cout << "Autor: " << autor << endl;
    cout << "Anio de Publicacion: " << AnioPublicacion << endl;
    cout << "Numero de Paginas: " << NumeroPaginas << endl;
    cout << "-------------------------------------" << endl;
  }

  void esNuevo() {
    if (AnioPublicacion >= 2020)
      cout << "El libro es nuevo" << endl;
    else
      cout << "El libro es antiguo" << endl;
    cout << "-------------------------------------" << endl;
  }
};

int main() {
  Libro libro1;
  libro1.registrar("El Quijote", "Miguel de Cervantes", 1605, 863);
  libro1.mostrar();
  libro1.esNuevo();

  return 0;
}
