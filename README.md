# CR_distritos_geojson
Provincias, Cantones y Distritos de Costa Rica en formato geoJSON

No me gusta XML, y prefiero JSON.
Me robé el archivo .kml de los distritos de Costa Rica de aquí:

http://daticos-geotec.opendata.arcgis.com/datasets/741bdd9fa2ca4d8fbf1c7fe945f8c916_0

Y hice un pequeño script que los convierte a diferentes archivos geoJSON.

El nombre de cada archivo es el código del distrito (el código postal).

~~Si hay interés, puedo convertir los cantones y las provincias, tambien.~~

geoJSON es muy útil, por ejemplo para usarlo nativamente en Leaflet.js

# Bugs / to-do
- no se si estoy manejando "holes" en los polygons bien. Existen "holes" en distritos en CR?


-M.
