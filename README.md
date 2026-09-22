# Depuración y análisis del Registro de Certificados de Eficiencia Energética

> Data cleaning, integration and visualization pipeline for the Catalan
> Energy Performance Certificate (EPC) registry.

[![R](https://img.shields.io/badge/R-276DC3?style=for-the-badge&logo=r&logoColor=white)](https://www.r-project.org/)
[![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)](https://www.microsoft.com/power-platform/products/power-bi)
[![GIS](https://img.shields.io/badge/GIS-3B7D23?style=for-the-badge&logo=qgis&logoColor=white)](https://www.qgis.org/)

## Overview

The Catalan Institute of Energy (ICAEN) publishes a large dataset containing
Energy Performance Certificates (EPC) for buildings across Catalonia.

However, inconsistencies in the original dataset make direct analysis
difficult. This project develops a reproducible workflow to clean,
classify and enrich the registry using cadastral and geographic data.

The final dataset can be used to analyse energy certification according to:

- Building / dwelling typology
- Energy performance
- Certification reason
- Construction year
- Municipality
- Territorial area
- Barcelona district and neighbourhood

This project was developed as part of my Final Degree Thesis in 2025.
[Full thesis doc](https://github.com/sergioalvira/analisis-icaen-cee/blob/ba218a02c63e3cbbb8e29efce5cf4da154b84c02/docs/TFG_SergioAlvira.pdf).

The methodology followed during the development of the script is summarized [here](https://github.com/sergioalvira/analisis-icaen-cee/blob/ba218a02c63e3cbbb8e29efce5cf4da154b84c02/docs/metodologia.md).


## Pipeline

| 01 | 02 | 03 | 04 | 05 | 06 | 07 |
|---|---|---|---|---|---|---|
| **Raw data** | **Cleaning** | **Data integration** | **Classification** | **Deduplication** | **Validated dataset** | **Visualization** |
| ICAEN | Errors & missing values | Cadastral + geographic data | Building types | Latest certificate | Analysis-ready data | R · Excel · Power BI · Web |

## Outputs

### [Interactive storymap](https://sergioalvira.github.io/analisis-icaen-cee/storymap/)

<img width="500" alt="image" src="https://github.com/user-attachments/assets/aa55c1d5-5f49-4dc3-a8eb-de04876e90c4" />

Web-based visualization of energy certificates in Barcelona.

### [Interactive dashboard](https://app.powerbi.com/view?r=eyJrIjoiNzg4MjUzODktZmNiOS00NDAxLTgwOTQtMDEyMWY3NzViM2ZiIiwidCI6IjZiNTE0YzI5LTIzOTEtNDgzMS1iNzc0LTg0ZjM1YzQ1YmYwMSIsImMiOjh9)

<img width="280" alt="image" src="https://github.com/user-attachments/assets/538dfcb5-5428-471d-a3ea-d211f33e3ed9" /> <img width="280" alt="image" src="https://github.com/user-attachments/assets/16d810f3-563d-4f0d-a9ee-70fb22401e5f" />

Power BI dashboard for exploring energy certificates by
territorial level, certification reason and CO₂ emissions rating.

### Data visualization

<img width="500" alt="grafico_icaen" src="https://github.com/user-attachments/assets/8cddc418-b932-4b78-8de6-7cdd15767382" />

Evolution of certification reasons over time.

### Excel pivot tables

<img width="514" height="310" alt="Captura de pantalla 2026-09-22 125706" src="https://github.com/user-attachments/assets/6dd0223e-b966-4392-ab26-f4be9bedf8ef" />

Clean and comprehensible visualization aimed for research technicians to use in report elaborations.

