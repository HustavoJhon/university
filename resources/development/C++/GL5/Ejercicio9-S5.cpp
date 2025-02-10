/*
Ejercicio 9: Registro de Fecha y Validación 

Crea un programa donde se cree un registro para almacenar el día, mes y año de n fechas. 
El programa debe validar si la fecha ingresada es válida, considerando el número de días 
de cada mes y los años bisiestos. Luego, debe mostrar los registros ingresados junto con 
un mensaje indicando si la fecha es válida o no.
*/

#include <iostream>
using namespace std;

struct Fecha {
    int dia;
    int mes;
    int anio;
    bool valida;
};

bool esBisiesto(int anio) {
    return (anio % 4 == 0 && anio % 100 != 0) || (anio % 400 == 0);
}

int diasEnMes(int mes, int anio) {
    if (mes == 2) return esBisiesto(anio) ? 29 : 28;
    if (mes == 4 || mes == 6 || mes == 9 || mes == 11) return 30;
    return 31;
}

int main() {
    int n;
    cout << "Ingrese la cantidad de fechas: ";
    cin >> n;

    Fecha f[n];

    for (int i = 0; i < n; i++) {
        cout << "\nFecha " << i + 1 << endl;
        cout << "Dia: ";
        cin >> f[i].dia;
        cout << "Mes: ";
        cin >> f[i].mes;
        cout << "Anio: ";
        cin >> f[i].anio;

        if (f[i].mes >= 1 && f[i].mes <= 12) {
            int maxDias = diasEnMes(f[i].mes, f[i].anio);
            f[i].valida = (f[i].dia >= 1 && f[i].dia <= maxDias);
        } else {
            f[i].valida = false;
        }
    }

    cout << "\n--- Validacion de Fechas ---\n";
    for (int i = 0; i < n; i++) {
        cout << f[i].dia << "/" << f[i].mes << "/" << f[i].anio
             << " -> " << (f[i].valida ? "Valida" : "No valida") 
             << endl;
    }

    return 0;
}
