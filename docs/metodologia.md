# Metodología de depuración y clasificación de la base de datos

## 1. Objetivo y criterios de clasificación

El procedimiento de depuración tiene como objetivo preparar la base de datos para su posterior análisis, clasificando los registros en tres grandes categorías:

* **A. Bloques de vivienda**
* **B. Viviendas unifamiliares**
* **C. Viviendas en bloques de viviendas**

La base de datos original presenta distintos problemas derivados de la introducción de los datos, como errores de escritura, categorías no homogéneas y valores introducidos indistintamente en castellano y catalán. Para corregir estas incidencias y establecer una clasificación coherente, se aplica el siguiente procedimiento.

---

## 2. Procedimiento de depuración

El proceso se estructura en tres grandes fases:

1. **Corrección de errores previa**
2. **Joins y creación de columnas adicionales**
3. **Clasificación y depuración de registros dudosos**

### 2.1. Corrección de errores previa

#### 2.1.1. Limpieza de caracteres y valores

Antes de realizar cualquier operación de integración o clasificación se corrigen determinados valores de la base de datos:

* Reemplazo de los valores de **comarca** que presentan errores y generan problemas en procesos posteriores.
* Reemplazo de `-`, `--` y `---` por `NA` en toda la tabla.
* Reemplazo de `0` por `NA` exclusivamente en las columnas `ESCALA` y `PORTA`.

#### 2.1.2. Eliminación de duplicados

Se realiza una primera eliminación de registros duplicados como parte de la corrección previa de la base de datos.

---

### 2.2. Joins y creación de columnas adicionales

Una vez corregidos los errores iniciales, se incorporan variables procedentes de las tablas de equivalencias y de la información catastral y cartográfica.

#### 2.2.1. Referencia catastral corta

Se crea la columna `ref_cad_edifici`, correspondiente a la referencia catastral corta del edificio.

#### 2.2.2. Recategorización del motivo de certificación

A partir de la variable `Motiu` se genera una nueva columna, `Motiu_cert`, con una categorización homogénea de los motivos de certificación.

#### 2.2.3. Incorporación de barrio y distrito

Se realiza un *join* con la tabla correspondiente para incorporar la información de:

* Barrio (`Barri`)
* Distrito (`Districte`)

#### 2.2.4. Incorporación del ámbito territorial

Se realiza un *join* con la tabla de equivalencias territoriales para incorporar el código de ámbito territorial correspondiente.

#### 2.2.5. Incorporación de información catastral

Se realiza un *join* con la información del catastro. Como resultado se incorporan, entre otras, las siguientes variables:

* `pc_Nhabita`: número de viviendas asociado.
* `pc_sumSupf`: superficie construida asociada.

---

## 3. Clasificación de los registros

### 3.1. Primera clasificación

En una primera fase, los registros se clasifican directamente a partir de la variable `Tipus_edifici`, generando tres conjuntos:

* `icaen_a`: bloques de vivienda.
* `icaen_b`: viviendas unifamiliares.
* `icaen_c`: viviendas en bloques de viviendas.

### 3.2. Reclasificación de registros con información de puerta

La primera clasificación presenta algunos casos que deben ser corregidos.

Todos aquellos registros inicialmente clasificados como **bloques de vivienda (A)** o **viviendas unifamiliares (B)** que contienen información en el campo `PORTA` se consideran **viviendas en bloques de viviendas (C)**.

Por tanto:

1. Se eliminan estos registros de `A` y `B`.
2. Se incorporan a `C`.

---

## 4. Depuración de bloques dudosos

Después de la primera clasificación y reclasificación, todavía existen registros clasificados como bloques de vivienda (`A`) cuya clasificación presenta dudas.

Estos casos corresponden a registros que presentan una **referencia catastral de inmueble larga**, por lo que se genera un conjunto denominado `bloques_duda` para su análisis específico.

La depuración de estos registros se realiza mediante una serie de filtros sucesivos.

### 4.1. Bloques que no aparecen en la base cartográfica

En primer lugar, se identifican los bloques de `bloques_duda` que no aparecen en la base cartográfica.

Estos registros se almacenan como:

`bloques_novalidos`

Estos registros se consideran no válidos y posteriormente se eliminan de la categoría `A`.

### 4.2. Filtro de propiedad única

De los bloques restantes se identifican aquellos que tienen asociado un único inmueble, utilizando la variable `pc_Nhabita`.

