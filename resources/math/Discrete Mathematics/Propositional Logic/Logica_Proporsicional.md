## UNIDAD I PRIMERA PARTE
### Logica
Es una ciencia formal que estudia la estructura o formas del pensamiento humano (como proposiciones, conceptos y razonamiento) para establecer leyes y principios validos para obtener criterios de verdad. Significa que algo sigue las reglas de la logica y de la razon.
### Enunciado
Es una oracion o expresion (linguistica o matematica) que expresa una idea con ambiguedades, la cual no es posible asignarle un valor definido de verdad o falsedad.
#### Ejemplos:
- Atiende al cliente (Ordenes)
- Que hermoso! (Admiracion)
- Quisiera ser prospero (Deseo)
- Muchos millones se perdieron (Ambiguedad o Anfibologia)
### Proposicion
Llamamos proposicion a toda enunciado que tiene la cualidad de ser verdadera (V) o de ser falsa (F), pero nunca puede ser V y F a la vez. La proposicion es un elemento fundamental de la _logica matematica._

### Notacion
Denotaremos a las proposiciones con letras minusculas: p, q, r, s, t, ... , etc. Si son muchas proposiciones, entonces usaremos subindices, tales como:
p1, p2, p3, p4, ... pn
q1, q2, q3, q4, ... qn
r1, r2, r3, r4, ... rn, etc
#### Ejemplos de proposiciones:
- **p**: Dos mas tres, es igual a cinco (V)
- **q**: Ocho es menor que tres (F)
- **r**: Cinco es diferente de cero (V)
- **s**: Cuatro multiplicado por tres, es igual a doce (V)
- **t**: Cuatro y diez son multiplos de dos (V)
- **u**: Dos es menor que tres y tres es multiplo de 5 (F)
##### En matematicas las proposiciones fundamentales son:
a) Los axiomas o postulados
b) Los lemas
c) Los teoremas
d) Los corolarios
e) Los axiomas o postulados, son proposiciones cuya validez se aceptan sin demostracion.
f) Los lemas, son proposiciones previas a la demostracion de algunos teoremas.
g) Los teoremas, son proposiciones que para ser VALIDOS, necesitan de su demostracion. Se muestran usando los axiomas y algunas tautologias logicas.
h) Los corolarios, son proposiciones que son consecuencias de algunos teoremas.
##### Ejemplos-. Escriba en cada oracion "E" si es enunciado o "p" si es proposicion:
1. Ganamos la licitacion! (E)
2. Ningun numero par es divisible por dos. (P)
3. Rapido. cuenta el dinero (E) (orden)
4. M. Friendman es el creador de la teoria monetaria. (P)
5. El dinero vuela. (E)
6. La UPN es centro de estudios Superiores. (P)
7. Te _estimo_ tanto, aunque tu no lo creas. (E) (dudosa)
8. China esta ubicado en el hemisferio sur. (P)
#### Los Enunciados estan divididos en enunciados abiertos y cerrados.
##### Enunciados Abiertos
Son expresiones que contienen variables y que no tiene la propiedad de ser verdadero o falso. (No es proposicion logica).
##### Enunciado Cerrado
Son proposiciones logicas, es decir, es un enunciado afirmativo verdadero, falso
###### Ejemplos
1. P(x): "x < 5" es un enunciado abierto por que no podemos afirmar que es V o F. Solo cuando las variables "x" toma un valor numerico se hace V o F.
	- Asi tenemos P(3): 3 < 5 es V
		P(9): 9 > 5 es F
