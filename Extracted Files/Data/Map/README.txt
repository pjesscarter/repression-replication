  
Steps to reproduce Figure 1 of "The Geography of Repression and Opposition to Autocracy" 

Published in the American Journal of Political Science. 

Authors:

1. Maria Angelica Bautista, University of Chicago 
2. Felipe Gonzalez, Universidad Catolica de Chile 
3. Luis R. Martinez (corresponding author), University of Chicago, luismartinez@uchicago.edu 
4. Pablo Munoz, Fundacao Getulio Vargas
5. Mounu Prem, Universidad del Rosario

Computational Environment:

Operating System: Windows 10 Enterprise
GIS Software: QGIS version 3.10 or higher

This file provides detailed instruction for the construction of Figure 1 in the paper. 

Data sources: 
1. Shapefiles with the polygons of all counties and provinces available at the website of the Library of Congress (https://www.bcn.cl/siit/mapas_vectoriales, last accessed 11/10/2020)
2. Victims per 10,000 inhabitants (data.csv). Own calculation. Source 1: Comision Rettig. Informe de la Comision Nacional de Verdad y Reconciliacion. Chile: Ministerio del Interior, 1996. Source 2: 1970 Census (INE): (i) Go to https://www.ine.cl/estadisticas/sociales/censos-de-poblacion-y-vivienda/poblacion-y-vivienda (last accessed 11/2/2020) (ii) Click on "Publicaciones y Anuarios" (iii) Click on "Censos anteriores"
3. Location of military bases (military_bases.csv). Source 1: Edmundo Gonzalez Salinas. Resenas Historicas de las Unidades e Institutos del Ejercito de Chile. Santiago: Instituto Geografico Militar, 1987. Source 2: Chilean Army (FOIA requests): (i) Go to https://www.consejotransparencia.cl/solicitud-informacionpublica/ (last accessed 11/2/2020) (ii) Click on “Organismo and instituciones del Estado” (iii) Register a new user (iv) Login as a user (v) Click on “Solicitar informacion” (vi) Click on “Ministerios y Presidencia” (vii) Click on “Defensa Nacional” (viii) Click on “Ejercito de Chile” (ix) Fill the questionnaire, including the information solicited.

PANEL (a)
  
1. Open shapefiles for provinces and counties in QGIS version 3.10 or higher:
- open QGIS
- click 'layer'
- click on 'add layer'
- click on 'add vector layer'
- add path of  'division_provincial.shp' by clicking on [...] in 'vector dataset'
- click on 'add' and then 'close'
- repeat same steps to add 'cl_comunas_geo.shp'

2. Open military_bases.csv [locations of military bases] in same QGIS project
- click on 'layer'
- click on 'add layer'
- click on 'add delimited text layer'
- add path of military_bases.csv in 'file name' box [...]
- under 'geometry definition' select 'point coordinates'
- if needed adjust 'geometry crs' to 'project crs: epsg:4326-wgs'
- click on 'add' and then 'close'

3. Open data.csv [repression data] in same QGIS project
- click on 'layer'
- click on 'add layer'
- click on 'add delimited text layer'
- add path of data.csv in 'file name' box [...]
- under 'geometry definition' select 'no geometry (attribute only table')
- click on 'add' and then 'close'

4. Add repression data to shapefile of counties
- double click on 'cl_comunas_geo' in the 'layer' window
- click on 'joins' in the menu on the left
- click on '+' at the bottom left
- next to 'join layer' select 'data'
- click on 'id_2002' next to 'join field'
- click on 'ID_2002' next to 'target field'
- click on 'OK' and then 'apply' and then 'OK'

5. Add graduated color for repression data in map
- double click on 'cl_comunas_geo' in the 'layer' window
- click on 'symbology' in the menu on the left
- select 'graduated' in the upper dropdown menu
- select 'data_share_victims' from the dropdown next to 'value'
- select 'equal interval' next to 'mode' with 5 classes
- double click on each category and set the following boundaries: [0-2.4], [2.4-4.8], [4.8-7.1], [7.1-9.5], [9.5-11.9]
- click on 'apply' and then ok
- double click on division_provincial.shp
- click 'symbology' then 'simple fill' then 'no brush' next to 'fill 'style
- click 'apply' and then 'OK'

PANEL (b)

1. Open cl_comunas_coquimbo.shp in QGIS following the procedure in panel (a)
2. Same as panel (a)
3. Same as panel (a)
4. Same as panel (a)

5. Add graduated color for repression data in map
- double click on 'cl_comunas_coquimbo' in the 'layer' window
- click on 'symbology' in the menu on the left
- select 'graduated' in the upper dropdown menu
- select 'data_share_victims' from the dropdown next to 'value'
- select 'equal interval' next to 'mode' with ‘4 classes’: 
- double click on each category and set the following boundaries: [0-0], [0-1.00], [1.00-2.00], [2.00-3.05]
- click on 'apply' and then ok

PANEL (c)

1. Open cl_comunas_cautin.shp in QGIS following the procedure in panel (a)
2. Same as panel (a)
3. Same as panel (a)
4. Same as panel (a)

5. Add graduated color for repression data in map
- double click on 'cl_comunas_cautin' in the 'layer' window
- click on 'symbology' in the menu on the left
- select 'graduated' in the upper dropdown menu
- select 'data_share_victims' from the dropdown next to 'value'
- select 'equal interval' next to 'mode' with ‘4 classes’: 
- double click on each category and set the following boundaries: [0-0], [0-4.3], [4.3-8.6], [8.6-12.9]
- click on 'apply' and then ok 





