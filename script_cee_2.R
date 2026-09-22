#Script desarrollado por Sergio Alvira para la explotación de la base de CEE del ICAEN

#0-------------------PASOS PREVIOS
library(readr)
library(data.table)
library(dplyr)
library(lubridate)
library(readxl)  # Para leer archivos .xlsx
library(sf) # Para leer gdb
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

#Abrimos el archivo CSV como versión 0
dir_csv <- "./Dades originals/Certificats_d_efici_ncia_energ_tica_d_edificis_20250210.csv"
icaen_0 <- read_csv(dir_csv)

# Cargar registro del cadastre desde una gdb
# Ruta a la Geodatabase
gdb_path <- "./Bases Cartograficas/BC_CadCAT_2024_12_xSc.gdb"

# Leer una feature específica
feature_name <- "Cad_2024_12Dis"
BaseCad <- st_read(gdb_path, layer = feature_name)

# Abrir la tabla de datos de catastro para conseguir los años de construcción
tabla1 <- readRDS("./Any cadastre/250508_resultats_taula1.rds")
tabla2 <- readRDS("./Any cadastre/250508_resultats_taula2.rds")




#1-------------------LIMPIEZA DE CARACTERES MAL INTRODUCIDOS Y OTROS ERRORES

#1.1-------------------Reemplazar comarcas que estaban mal y luego nos dan errores
icaen_0 <- icaen_0 %>%
  mutate(CODI_COMARCA = replace(CODI_COMARCA, is.na(CODI_COMARCA), 24))

#1.2-------------------Reemplazar "-", "--" y "---" por NA en toda la tabla
icaen_0 <- icaen_0 %>%
  mutate(across(everything(), ~ ifelse(. %in% c("-", "--", "---", "- -", "- - -", "----", "-----", ".", "/"), NA, .)))

#1.3-------------------Reemplazar "0" por NA solo en las columnas ESCALA y PORTA
icaen_0 <- icaen_0 %>%
  mutate(across(c(ESCALA, PORTA), ~ ifelse(. %in% c("0", 0), NA, .)))

#1.4-------------------Convertir la columna de fecha a formato de fecha
icaen_0$DATA_ENTRADA <- dmy(icaen_0$DATA_ENTRADA)

icaen <- icaen_0

rm(icaen_0)




#2-------------------JOINS Y COLUMNAS EXTRA

#2.1-------------------Crear columna de referencia catastral de parcela (14 dígitos) 

icaen <- icaen %>%
  mutate(ref_cad_edifici = substr(`REFERENCIA CADASTRAL`, 1, 14))


#2.2-------------------Sustituir valores de Motiu

#Cargar la tabla de equivalencias desde el Excel
equivalencias <- read_excel("./Encreuements/TablaEquivalencias_MOTIU.xlsx", col_names = FALSE)
colnames(equivalencias) <- c("valor_original", "valor_equivalente")

#Crear un vector de equivalencias
equivalencias <- setNames(equivalencias[[2]], equivalencias[[1]])

icaen <- icaen %>%
  mutate(`Motiu_cert` = recode(`Motiu de la certificacio`, !!!equivalencias))


#2.3-------------------Añadir Barri i Districte según cadastre

equivalencias_cadastre <- read_xlsx("./Encreuements/BarrisDistrictesCAD.xlsx")

equivalencias_cadastre <- equivalencias_cadastre %>% distinct(REFCAT, .keep_all = TRUE)

#Quedarnos solo con la referencia catastral de edificio y hacer el join
icaen <- icaen %>%
  left_join(equivalencias_cadastre, by = c("ref_cad_edifici" = "REFCAT"))


#2.4-------------------Añadir código de ámbito terr.

equivalencias_terr <- read_xlsx("./Encreuements/TablaEquivalencias_Terr.xlsx")

#Quedarnos solo con la referencia catastral de edificio y hacer el join
icaen <- icaen %>%
  mutate(CODI_POBLACIO = as.numeric(CODI_POBLACIO)) %>%
  left_join(equivalencias_terr, by = c("CODI_POBLACIO" = "CODI_INE"))


#2.5-------------------Join Cadastre
BaseCad <- BaseCad %>%
  mutate(REFCAT_14 = substr(REFCAT, 1, 14))

icaen <- icaen %>%
  left_join(BaseCad %>% select(REFCAT_14, pc_Nhabita, pc_sumSupf),
            by = c("ref_cad_edifici" = "REFCAT_14"))

