package Formularios;

import javax.swing.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class FrmCalcularPago extends javax.swing.JFrame {
    public FrmCalcularPago() {
        initComponents();
        this.setLocationRelativeTo(null);
    }

    private void initComponents() {
        setTitle("Calcular Pago");
        setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
        setLayout(null);

        JLabel lblCostoBase = new JLabel("Costo Base:");
        lblCostoBase.setBounds(30, 30, 100, 25);
        add(lblCostoBase);

        txtCostoBase = new JTextField();
        txtCostoBase.setBounds(140, 30, 100, 25);
        add(txtCostoBase);

        JLabel lblMedicamentos = new JLabel("Cantidad Medicamentos:");
        lblMedicamentos.setBounds(30, 70, 150, 25);
        add(lblMedicamentos);

        cboMedicamentos = new JComboBox<>(new String[]{"0", "5-10", "11-20", "21 a más"});
        cboMedicamentos.setBounds(180, 70, 100, 25);
        add(cboMedicamentos);

        JLabel lblFormaPago = new JLabel("Forma de Pago:");
        lblFormaPago.setBounds(30, 110, 100, 25);
        add(lblFormaPago);

        rbContado = new JRadioButton("Contado");
        rbDirecto = new JRadioButton("Tarjeta Directo");
        rbCuotas = new JRadioButton("Tarjeta Cuotas");
        rbContado.setBounds(140, 110, 130, 25);
        rbDirecto.setBounds(140, 140, 130, 25);
        rbCuotas.setBounds(140, 170, 130, 25);

        ButtonGroup bgPago = new ButtonGroup();
        bgPago.add(rbContado);
        bgPago.add(rbDirecto);
        bgPago.add(rbCuotas);
        add(rbContado);
        add(rbDirecto);
        add(rbCuotas);

        JLabel lblPromociones = new JLabel("Promociones:");
        lblPromociones.setBounds(30, 210, 100, 25);
        add(lblPromociones);

        chkReceta = new JCheckBox("Obtener Receta");
        chkLanzamiento = new JCheckBox("Medicamento Lanzamiento");
        chkReceta.setBounds(140, 210, 200, 25);
        chkLanzamiento.setBounds(140, 240, 200, 25);
        add(chkReceta);
        add(chkLanzamiento);

        JLabel lblPagoFinal = new JLabel("Pago Final:");
        lblPagoFinal.setBounds(30, 280, 100, 25);
        add(lblPagoFinal);

        txtPagoFinal = new JTextField();
        txtPagoFinal.setBounds(140, 280, 100, 25);
        txtPagoFinal.setEditable(false);
        add(txtPagoFinal);

        btnCalcular = new JButton("Calcular");
        btnCalcular.setBounds(30, 320, 100, 30);
        add(btnCalcular);

        btnSalir = new JButton("Salir");
        btnSalir.setBounds(140, 320, 100, 30);
        add(btnSalir);

        btnCalcular.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                calcularPago();
            }
        });

        btnSalir.addActionListener(e -> dispose());

        setSize(400, 420);
    }

    private void calcularPago() {
        double costoBase;
        try {
            costoBase = Double.parseDouble(txtCostoBase.getText());
            if (costoBase <= 0) {
                JOptionPane.showMessageDialog(this, "Ingrese un costo base mayor a 0.");
                return;
            }
        } catch (NumberFormatException e) {
            JOptionPane.showMessageDialog(this, "Ingrese un valor válido para el costo base.");
            return;
        }

        double descuentoMedicamento = switch (cboMedicamentos.getSelectedIndex()) {
            case 1 -> 10;
            case 2 -> 20;
            case 3 -> 30;
            default -> 0;
        };

        double porcentajePago = 0;
        if (rbDirecto.isSelected()) porcentajePago = 0.02;
        else if (rbCuotas.isSelected()) porcentajePago = 0.10;

        double descuentoPromocion = 0;
        if (chkReceta.isSelected()) descuentoPromocion += 0.05;
        if (chkLanzamiento.isSelected()) descuentoPromocion += 0.10;

        double pagoFinal = costoBase + (costoBase * porcentajePago);
        pagoFinal -= descuentoMedicamento;
        pagoFinal -= (costoBase * descuentoPromocion);

        txtPagoFinal.setText(String.format("S/ %.2f", pagoFinal));
    }

    private JTextField txtCostoBase;
    private JComboBox<String> cboMedicamentos;
    private JRadioButton rbContado, rbDirecto, rbCuotas;
    private JCheckBox chkReceta, chkLanzamiento;
    private JTextField txtPagoFinal;
    private JButton btnCalcular, btnSalir;
}
