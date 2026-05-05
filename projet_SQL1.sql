/*
  INF403 - Projet Partie 2 - Question 2
*/

/* DROP des tables (ordre inverse des dépendances) */


DROP TABLE IF EXISTS Factures;
DROP TABLE IF EXISTS OptionLocations;
DROP TABLE IF EXISTS Locations;
DROP TABLE IF EXISTS Options;
DROP TABLE IF EXISTS TarificationEmplacements;
DROP TABLE IF EXISTS Emplacements;
DROP TABLE IF EXISTS TypeEmplacements;
DROP TABLE IF EXISTS Saisons;
DROP TABLE IF EXISTS TypeSaisons;
DROP TABLE IF EXISTS Clients;


/*  CREATE des tables  */


CREATE TABLE Clients (
    idClient        INTEGER NOT NULL,
    prenomClient    TEXT    NOT NULL,
    nomClient       TEXT    NOT NULL,
    adresseClient   TEXT,
    codePostalClient NUMERIC,
    villeClient     TEXT,
    telephoneClient NUMERIC,
    CONSTRAINT pk_Clients PRIMARY KEY (idClient)
);
 


CREATE TABLE TypeSaisons (
    nomTypeSaison TEXT NOT NULL,
    CONSTRAINT pk_TypeSaisons PRIMARY KEY (nomTypeSaison),
    CONSTRAINT ck_TypeSaisons_nom CHECK (nomTypeSaison IN ('basse', 'moyenne', 'haute'))
);

CREATE TABLE Saisons (
	idSaison  INTEGER NOT NULL,
	descriptifSaison TEXT,
    dateDebutSaison  TEXT    NOT NULL,   
    dateFinSaison    TEXT    NOT NULL,
    nomTypeSaison    TEXT    NOT NULL,
	CONSTRAINT pk_idSaison PRIMARY KEY (idSaison),
	CONSTRAINT fk_Saisons_TypeSaisons
        FOREIGN KEY (nomTypeSaison) REFERENCES TypeSaisons(nomTypeSaison),
    CONSTRAINT ck_Saisons_dates CHECK (dateDebutSaison < dateFinSaison)
);
 
 
 
 
 CREATE TABLE TypeEmplacements (
    idTypeEmplacement       INTEGER NOT NULL,
    descriptionTypeEmplacement TEXT NOT NULL,
    CONSTRAINT pk_TypeEmplacements PRIMARY KEY (idTypeEmplacement)
);

CREATE TABLE Emplacements (
    numEmplacement    INTEGER NOT NULL,
    idTypeEmplacement INTEGER NOT NULL,
    CONSTRAINT pk_Emplacements PRIMARY KEY (numEmplacement),
    CONSTRAINT fk_Emplacements_TypeEmplacements
        FOREIGN KEY (idTypeEmplacement) REFERENCES TypeEmplacements(idTypeEmplacement)
);
 
 
 CREATE TABLE TarificationEmplacements (
    idTypeEmplacement               INTEGER NOT NULL,
    nomTypeSaison                   TEXT    NOT NULL,
    prixJourneeTarificationEmplacement REAL  NOT NULL,
    CONSTRAINT pk_TarificationEmplacements
        PRIMARY KEY (idTypeEmplacement, nomTypeSaison),
    CONSTRAINT fk_Tarif_TypeEmplacements
        FOREIGN KEY (idTypeEmplacement) REFERENCES TypeEmplacements(idTypeEmplacement),
    CONSTRAINT fk_Tarif_TypeSaisons
        FOREIGN KEY (nomTypeSaison) REFERENCES TypeSaisons(nomTypeSaison),
    CONSTRAINT ck_Tarif_prix CHECK (prixJourneeTarificationEmplacement > 0)
);

CREATE TABLE Options (
    idOption            INTEGER NOT NULL,
    descriptionOption   TEXT    NOT NULL,
    quantiteMaxOption   INTEGER,             -- NULL = pas de limite
    prixJourneeOption   REAL    NOT NULL,
    CONSTRAINT pk_Options PRIMARY KEY (idOption),
    CONSTRAINT ck_Options_qteMax  CHECK (quantiteMaxOption IS NULL OR quantiteMaxOption > 0),
    CONSTRAINT ck_Options_prix    CHECK (prixJourneeOption > 0)
);



