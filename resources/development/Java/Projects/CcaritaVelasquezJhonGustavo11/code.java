package Formularios;

import javax.swing.*;
import java.awt.event.*;

public class FrmCalcularPago extends javax.swing.JFrame {

    public FrmCalcularPago() {
        initComponents();
        this.setLocationRelativeTo(null);
        buttonGroupFormaPago.add(RbtContado);
        buttonGroupFormaPago.add(RbtTarjetaDirecto);
        buttonGroupFormaPago.add(RbtTarjetaCuotas);
        TxtPagoFinal.setEditable(false);
    }

    @SuppressWarnings("unchecked")
    private void initComponents() {

        buttonGroupFormaPago = new javax.swing.ButtonGroup();

        jLabel1 = new javax.swing.JLabel();
        TxtCostoBase = new javax.swing.JTextField();
        jLabel2 = new javax.swing.JLabel();
        CboCantidadMedicamentos = new javax.swing.JComboBox<>();
        jLabel3 = new javax.swing.JLabel();
        RbtContado = new javax.swing.JRadioButton();
        RbtTarjetaDirecto = new javax.swing.JRadioButton();
        RbtTarjetaCuotas = new javax.swing.JRadioButton();
        jLabel4 = new javax.swing.JLabel();
        CboPromociones = new javax.swing.JComboBox<>();
        jLabel5 = new javax.swing.JLabel();
        TxtPagoFinal = new javax.swing.JTextField();
        BtnCalcular = new javax.swing.JButton();
        BtnSalir = new javax.swing.JButton();
        BtnNuevo = new javax.swing.JButton();

        setDefaultCloseOperation(javax.swing.WindowConstants.EXIT_ON_CLOSE);
        setTitle("Calcular Pago");

        jLabel1.setText("Costo Base:");

        jLabel2.setText("Cantidad de Medicamentos:");

        CboCantidadMedicamentos.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] {
            "0",
            "5-10",
            "11-20",
            "21 o más"
        }));

        jLabel3.setText("Forma de Pago:");

        RbtContado.setText("Contado");

        RbtTarjetaDirecto.setText("Tarjeta Directo");

        RbtTarjetaCuotas.setText("Tarjeta Cuotas");

        jLabel4.setText("Promociones:");

        CboPromociones.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] {
            "Ninguna",
            "Obtener Receta",
            "Medicamento en Lanzamiento"
        }));

        jLabel5.setText("Pago Final:");

        BtnCalcular.setText("Calcular");
        BtnCalcular.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                BtnCalcularActionPerformed(evt);
            }
        });

        BtnSalir.setText("Salir");
        BtnSalir.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                BtnSalirActionPerformed(evt);
            }
        });

        BtnNuevo.setText("Nuevo");
        BtnNuevo.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                BtnNuevoActionPerformed(evt);
            }
        });

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(getContentPane());
        getContentPane().setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addGap(40, 40, 40)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                    .addComponent(jLabel5)
                    .addComponent(TxtPagoFinal, javax.swing.GroupLayout.DEFAULT_SIZE, 200, Short.MAX_VALUE)
                    .addComponent(jLabel4)
                    .addComponent(CboPromociones, 0, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(jLabel3)
                    .addGroup(layout.createSequentialGroup()
                        .addComponent(RbtContado)
                        .addGap(18, 18, 18)
                        .addComponent(RbtTarjetaDirecto)
                        .addGap(18, 18, 18)
                        .addComponent(RbtTarjetaCuotas))
                    .addComponent(jLabel2)
                    .addComponent(CboCantidadMedicamentos, 0, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(jLabel1)
                    .addComponent(TxtCostoBase))
                .addContainerGap(48, Short.MAX_VALUE))
            .addGroup(layout.createSequentialGroup()
                .addGap(60, 60, 60)
                .addComponent(BtnCalcular, javax.swing.GroupLayout.PREFERRED_SIZE, 100, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(40, 40, 40)
                .addComponent(BtnNuevo, javax.swing.GroupLayout.PREFERRED_SIZE, 100, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(40, 40, 40)
                .addComponent(BtnSalir, javax.swing.GroupLayout.PREFERRED_SIZE, 100, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addGap(25, 25, 25)
                .addComponent(jLabel1)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(TxtCostoBase, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(18, 18, 18)
                .addComponent(jLabel2)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(CboCantidadMedicamentos, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(18, 18, 18)
                .addComponent(jLabel3)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(RbtContado)
                    .addComponent(RbtTarjetaDirecto)
                    .addComponent(RbtTarjetaCuotas))
                .addGap(18, 18, 18)
                .addComponent(jLabel4)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(CboPromociones, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(18, 18, 18)
                .addComponent(jLabel5)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(TxtPagoFinal, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(30, 30, 30)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(BtnCalcular)
                    .addComponent(BtnNuevo)
                    .addComponent(BtnSalir))
                .addContainerGap(30, Short.MAX_VALUE))
        );

        pack();
    }

    private void BtnCalcularActionPerformed(java.awt.event.ActionEvent evt) {
        try {
            double costoBase = Double.parseDouble(TxtCostoBase.getText());
            if (costoBase <= 0) {
                JOptionPane.showMessageDialog(this, "El costo base debe ser mayor a cero.", "Error", JOptionPane.ERROR_MESSAGE);
                return;
            }

            // Descuento por cantidad medicamentos
            String cantidad = (String) CboCantidadMedicamentos.getSelectedItem();
            double descuentoCantidad = 0;
            switch (cantidad) {
                case "0":
                    descuentoCantidad = 0;
                    break;
                case "5-10":
                    descuentoCantidad = 10;
                    break;
                case "11-20":
                    descuentoCantidad = 20;
                    break;
                case "21 o más":
                    descuentoCantidad = 30;
                    break;
            }

            // Descuento por promoción
            String promocion = (String) CboPromociones.getSelectedItem();
            double descuentoPromocion = 0;
            switch (promocion) {
                case "Obtener Receta":
                    descuentoPromocion = costoBase * 0.05;
                    break;
                case "Medicamento en Lanzamiento":
                    descuentoPromocion = costoBase * 0.10;
                    break;
                default:
                    descuentoPromocion = 0;
            }

            // Cargo por forma de pago
            double cargoFormaPago = 0;
            if (RbtContado.isSelected()) {
                cargoFormaPago = 0;
            } else if (RbtTarjetaDirecto.isSelected()) {
                cargoFormaPago = costoBase * 0.02;
            } else if (RbtTarjetaCuotas.isSelected()) {
                cargoFormaPago = costoBase * 0.10;
            } else {
                JOptionPane.showMessageDialog(this, "Debe seleccionar una forma de pago.", "Error", JOptionPane.ERROR_MESSAGE);
                return;
            }

            // Calcular pago final
            double pagoFinal = costoBase - descuentoCantidad - descuentoPromocion + cargoFormaPago;
            if (pagoFinal < 0) {
                pagoFinal = 0;
            }

            TxtPagoFinal.setText(String.format("%.2f", pagoFinal));

        } catch (NumberFormatException e) {
            JOptionPane.showMessageDialog(this, "Ingrese un costo base válido.", "Error", JOptionPane.ERROR_MESSAGE);
        }
    }

    private void BtnSalirActionPerformed(java.awt.event.ActionEvent evt) {
        this.dispose();
    }

    private void BtnNuevoActionPerformed(java.awt.event.ActionEvent evt) {
        TxtCostoBase.setText("");
        CboCantidadMedicamentos.setSelectedIndex(0);
        buttonGroupFormaPago.clearSelection();
        CboPromociones.setSelectedIndex(0);
        TxtPagoFinal.setText("");
    }

    // Variables declaration
    private javax.swing.JButton BtnCalcular;
    private javax.swing.JButton BtnSalir;
    private javax.swing.JButton BtnNuevo;
    private javax.swing.JComboBox<String> CboCantidadMedicamentos;
    private javax.swing.JComboBox<String> CboPromociones;
    private javax.swing.JTextField TxtCostoBase;
    private javax.swing.JTextField TxtPagoFinal;
    private javax.swing.JRadioButton RbtContado;
    private javax.swing.JRadioButton RbtTarjetaDirecto;
    private javax.swing.JRadioButton RbtTarjetaCuotas;
    private javax.swing.ButtonGroup buttonGroupFormaPago;
    private javax.swing.JLabel jLabel1;
    private javax.swing.JLabel jLabel2;
    private javax.swing.JLabel jLabel3;
    private javax.swing.JLabel jLabel4;
    private javax.swing.JLabel jLabel5;
    // End of variables declaration
}