icaen <- icaen %>% select(-Shape)



#3-------------------DIVISIÓN SEGÚN OBJETOS DE ESTUDIO

#3.1-------------------Primera division en grupos

icaen_a <- icaen %>%
  filter(US_EDIFICI %in% c("Bloc d'habitatges",
                           "Bloc d'habitatges plurifamiliar",
                           "Bloque de viviendas plurifamiliar",
                           "Bloque de viviendas"))


icaen_b <- icaen %>%
  filter(US_EDIFICI %in% c("Habitatge unifamiliar",
                           "Habitatge Unifamiliar",
                           "Vivienda unifamiliar"))


icaen_c <- icaen %>%
  filter(US_EDIFICI %in% c("Habitatge individual en bloc d'habitatges",
                           "Vivienda individual en bloque de viviendas"))


#3.2---------Pasar a C aquellos que tienen info porta

# Filtrar registros donde PIS o PORTA no sean NA
eliminados_a <- !is.na(icaen_a$PIS) & !is.na(icaen_a$PORTA)
eliminados_b <- !is.na(icaen_b$PIS)


# Mover los registros que cumplen la condición a icaen_c
icaen_c <- bind_rows(icaen_c, filter(icaen_a, eliminados_a))
icaen_c <- bind_rows(icaen_c, filter(icaen_b, eliminados_b))

# Eliminar esos registros de icaen_a
icaen_a <- filter(icaen_a, !eliminados_a)
icaen_b <- filter(icaen_b, !eliminados_b)



#3.3-----------------Bloques dudosos

bloques_duda <- icaen_a %>%
  filter(nchar(`REFERENCIA CADASTRAL`) > 14)


#A - Eliminar aquellos que no aparecen
bloques_novalidos <- bloques_duda %>%
  filter(is.na(pc_Nhabita))

bloques_duda <- bloques_duda %>%
  filter(!is.na(pc_Nhabita))


#B - Filtro de propiedad única
bloques_unica <- bloques_duda %>%
  filter(pc_Nhabita == 1)

bloques_duda <- bloques_duda %>%
  filter(pc_Nhabita != 1)


#C - Filtro metros construidos
bloques_erroneos <- bloques_duda %>%
  filter(METRES_CADASTRE < pc_sumSupf * 0.8)

bloques_viviendas <- bloques_erroneos %>%
  filter(METRES_CADASTRE < 100)

bloques_correctos  <- anti_join(bloques_duda, bloques_erroneos)
bloques_erroneos  <- anti_join(bloques_erroneos, bloques_viviendas)


#Redistribuir estos a los grupos correspontiendes, eliminar los que no queremos en A
icaen_a <- anti_join(icaen_a, bloques_erroneos)
icaen_a <- anti_join(icaen_a, bloques_novalidos)
icaen_a <- anti_join(icaen_a, bloques_viviendas)

icaen_c <- rbind(icaen_c, bloques_viviendas)


# Añadir la columna "Categoría" a cada dataset
icaen_a <- icaen_a %>% mutate(Categoria = "Edifici plurifamiliar")
icaen_b <- icaen_b %>% mutate(Categoria = "Habitatge unifamiliar")
icaen_c <- icaen_c %>% mutate(Categoria = "Habitatge en edifici plurifamiliar")

# Unirlos todos en uno solo
icaen_total <- bind_rows(icaen_a, icaen_b, icaen_c)



#4-------------------ELIMINAR DUPLICADOS Y GENERAR ARCHIVOS FINALES

# Ordenar por fecha de entrada de más reciente a más antigua
icaen_total <- icaen_total %>% arrange(desc(DATA_ENTRADA))

# Eliminar duplicados manteniendo la fila con la fecha más reciente
icaen_vigente <- icaen_total %>%
  distinct(`REFERENCIA CADASTRAL`, NUMERO, PIS, ESCALA, PORTA, .keep_all = TRUE)





#-------------------Guardar el resultado en un nuevo CSV
write.csv(icaen_a, "./icaen_a.csv", row.names = FALSE)
write.csv(icaen_b, "./icaen_b.csv", row.names = FALSE)
write.csv(icaen_c, "./icaen_c.csv", row.names = FALSE)
write.csv(icaen_total, "./icaen_total.csv", row.names = FALSE)
write.csv(icaen_vigente, "./icaen_vigente.csv", row.names = FALSE)