CREATE TABLE Locations (
    idLocation          INTEGER NOT NULL,
    dateArriveeLocation TEXT    NOT NULL,   
    dateDepartLocation  TEXT    NOT NULL,
    annulationLocation  INTEGER NOT NULL DEFAULT 0,  -- 0 = false, 1 = true  (BOOLEAN SQLite)
    idClient            INTEGER NOT NULL,
    numEmplacement      INTEGER NOT NULL,
    CONSTRAINT pk_Locations PRIMARY KEY (idLocation),
    CONSTRAINT fk_Locations_Clients
        FOREIGN KEY (idClient) REFERENCES Clients(idClient),
    CONSTRAINT fk_Locations_Emplacements
        FOREIGN KEY (numEmplacement) REFERENCES Emplacements(numEmplacement),
    -- Au moins 1 nuit (dateArrivée < dateDépart)
    CONSTRAINT ck_Locations_dates CHECK (dateArriveeLocation < dateDepartLocation),
    CONSTRAINT ck_Locations_annulation CHECK (annulationLocation IN (0, 1))
);


CREATE TABLE OptionLocations (
    idLocation              INTEGER NOT NULL,
    idOption                INTEGER NOT NULL,
    dateDebutOptionLocation TEXT    NOT NULL,
    dateFinOptionLocation   TEXT    NOT NULL,
    quantiteOptionLocation  INTEGER NOT NULL,
    CONSTRAINT pk_OptionLocations
        PRIMARY KEY (idLocation, idOption),
    CONSTRAINT fk_OptionLocations_Locations
        FOREIGN KEY (idLocation) REFERENCES Locations(idLocation),
    CONSTRAINT fk_OptionLocations_Options
        FOREIGN KEY (idOption)   REFERENCES Options(idOption),
    -- Les dates de l'option doivent être incluses dans la période de location
    -- (vérifié applicativement ou via trigger ; SQLite ne supporte pas les FK cross-row)
    CONSTRAINT ck_OptionLocations_dates
        CHECK (dateDebutOptionLocation <= dateFinOptionLocation),
    -- La quantité demandée doit être > 0
    CONSTRAINT ck_OptionLocations_qte CHECK (quantiteOptionLocation > 0)
);



CREATE TABLE Factures (
    idFacture           INTEGER NOT NULL,
    dateEditionFacture  TEXT    NOT NULL,
    idLocation          INTEGER NOT NULL,
    CONSTRAINT pk_Factures PRIMARY KEY (idFacture),
    CONSTRAINT fk_Factures_Locations
        FOREIGN KEY (idLocation) REFERENCES Locations(idLocation),
    -- Au plus une facture par location
    CONSTRAINT uq_Factures_location UNIQUE (idLocation)
);




/*
  INF403 - Projet Partie 2 - Question 3
  Transfert des données depuis la table camping vers les tables bien conçues
*/



INSERT INTO Clients (idClient, prenomClient, nomClient, adresseClient, codePostalClient, villeClient, telephoneClient)
    SELECT DISTINCT
        id_client,
        prenom_client,
        nom_client,
        adresse_client,
        code_postal_client,
        ville_client,
        telephone_client
    FROM camping
    WHERE id_client IS NOT NULL;
 

INSERT INTO TypeSaisons (nomTypeSaison)
    SELECT DISTINCT nom_type_saison
    FROM camping
    WHERE nom_type_saison IS NOT NULL;
	
	

INSERT INTO Saisons ( descriptifSaison, dateDebutSaison, dateFinSaison, nomTypeSaison)
    SELECT DISTINCT
        
        descriptif_saison,
        date_debut_saison,
        date_fin_saison,
        nom_type_saison
    FROM camping
    WHERE nom_type_saison IS NOT NULL
      AND date_debut_saison IS NOT NULL
      AND date_fin_saison IS NOT NULL;
	 
	 

 
INSERT INTO TypeEmplacements (idTypeEmplacement, descriptionTypeEmplacement)
    SELECT DISTINCT
        id_type_emplacement,
        description_type_emplacement
    FROM camping
    WHERE id_type_emplacement IS NOT NULL;
	


	
INSERT INTO Emplacements (numEmplacement, idTypeEmplacement)
    SELECT DISTINCT
        num_emplacement,
        id_type_emplacement
    FROM camping
    WHERE num_emplacement IS NOT NULL;
	
	
	
INSERT INTO TarificationEmplacements (idTypeEmplacement, nomTypeSaison, prixJourneeTarificationEmplacement)
    SELECT DISTINCT
        id_type_emplacement,
        nom_type_saison,
        prix_journee
    FROM camping
    WHERE id_type_emplacement IS NOT NULL
      AND nom_type_saison IS NOT NULL
      AND prix_journee IS NOT NULL;

	  
	  
	  
