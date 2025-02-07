/*
Ejercicio 6: Registro de Vehículos y Verificación de Clásico

Crea un programa donde se cree un registro para almacenar la marca, modelo, año de fabricación, color y matrícula de n vehículos. El programa debe calcular la edad del vehículo y determinar si es un vehículo clásico (si tiene más de 25 años). Muestra los registros ingresados por pantalla junto con un mensaje indicando si el vehículo es clásico o no.
*/
#include <iostream>
using namespace std;

struct Vehiculo {
  string marca;
  string modelo;
  int anio;
  string color;
  string matricula;
  bool clasico;
};

int main() {
  int n;
  cout << "Ingrese la cantidad de vehiculos: ";
  cin >> n;
  Vehiculo v[n];
  int actual = 2025;
  for (int i = 0; i < n; i++) {
    cout << "\nVehiculo " << i + 1 << endl;
    cout << "Marca: ";
    cin >> v[i].marca;
    cout << "Modelo: ";
    cin >> v[i].modelo;
    cout << "Anio: ";
    cin >> v[i].anio;
    cout << "Color: ";
    cin >> v[i].color;
    cout << "Matricula: ";
    cin >> v[i].matricula;
    v[i].clasico = (actual - v[i].anio > 25);
  }
  cout << "\n--- Vehiculos ---\n";
  for (int i = 0; i < n; i++) {
    cout << v[i].marca << " " << v[i].modelo
         << " | Clasico: " << (v[i].clasico ? "Si" : "No") << endl;
  }
  return 0;
}