2. A(x,y): x^2 + y^2 = 25 tambien es un enunciado abierto.
3. _El_ es un escritor peruano. (enunciado abierto)
4. 3^2 + 4^2 = 5^2 (es enunciado cerrado)
5. x - 1 = 1, enunciado abierto.
### Clase de proposiciones logicas
#### a) Proposiciones simples (atomica o elemental)
Son los enunciados que tienen un solo sujeto y un solo predicado. No llevan ningun conectivo logico.
- P: 1 + 4 = 5 (V)
#### b) Proposiciones compuestas (molecular o coligativa)
Son aquellas proposiciones que se obtienen de la combinacion de dos o mas proposiciones que se obtienen de la combinacion de dos o mas proposiciones simples, las cuales son enlazadas por los simbolos llamados conectores logicos.
**Donde**
"Y" Se representa por "∧"
"O" Se representa por "∨"
"Si ...entonces..." se representa por "p → q"
"Si ...y solo si..." po "p ↔ q"
###### Ejemplos
1. "_9 es mayor que 3_" y "3 es mayor que 2"
>	Se denota por: _p1_ ∧ p2
2. A: "Jose llego tarde, sin embargo dio examen"
>	Jose llego tarde = p3
>	Jose dio examen = p4
>	A ≡" p3 ∧ p4
>	
	**Nota**"≡" se lee "equivalente" Sin embargo es = "y" Aunque es = "y" 	
3. B: "_Si 9 es multiplo de 3_ y **12 es multiplo de 3**", entonces, 9 + 3 es multiplo de 3"
	B ≡ (_P5_ ∧ _P6_) → p9 

### Conectores Logicos
Los conectivos logicos son simbolos que enlazan proposiciones atomicas, sin formar parte de ellas. Dichos simbolos tambien toman el nombre de operaciones.

| Símbolo | Operacion logica         | Simbolo (Conector Lógico) | Expresión | Descripción                                                |
| ------- | ------------------------ | ------------------------- | --------- | ---------------------------------------------------------- |
| ¬ ~     | Negacion                 | NOT                       | ¬A        | Verdadero si la expresión es falsa                         |
| ∧       | Conjuncion               | AND                       | A ∧ B     | Verdadero si ambas expresiones son verdaderas              |
| ∨       | Disyuncion               | OR                        | A ∨ B     | Verdadero si al menos una de las expresiones es verdadera  |
| →       | Condicional (implicador) | Implicación               | A → B     | Verdadero si A implica B (si A es verdadero, B debe serlo) |
| ↔       | Bicondicional            | Doble Implicación         | A ↔ B     | Verdadero si ambas expresiones son equivalentes            |
| ⊕       | Disyuncino excluyente    | XOR (OR exclusivo)        | A ⊕ B     | Verdadero si solo una de las expresiones es verdadera      |

#### Proposciciones Compuestas Basicas
##### Tablas de verdad
La _verdad o falsedad_ de una proposicion se denomina **Validez** (o su valor de verdad). La validez de la conjuncion, de la disyuncion, de la condicional, de la bicondicional y de la negacion puede representarse en TABLAS.
En connsecuencia, dadas dos o mas proposiciones simples cuyos valores de VERDAD son conocidas, el VALOR DE VERDAD de una PROPOSICION COMPUESTA depende de la verdad de cada uno de las proposiciones componentes y se determina mediante TABLAS DE VERDAD.
###### Validez de una proposicion
Existe una correspondencia entre una proposicion y su valor de verdad, asi tenemos que a cada proposicion _p_ le corresponde solo un valor, que puede ser V (verdadero) o F (falsa)"
##### Conbinacion de dos o mas proposiciones
1. Para una proposicion _p_ le corresponde 2^1 = 2 posibles valores: p = {V/F}
2. Para dos proposiciones _p_ y _q_ le corresponde 2^2 = 4 combinaciones de valores.
| **p** | V | V | F | F |
| **q** | F | F | V | V |
3. Para tres proposiciones **p**, **q** y **r** le corresponde 2^3 = 8 combinaciones
| **p** | V | V | V | V | F | F | F | F |
| **q** | V | V | F | F | V | V | F | F |
| **r** | V | F | V | F | V | F | V | F |
n. Para n proposiciones p1, p2, p3,...,pn habran 2^n combinaciones de valores las tablas de verdad de la conjuncion, disyuncion, condicional, bicondicional y negacion es explica a continuacion.
	