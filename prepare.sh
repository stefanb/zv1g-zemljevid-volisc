#!/bin/bash

# curl -o seznam-volisc-predcasno-zv1g.pdf https://www.dvk-rs.si/files/files/Seznam-volisc-za-predcasno-glasovanje_stanje-18.6.2021.pdf

#curl -o VDV-GURS-RPE.geojson https://raw.githubusercontent.com/stefanb/gurs-obcine/master/data/VDV.geojson

rm VDV-GURS-RPE-DVK.geojson

ogr2ogr VDV-GURS-RPE-DVK.geojson VDV-GURS-RPE.geojson -dialect sqlite \
 -sql "SELECT ST_Union(geometry),
		dvk.OVK as ovk,
		dvk.sedez as 'name'
	FROM 'VDV' AS src
		LEFT JOIN 'seznam-volisc-predcasno-zv1g.csv'.seznam-volisc-predcasno-zv1g AS dvk ON cast(src.VDV_ID as text)=dvk.OVK
    WHERE src.ENOTA = 'VO' 
    GROUP BY dvk.sedez"\
 -nln VDV-GURS-RPE-DVK

echo "  done."