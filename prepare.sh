#!/bin/bash

# curl -o seznam-volisc-predcasno-zv1g.pdf https://www.dvk-rs.si/files/files/Seznam-volisc-za-predcasno-glasovanje_stanje-18.6.2021-POPRAVLJENA-VERZIJA.xls---List1-%281%29.pdf

curl -o seznam-volisc-predcasno-zv1g.html https://www.dvk-rs.si/index.php/si/strani/seznama-volisc-za-predcasno-glasovanje-in-omnia
#curl -o VDV-GURS-RPE.geojson https://raw.githubusercontent.com/stefanb/gurs-obcine/master/data/VDV.geojson

rm zv1g-volisca-predcasno.geojson

ogr2ogr zv1g-volisca-predcasno.geojson VDV-GURS-RPE.geojson -dialect sqlite \
 -sql "SELECT ST_Union(geometry),
		GROUP_CONCAT('- '|| dvk.OVK || ': ' || OVK_ime, char(10)) as ovk,
		dvk.sedez as 'name',
		dvk.sedez_naslov as 'address',
		dvk.sedez_kraj as 'city'
	FROM 'VDV' AS src
		LEFT JOIN 'seznam-volisc-predcasno-zv1g.csv'.seznam-volisc-predcasno-zv1g AS dvk ON cast(src.VDV_ID as text)=dvk.OVK
    WHERE src.ENOTA = 'VO' 
    GROUP BY dvk.sedez, dvk.sedez_naslov, dvk.sedez_kraj"\
 -nln VDV-GURS-RPE-DVK

rm zv1g-volisca-redno.geojson
ogr2ogr zv1g-volisca-redno.geojson VDV-GURS-RPE.geojson -dialect sqlite \
 -sql "SELECT ST_Union(geometry),
		src.VDV_UIME as 'name',
		IFNULL(src.VDV_DJ, '') as 'name_alt',
		SUM(src.POV_KM2) as 'pov_km2',
		COUNT(src.VDV_ID) as 'vdv_count',
		GROUP_CONCAT(src.VDV_ID, ', ') as vdv_ids
	FROM 'VDV' AS src
    WHERE src.ENOTA = 'VD'
    GROUP BY src.VDV_UIME"\
 -nln VDV-GURS-RPE-Regular

echo "  done."