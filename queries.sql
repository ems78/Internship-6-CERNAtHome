--● naziv i datum objave svakog znanstvenog rada zajedno s imenima znanstvenika koji su  
--na njemu radili, pri čemu imena znanstvenika moraju biti u jednoj ćeliji i u obliku     
--Prezime, I.; npr. Puljak, I.; Godinović, N.; Bilušić, A.								


SELECT scw.name AS scientificwork, scw.publishdate,
(SELECT STRING_AGG(s.lastname || ', ' || SUBSTRING(s.firstname, 1, 1 ), '; ' ) AS scientists
FROM scientists s
WHERE (SELECT COUNT(*) FROM scientistworks sw WHERE s.id = sw.scientistid AND scw.id = sw.scientificworkid) > 0)
FROM scientificworks scw;




----------------------------------------------------------------------------------------------------------------------------------------
--● ime, prezime, spol (ispisati ‘MUŠKI’, ‘ŽENSKI’, ‘NEPOZNATO’, ‘OSTALO’;), ime države i
--PPP/capita iste svakom znanstveniku


SELECT s.firstname, s.lastname,
		CASE
			WHEN g.meaning like 'not known'
				THEN 'NEPOZNATO'
			WHEN g.meaning like 'male'
				THEN 'MUŠKI'
			WHEN g.meaning like 'female'
				THEN 'ŽENSKI'
			ELSE
				'OSTALO'
		END AS gender,
		c.name AS country,
		c.ppp
FROM scientists s
INNER JOIN genders g on s.genderid = g.id
INNER JOIN countries c on s.countryid = c.id
ORDER BY lastname, firstname;




----------------------------------------------------------------------------------------------------------------------------------------
--● svaku kombinaciju projekta i akceleratora, pri čemu nas zanimaju samo nazivi; u slučaju -------------  ne prikazuje NEMA GA -------
--da projekt nije vezan ni za jedan akcelerator, svejedno ga ispiši uz ime akceleratora ‘NEMA GA’. 


SELECT p.name AS projectname,
		CASE
			WHEN p.acceleratorid = null  -- not between 1 and 21 isto ne radi
				THEN 'NEMA GA' 			-- ne pripoznaje null iako pise
			ELSE
				a.name
		END AS accelerator
FROM projects p
FULL OUTER JOIN accelerators a ON p.acceleratorid = a.id;




----------------------------------------------------------------------------------------------------------------------------------------
--● sve projekte kojima je bar jedan od radova izašao između 2015. i 2017.


SELECT distinct p.id, p.name AS project, p.acceleratorid
FROM projects p
INNER JOIN scientificworks scw ON p.id = scw.projectid
WHERE scw.publishdate >= '2015-01-01' AND scw.publishdate < '2017-01-01'
ORDER BY p.id;




----------------------------------------------------------------------------------------------------------------------------------------
--● u istoj tablici po zemlji broj radova i najpopularniji rad znanstvenika iste zemlje, pri čemu
--je najpopularniji rad onaj koji ima najviše citata


SELECT co.name AS country,
		(SELECT COUNT(*) AS numberofpapers 
			FROM scientistworks sw
			INNER JOIN scientists s ON s.id = sw.scientistid
			INNER JOIN countries c ON c.id = s.countryid
			WHERE c.id = co.id
			GROUP BY c.id ),
		(select  scw3.name as scientificwork
				FROM scientificworks scw3
				INNER JOIN scientistworks sw3 ON sw3.scientificworkid = scw3.id
				INNER JOIN scientists s3 ON s3.id = sw3.scientistid
				INNER JOIN countries c3 ON c3.id = s3.countryid
				WHERE c3.id = co.id
				ORDER BY 1 DESC
				LIMIT 1)
FROM countries co
ORDER BY country;





----------------------------------------------------------------------------------------------------------------------------------------
--● prvi objavljeni rad po svakoj zemlji


