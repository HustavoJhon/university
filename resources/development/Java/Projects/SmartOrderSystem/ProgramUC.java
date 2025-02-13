
//package ProgramaSemana1;
import javax.swing.JOptionPane;

public class ProgramaPedidos {
    public static void main(String[] args) {
        int op, cantInvent, cantVendid, inventAgregado, PedidoCompleto = 0, PedidoIncompleto = 0, sumVendidos = 0;
        String entrada;

        do {
            entrada = JOptionPane.showInputDialog("BIENVENIDO \n Ingresar Cantidad de Inventario: ");
            cantInvent = Integer.parseInt(entrada);
            if (cantInvent <= 0)
                JOptionPane.showMessageDialog(null, "Vuelva a ingresar", "ERROR", JOptionPane.WARNING_MESSAGE);
        } while (cantInvent <= 0);

        do {
            entrada = JOptionPane.showInputDialog("=== CAJERO ===\n" +
                    "1. Actualizar Inventario \n" +
                    "2. Realizar Pedido \n" +
                    "3. Mostrar \n" +
                    "4. Salir \n" +
                    "Seleccione opción: ");
            op = Integer.parseInt(entrada);
            if (op < 1 || op > 4)
                JOptionPane.showMessageDialog(null, "Vuelva a ingresar", "ERROR", JOptionPane.WARNING_MESSAGE);

            switch(op) {
                case 1:
                    do {
                        entrada = JOptionPane.showInputDialog("Ingresar cantidad");
                        inventAgregado = Integer.parseInt(entrada);
                        if (inventAgregado <= 0)
                            JOptionPane.showMessageDialog(null, "Vuelva a ingresar", "ERROR", JOptionPane.WARNING_MESSAGE);
                    } while (inventAgregado <= 0);

                    cantInvent = cantInvent + inventAgregado;
                    break;

                case 2:
                    do {
                        entrada = JOptionPane.showInputDialog("Ingresar cantidad a vender");
                        cantVendid = Integer.parseInt(entrada);
                        if (cantVendid <= 0)
                            JOptionPane.showMessageDialog(null, "Vuelva a ingresar", "ERROR", JOptionPane.WARNING_MESSAGE);
                    } while (cantVendid <= 0);

                    if (cantVendid <= cantInvent) {
                        JOptionPane.showMessageDialog(null, "Pedido Completo", "PEDIDO", JOptionPane.WARNING_MESSAGE);
                        cantInvent -= cantVendid;
                        sumVendidos += cantVendid;
                        PedidoCompleto++;
                    } else {
                        JOptionPane.showMessageDialog(null, "Pedido Incompleto", "PEDIDO", JOptionPane.WARNING_MESSAGE);
                        PedidoIncompleto++;
                    }
                    break;

                case 3:
                    JOptionPane.showMessageDialog(null, "Queda: " + cantInvent + "\nVendidos: " + sumVendidos +
                            "\nCantidad Completos: " + PedidoCompleto +
                            "\nPedidos Incompletos: " + PedidoIncompleto, "PEDIDO", JOptionPane.WARNING_MESSAGE);
                    break;

                case 4:
                    JOptionPane.showMessageDialog(null, "Gracias...! vuelva pronto", "SALIDA", JOptionPane.WARNING_MESSAGE);
                    break;
            }
        } while (op != 4);
    }
}
