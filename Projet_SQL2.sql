/*
  INF403 - Projet Partie 2 - Question 6
  Requêtes SQL
*/


-- Requête 1 : Donner les id, nom, prénom des clients qui ne sont jamais venus

SELECT DISTINCT C.idClient, C.prenomClient, C.nomClient 
FROM Clients C
WHERE C.idClient NOT IN (
	SELECT DISTINCT idClient 
	FROM Locations
);

-- Requête 2 : Donner nom, prénom, et nombre de locations du client 156

SELECT C.prenomClient, C.nomClient , COUNT(L.idLocation) AS nbLocation
From Clients C
JOIN Locations L USING (idClient)
WHERE C.idClient = 156
GROUP BY C.idClient, C.nomClient, C.prenomClient;




-- Requête 3 : Donner les numéros des emplacements disponibles entre le 1er et le 10 aout 2025

SELECT numEmplacement 
FROM Emplacements
WHERE numEmplacement NOT IN (
    SELECT numEmplacement
    FROM Locations
    WHERE annulationLocation = 0
      -- Chevauchement : dateArrivee < '2025-08-10' ET dateDepart > '2025-08-01'
      AND dateArriveeLocation < '2025-08-10'
      AND dateDepartLocation  > '2025-08-01'
);

--  Requête 4:  Donner les id et durées des locations du client 156

SELECT idLocation , (JULIANDAY(dateDepartLocation)-JULIANDAY(dateArriveeLocation)) AS durée
FROM Locations
WHERE idClient = 156;

-- Requete 5: Donner les id, nom, prénom des clients qui sont restés le plus de temps en cumulé.



SELECT C.idClient, C.nomClient, C.prenomClient,
       SUM(JULIANDAY(L.dateDepartLocation) - JULIANDAY(L.dateArriveeLocation)) AS dureeTotal
FROM Clients C
JOIN Locations L USING (idClient)
WHERE L.annulationLocation = 0
GROUP BY C.idClient, C.nomClient, C.prenomClient
HAVING dureeTotal = (
    SELECT MAX(dureeParClient)
    FROM (
        SELECT SUM(JULIANDAY(dateDepartLocation) - JULIANDAY(dateArriveeLocation)) AS dureeParClient
        FROM Locations
        WHERE annulationLocation = 0
        GROUP BY idClient
    )
);


-- La requête 6 est très difficile , on a pas pu la faire



-- Requête 7: Donner les id, nom, prénom des clients ont pris toutes les options pendant une location

SELECT DISTINCT C.idClient, C.nomClient, C.prenomClient
FROM Clients C
JOIN Locations L USING (idClient)
JOIN OptionLocations OL USING (idLocation)
WHERE L.annulationLocation = 0
GROUP BY C.idClient, C.nomClient, C.prenomClient, L.idLocation
HAVING COUNT(DISTINCT OL.idOption) = (SELECT COUNT(*) FROM Options);


-- Requête 8: Donner les id, nom, prénom des clients qui ont pris toutes les options sur l’ensemble de leurs locations

SELECT DISTINCT C.idClient, C.nomClient, C.prenomClient
FROM Clients C
JOIN Locations L USING (idClient)
JOIN OptionLocations OL USING (idLocation)
WHERE L.annulationLocation = 0
GROUP BY C.idClient, C.nomClient, C.prenomClient
HAVING COUNT(DISTINCT OL.idOption) = (SELECT COUNT(*) FROM Options);


--  Requête 9: Donner les deux requetes listant les tuples qui ne respectent pas les contraintes données en Question 4.
--Contrainte 1:
	
SELECT OL.idLocation, OL.idOption, OL.quantiteOptionLocation, O.quantiteMaxOption
FROM OptionLocations OL
JOIN Options O USING (idOption)
WHERE O.quantiteMaxOption IS NOT NULL
  AND OL.quantiteOptionLocation > O.quantiteMaxOption;
	


--Contrainte 2 :
	
SELECT L1.idLocation, L1.numEmplacement, L1.dateArriveeLocation, L1.dateDepartLocation
FROM Locations L1
JOIN Locations L2 ON L1.numEmplacement = L2.numEmplacement
                  AND L1.idLocation != L2.idLocation
                  AND L1.annulationLocation = 0
                  AND L2.annulationLocation = 0
                  -- Chevauchement de dates
                  AND L1.dateArriveeLocation < L2.dateDepartLocation
                  AND L2.dateArriveeLocation < L1.dateDepartLocation;