Estos registros se consideran **bloques de propiedad única** y se almacenan como:

`bloques_unica`

### 4.3. Comparación de superficie construida

Para los registros restantes se compara la superficie indicada en el catastro con la superficie correspondiente en la base cartográfica.

Se identifican como `bloques_erroneos` aquellos casos en los que los metros cuadrados registrados en el catastro son inferiores al **80 % de los metros cuadrados indicados por la base cartográfica**.

### 4.4. Identificación de viviendas

Para determinar cuáles de estos registros pueden ser considerados viviendas, se aplica un último filtro de superficie.

Los registros de `bloques_erroneos` cuya superficie **no supera los 100 m²** se consideran viviendas y se almacenan como:

`bloques_viviendas`

---

## 5. Resultado de la depuración

La clasificación final de los registros se obtiene mediante las siguientes operaciones:

| Conjunto                     | Operación                                   |
| ---------------------------- | ------------------------------------------- |
| `bloques_novalidos`          | Se eliminan de `A`                          |
| `bloques_unica`              | Se excluyen del conjunto de bloques dudosos |
| `bloques_erroneos` > 100 m²  | Se eliminan de `A`                          |
| `bloques_viviendas` ≤ 100 m² | Se eliminan de `A` y se incorporan a `C`    |
| `bloques_duda` restantes     | Se mantienen como bloques (`A`)             |

De esta forma, los registros que finalmente permanecen en `A` son aquellos que, después del proceso de depuración, pueden considerarse bloques de vivienda.

Los registros de `B` corresponden a viviendas unifamiliares y los de `C` a viviendas situadas en bloques de viviendas.

Finalmente, se añade una columna de categoría a los conjuntos `A`, `B` y `C`, permitiendo unirlos en un único archivo y conservar la clasificación de cada registro.

---

## 6. Archivos de entrada

Para ejecutar el script es necesario disponer de una carpeta general que contenga los siguientes archivos y carpetas:

```text
/
├── Dades originals/
│   └── Certificats_d_efici_ncia_energ_tica_d_edificis_AAAAMMDD.csv
│
├── Bases Cartograficas/
│   └── BC_CadCAT_2024_12_xSc.gdb
│
└── Encreuements/
    ├── BarrisDistrictesCAD.xlsx
    ├── TablaEquivalencias_MOTIU.xlsx
    └── TablaEquivalencias_Terr.xlsx
```

### `Dades originals`

Contiene el archivo de datos primario del registro de certificados de eficiencia energética, con el formato:

```text
Certificats_d_efici_ncia_energ_tica_d_edificis_AAAAMMDD.csv
```

### `Bases Cartograficas`

Contiene la geodatabase utilizada para incorporar y contrastar información cartográfica y catastral:

```text
BC_CadCAT_2024_12_xSc.gdb
```

### `Encreuements`

Contiene las tablas utilizadas para los procesos de integración:

* `BarrisDistrictesCAD.xlsx`
* `TablaEquivalencias_MOTIU.xlsx`
* `TablaEquivalencias_Terr.xlsx`

---

## 7. Archivos generados

El proceso genera los siguientes archivos principales:

| Archivo       | Contenido                                                     |
| ------------- | ------------------------------------------------------------- |
| `icaen_total` | Todos los registros juntos                                    |
| `icaen_a`     | Registros clasificados como bloques de vivienda               |
| `icaen_b`     | Registros clasificados como viviendas unifamiliares           |
| `icaen_c`     | Registros clasificados como viviendas en bloques de viviendas |

El archivo `icaen_total` reúne los tres conjuntos y mantiene la categoría asignada a cada registro mediante una columna adicional.

---

## 8. Secuencia de ejecución del script

El script sigue la siguiente secuencia general:

```text
Carga de librerías
        ↓
Carga del CSV original
        ↓
Carga de datos de la geodatabase
        ↓
Corrección de errores previos
        ↓
Joins y creación de variables
        ↓
Primera clasificación A / B / C
        ↓
Reclasificación de registros con PORTA
        ↓
Identificación de bloques dudosos
        ↓
Depuración mediante información cartográfica y catastral
        ↓
Reclasificación de viviendas y eliminación de registros
        ↓
Asignación de categoría
        ↓
Unificación de A + B + C
        ↓
Generación de icaen_total
```

Este procedimiento permite transformar la base de datos original en un conjunto de datos depurado y clasificado, preparado para las posteriores fases de análisis y visualización.
