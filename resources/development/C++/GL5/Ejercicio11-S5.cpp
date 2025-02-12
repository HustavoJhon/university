/*
Ejercicio 11: Registro de Estudiantes y Dirección 

Crea un programa donde se cree un registro para almacenar el nombre del estudiante, código del estudiante, 
edad y promedio de calificaciones de n estudiantes. Además, dentro de este registro debe haber un registro 
anidado para almacenar la dirección del estudiante, que contenga:
    • Calle
    • Ciudad
    • Código postal
El programa debe calcular el promedio de las edades de los estudiantes y mostrar los registros ingresados, 
junto con el promedio de edad.
*/

#include <iostream>
using namespace std;

struct Direccion {
    string calle;
    string ciudad;
    string codigoPostal;
};

struct Estudiante {
    string nombre;
    int codigo;
    int edad;
    float promedio;
    Direccion dir;
};

int main() {
    int n;
    cout << "Ingrese la cantidad de estudiantes: ";
    cin >> n;

    Estudiante est[n];
    int sumaEdades = 0;

    for (int i = 0; i < n; i++) {
        cout << "\nEstudiante " << i + 1 << endl;
        cout << "Nombre: ";
        cin >> est[i].nombre;
        cout << "Codigo: ";
        cin >> est[i].codigo;
        cout << "Edad: ";
        cin >> est[i].edad;
        sumaEdades += est[i].edad;
        cout << "Promedio de calificaciones: ";
        cin >> est[i].promedio;

        cout << "--- Direccion ---" << endl;
        cout << "Calle: ";
        cin >> est[i].dir.calle;
        cout << "Ciudad: ";
        cin >> est[i].dir.ciudad;
        cout << "Codigo postal: ";
        cin >> est[i].dir.codigoPostal;
    }

    float promedioEdad = (float)sumaEdades / n;

    cout << "\n--- Estudiantes ---\n";
    for (int i = 0; i < n; i++) {
        cout << "Nombre: " << est[i].nombre
             << " | Codigo: " << est[i].codigo
             << " | Edad: " << est[i].edad
             << " | Promedio: " << est[i].promedio
             << " | Direccion: " << est[i].dir.calle << ", " 
             << est[i].dir.ciudad << " (" << est[i].dir.codigoPostal << ")"
             << endl;
    }

    cout << "\nPromedio de edad de los estudiantes: " << promedioEdad << endl;

    return 0;
}
