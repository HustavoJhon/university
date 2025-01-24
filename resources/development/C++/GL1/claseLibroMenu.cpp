#include <iostream>
using namespace std;

class Libro {
private:
  string titulo;
  string autor;
  bool disponible;

public:
  void RegistrarLibro() {
    cout << "Titulo: ";
    getline(cin, titulo);
    cout << "Autor: ";
    getline(cin, autor);
    disponible = true;
  }
  void MostrarInformacion() {
    cout << "Titulo: " << titulo << "\nAutor: " << autor
         << "\nDisponible: " << (disponible ? "Si" : "No") << endl;
  }
  void PrestarLibro() { disponible = false; }
  void DevolverLibro() { disponible = true; }
};

int main() {
  Libro l;
  int op;
  do {
    cout << "\n1. Registrar\n2. Mostrar\n3. Prestar\n4. Devolver\n5. "
            "Salir\nOpcion: ";
    cin >> op;
    cin.ignore();
    switch (op) {
    case 1:
      l.RegistrarLibro();
      break;
    case 2:
      l.MostrarInformacion();
      break;
    case 3:
      l.PrestarLibro();
      break;
    case 4:
      l.DevolverLibro();
      break;
    }
  } while (op != 5);
  return 0;
}
