#include <iostream>
using namespace std;

class Cuenta {
private:
  string nombre;
  string numero;
  double saldo;

public:
  void RegistrarCuenta() {
    cout << "Titular: ";
    getline(cin, nombre);
    cout << "Numero de cuenta: ";
    getline(cin, numero);
    saldo = 0;
  }
  void DepositarDinero(double c) { saldo += c; }
  void RetirarDinero(double c) {
    if (c <= saldo)
      saldo -= c;
    else
      cout << "Saldo insuficiente\n";
  }
  void ConsultarSaldo() { cout << "Saldo: " << saldo << endl; }
  void MostrarInformacion() {
    cout << "Titular: " << nombre << "\nCuenta: " << numero
         << "\nSaldo: " << saldo << endl;
  }
};

int main() {
  Cuenta c;
  int op;
  double cant;
  do {
    cout << "\n1. Registrar\n2. Depositar\n3. Retirar\n4. Consultar saldo\n5. "
            "Mostrar informacion\n6. Salir\nOpcion: ";
    cin >> op;
    cin.ignore();
    switch (op) {
    case 1:
      c.RegistrarCuenta();
      break;
    case 2:
      cout << "Cantidad: ";
      cin >> cant;
      c.DepositarDinero(cant);
      break;
    case 3:
      cout << "Cantidad: ";
      cin >> cant;
      c.RetirarDinero(cant);
      break;
    case 4:
      c.ConsultarSaldo();
      break;
    case 5:
      c.MostrarInformacion();
      break;
    }
  } while (op != 6);
  return 0;
}
