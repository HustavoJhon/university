#include <iostream>
#include <string>
using namespace std;

class Libro {
private:
  string titulo;
  string autor;
  bool disponible;

public:
  Libro() { disponible = true; }

  void RegistrarLibro() {
    cout << "Ingrese titulo: ";
    getline(cin, titulo);
    cout << "Ingrese autor: ";
    getline(cin, autor);
    disponible = true;
  }

  void MostrarInformacion() {
    cout << "\n--- Información del Libro ---\n";
    cout << "Titulo: " << titulo << endl;
    cout << "Autor: " << autor << endl;
    cout << "Disponible: " << (disponible ? "Si" : "No") << endl;
  }

  void PrestarLibro() {
    if (disponible) {
      disponible = false;
      cout << "El libro ha sido prestado.\n";
    } else {
      cout << "El libro ya está prestado.\n";
    }
  }

  void DevolverLibro() {
    disponible = true;
    cout << "El libro ha sido devuelto.\n";
  }
};

int main() {
  Libro libro;
  int opcion;
  do {
    cout << "\n--- Menú ---\n";
    cout << "1. Registrar libro\n";
    cout << "2. Mostrar informacion\n";
    cout << "3. Prestar libro\n";
    cout << "4. Devolver libro\n";
    cout << "5. Salir\n";
    cout << "Opcion: ";
    cin >> opcion;
    cin.ignore();

    switch (opcion) {
    case 1:
      libro.RegistrarLibro();
      break;
    case 2:
      libro.MostrarInformacion();
      break;
    case 3:
      libro.PrestarLibro();
      break;
    case 4:
      libro.DevolverLibro();
      break;
    }
  } while (opcion != 5);

  return 0;
}
