/*
Ejercicio 4: Registro de Clientes

Crea un programa donde se cree un registro para almacenar el nombre completo, dirección, teléfono y correo electrónico de n clientes. Luego, debe mostrar los registros ingresados y si el correo de cada cliente es válido o no.
*/
#include <iostream>
using namespace std;

struct Cliente {
  string nombre;
  string direccion;
  string telefono;
  string correo;
};

bool validarCorreo(string correo) { return correo.find('@') != string::npos; }

int main() {
  int n;
  cout << "Ingrese la cantidad de clientes: ";
  cin >> n;
  Cliente c[n];
  for (int i = 0; i < n; i++) {
    cout << "\nCliente " << i + 1 << endl;
    cout << "Nombre: ";
    cin >> c[i].nombre;
    cout << "Direccion: ";
    cin >> c[i].direccion;
    cout << "Telefono: ";
    cin >> c[i].telefono;
    cout << "Correo: ";
    cin >> c[i].correo;
  }
  cout << "\n--- Clientes ---\n";
  for (int i = 0; i < n; i++) {
    cout << c[i].nombre << " | " << c[i].correo;
    if (validarCorreo(c[i].correo))
      cout << " (Valido)" << endl;
    else
      cout << " (No valido)" << endl;
  }
  return 0;
}
