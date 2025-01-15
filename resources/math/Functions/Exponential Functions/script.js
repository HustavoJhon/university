
---

### 🧩 Archivo `script.js` (JavaScript para gráfica animada con Plotly)

```javascript
// Este script se incluye con include-after-body
Plotly.newPlot('plot', [{
  x: Array.from({length: 181}, (_, i) => i),
  y: Array.from({length: 181}, (_, i) => 1000 * Math.pow(2, i / 20)),
  mode: 'lines+markers',
  line: {color: 'green'},
  name: 'Crecimiento E. coli'
}], {
  title: 'Crecimiento Exponencial de E. coli',
  xaxis: { title: 'Tiempo (minutos)' },
  yaxis: { title: 'Población de bacterias' }
});