SELECT c.name AS country, 
(SELECT scw.name FROM scientificworks scw
 				 INNER JOIN scientistworks sw ON sw.scientificworkid = scw.id
 				 INNER JOIN scientists s ON s.id = sw.scientistid
 				 WHERE s.countryid = c.id
				 ORDER BY scw.publishdate DESC
			     LIMIT 1) AS scientificwork
FROM countries c
ORDER BY c.name;


-- provjera
SELECT c.name AS country, scw.name AS scientificwork, scw.publishdate FROM scientificworks scw
INNER JOIN scientistworks sw ON sw.scientificworkid = scw.id
INNER JOIN scientists s ON s.id = sw.scientistid
INNER JOIN countries c ON c.id = s.countryid
ORDER BY publishdate DESC;






----------------------------------------------------------------------------------------------------------------------------------------
--● gradove po broju znanstvenika koji trenutno u njemu borave


SELECT x.town, COUNT(x.townid) AS scientistnumber
FROM (SELECT s.firstname || ' ' || s.lastname AS scientist, 
	  t.id AS townid, 
	  t.name AS town 
	  FROM scientists s
		INNER JOIN hotels h ON h.id = s.hotelid
		INNER JOIN towns t ON t.id = h.townid) x
GROUP BY x.town
ORDER BY scientistnumber DESC;






----------------------------------------------------------------------------------------------------------------------------------------
--● prosječan broj citata radova po svakom akceleratoru


SELECT a.name AS accelerator, 
		ROUND(AVG(scw.timescited),1) AS averagecitations 
FROM scientificworks scw
INNER JOIN projects p ON p.id = scw.projectid
INNER JOIN accelerators a ON a.id = p.acceleratorid
GROUP BY a.name
ORDER BY averagecitations DESC;



----------------------------------------------------------------------------------------------------------------------------------------
--● broj znanstvenika po struci, desetljeću rođenja i spolu; u slučaju da je broj znanstvenika
--manji od 20, ne prikazuj kategoriju; poredaj prikaz po desetljeću rođenja



SELECT p.name AS profession,    
		EXTRACT('decade' FROM s.birthdate) as decade,   -- podjela bez filtera za broj znanstvenika
		g.meaning AS gender, 
		COUNT(*) 
		FROM scientists s  
INNER JOIN professions p ON p.id = s.professionid
INNER JOIN genders g ON g.id = s.genderid
GROUP BY p.name, decade, g.meaning
ORDER BY decade DESC, 4 DESC;



SELECT p.name AS profession, 
			EXTRACT('decade' FROM s.birthdate) as decade, 
			g.meaning AS gender, 
			COUNT(*) AS broj
FROM scientists s  
INNER JOIN professions p ON p.id = s.professionid
INNER JOIN genders g ON g.id = s.genderid
GROUP BY p.name, decade, g.meaning
HAVING COUNT(*) >= 20
ORDER BY 4 DESC;






----------------------------------------------------------------------------------------------------------------------------------------
--Bonus:

--● prikaži 10 najbogatijih znanstvenika, ako po svakom radu dobije €
--sqrt(𝑏𝑟𝑜𝑗𝐶𝑖𝑡𝑎𝑡𝑎)/𝑏𝑟𝑜𝑗𝑍𝑛𝑎𝑛𝑠𝑡𝑣𝑒𝑛𝑖𝑘𝑎𝑃𝑜𝑅𝑎𝑑𝑢


SELECT * FROM scientificworks scw
order by scw.timescited desc


SELECT s.firstname || ' ' || s.lastname AS scientist,
	SUM(x.money) AS moneyreceived
FROM (SELECT scw.id,  
		DIV(CAST(SQRT(scw.timescited) AS INTEGER), (SELECT COUNT(*) FROM scientistworks sw WHERE sw.scientificworkid = scw.id)) AS money
		FROM scientificworks scw ) x
INNER JOIN scientistworks sw1 ON sw1.scientificworkid = x.id
INNER JOIN scientists s ON s.id = sw1.scientistid
GROUP BY s.id
ORDER BY 2 DESC
LIMIT 10;






--● radovi se najčešće pretražuju po imenu; kako optimizirati bazu?