INSERT INTO Options (idOption, descriptionOption, quantiteMaxOption, prixJourneeOption)
    SELECT DISTINCT
        id_option,
        description_option,
        quantite_max_option,
        prix_journee_option
    FROM camping
    WHERE id_option IS NOT NULL;
	
	
	
INSERT INTO Locations (idLocation, dateArriveeLocation, dateDepartLocation, annulationLocation,  idClient, numEmplacement)
    SELECT DISTINCT
        id_location,
        date_arrivee_location,
        date_depart_location,
        annule,
        id_client,
        num_emplacement
    FROM camping
    WHERE id_location IS NOT NULL;
	
	
	
INSERT INTO OptionLocations (idLocation, idOption, dateDebutOptionLocation, dateFinOptionLocation, quantiteOptionLocation)
    SELECT DISTINCT
        id_location,
        id_option,
        date_debut_option,
        date_fin_option,
        quantite_option
    FROM camping
    WHERE id_location IS NOT NULL
      AND id_option IS NOT NULL
      AND date_debut_option IS NOT NULL
      AND date_fin_option IS NOT NULL
      AND quantite_option IS NOT NULL;
	  
	  
	  
	  
INSERT INTO Factures (idFacture, dateEditionFacture,  idLocation)
    SELECT DISTINCT
        id_facture,
        date_edition_facture,
        id_location
    FROM camping
    WHERE id_facture IS NOT NULL;
	
	

	
/*
  INF403 - Projet Partie 2 - Question 4
  Insertions de données qui ne respectent pas les contraintes
*/


INSERT INTO OptionLocations (idLocation, idOption, dateDebutOptionLocation, dateFinOptionLocation, quantiteOptionLocation)
VALUES (
    59193,        -- location existante (emplacement 46, du 2025-06-12 au 2025-06-16)
    3,            -- Branchement électrique (quantiteMax = 1)
    '2025-06-12',
    '2025-06-16',
    5             -- VIOLATION : 5 > quantiteMax (1)
);

	
INSERT INTO Locations (idLocation, dateArriveeLocation, dateDepartLocation, annulationLocation, idClient, numEmplacement)
VALUES (
    99999,        -- nouvel idLocation
    '2025-06-13', -- dateArrivee : au milieu de la location 59193 !
    '2025-06-15', -- dateDepart  : toujours dans la location 59193
    0,            -- non annulée
    1,            -- un client existant
    46            -- VIOLATION : emplacement 46 déjà réservé
                  -- sur la période 2025-06-12 / 2025-06-16
);


/*
  INF403 - Projet Partie 2 - Question 5
  Vues
*/

DROP VIEW IF EXISTS MontantLocations;

CREATE VIEW MontantLocations ( idLocation , prixEplacement , prixOption , prixTotal)AS 
SELECT 
	L.idLocation,
	(JULIANDAY(L.dateDepartLocation) - JULIANDAY(L.dateArriveeLocation)) * TE.prixJourneeTarificationEmplacement 
	AS prixEplacement,
	
	
	 (SELECT SUM(
	(JULIANDAY(OL.dateFinOptionLocation) - JULIANDAY(OL.dateDebutOptionLocation)) * OL.quantiteOptionLocation * O.prixJourneeOption )
	 FROM OptionLocations OL 
	 JOIN Options O USING (idOption)
	 WHERE OL.idLocation = L.idLocation 
	)AS prixOption,
	
	
	(
	(JULIANDAY(L.dateDepartLocation) - JULIANDAY(L.dateArriveeLocation)) * TE.prixJourneeTarificationEmplacement 
	)
	+
	(
	 SELECT SUM(
	(JULIANDAY(OL.dateFinOptionLocation) - JULIANDAY(OL.dateDebutOptionLocation)) * OL.quantiteOptionLocation * O.prixJourneeOption)
	 FROM OptionLocations OL 
	 JOIN Options O USING (idOption)
	 WHERE OL.idLocation = L.idLocation 
	
	)
	AS  prixTotal

FROM Locations L
JOIN Emplacements E USING (numEmplacement)
JOIN TarificationEmplacements TE USING (idTypeEmplacement)
JOIN Saisons S USING (nomTypeSaison)
WHERE L.annulationLocation = 0
  AND L.dateArriveeLocation >= S.dateDebutSaison
  AND L.dateArriveeLocation < S.dateFinSaison;

  
  
  
  
  
DROP VIEW IF EXISTS ArrhesLocations;

CREATE VIEW ArrhesLocations (idLocation, arrhesLocation) AS
SELECT
    idLocation,
    prixTotal * 0.20 AS arrhesLocation
FROM MontantLocations;
 






