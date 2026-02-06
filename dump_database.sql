DROP DATABASE IF EXISTS bdd_grp3;
CREATE DATABASE IF NOT EXISTS bdd_grp3;
USE bdd_grp3;

create user if not exists 'admin'@'localhost' identified by 'admin_mdp' ;
grant all privileges on bdd_grp3.* to 'admin'@'localhost' ;

create user if not exists 'user'@'localhost' identified by 'user_mdp' ;
grant select on bdd_grp3.* to 'user'@'localhost' ;

flush privileges ;

-- LDD -----------------------------------------------------------------------------------------------------------------------------------------

DROP TABLES IF EXISTS Rapports, Regions, Types_gaz, Villes, Agences, Personnel, Gaz, Chef_agence, Agent_technique, Agent_administratif, Capteurs, Releves, Rediger, Dependre;

CREATE TABLE IF NOT EXISTS Rapports(
   ID_Rapport INT AUTO_INCREMENT,
   Date_rapport DATE CHECK (Date_rapport BETWEEN "2017-01-01" AND "2024-12-31") NOT NULL,
   Titre VARCHAR(128) NOT NULL,
   Contenu TEXT,
   PRIMARY KEY(ID_Rapport)
);

CREATE TABLE IF NOT EXISTS Regions(
   ID_Region INT AUTO_INCREMENT,
   Region VARCHAR(128) NOT NULL UNIQUE,
   PRIMARY KEY(ID_Region)
);

CREATE TABLE IF NOT EXISTS Types_gaz(
   ID_Type_gaz INT AUTO_INCREMENT,
   Type VARCHAR(40) NOT NULL,
   PRIMARY KEY(ID_Type_gaz)
);

CREATE TABLE IF NOT EXISTS Villes(
   ID_Ville INT AUTO_INCREMENT,
   Nom_ville VARCHAR(128) NOT NULL UNIQUE,
   ID_Region INT NOT NULL,
   PRIMARY KEY(ID_Ville),
   FOREIGN KEY(ID_Region) REFERENCES Regions(ID_Region) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Agences(
   ID_Agence INT AUTO_INCREMENT,
   Nom_agence VARCHAR(40) NOT NULL,
   Adresse VARCHAR(128) NOT NULL,
   ID_Ville INT NOT NULL,
   PRIMARY KEY(ID_Agence),
   UNIQUE(ID_Ville),
   FOREIGN KEY(ID_Ville) REFERENCES Villes(ID_Ville) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Personnel(
   ID_Personnel INT AUTO_INCREMENT,
   Nom_personnel VARCHAR(40),
   Prenom_personnel VARCHAR(40),
   Date_naissance DATE CHECK(Date_naissance > "1960-01-01"),
   Date_prise_poste DATE,
   Adresse_postale VARCHAR(128),
   Fonction VARCHAR(40) NOT NULL,
   ID_Agence INT NOT NULL,
   UNIQUE (Nom_personnel, Prenom_personnel),
   PRIMARY KEY(ID_Personnel),
   FOREIGN KEY(ID_Agence) REFERENCES Agences(ID_Agence) ON DELETE CASCADE
);

DELIMITER $$
CREATE TRIGGER check_date_prise_poste
BEFORE INSERT ON Personnel
FOR EACH ROW
BEGIN
   IF NEW.Date_prise_poste <= NEW.Date_naissance THEN
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Date de prise de poste doit être supérieure à la date de naissance';
   END IF;
END$$
DELIMITER ;

CREATE TABLE IF NOT EXISTS Gaz(
   ID_Gaz INT AUTO_INCREMENT,
   Nom_gaz VARCHAR(40) NOT NULL UNIQUE,
   Sigle VARCHAR(40) NOT NULL UNIQUE,
   ID_Type_gaz INT NOT NULL,
   PRIMARY KEY(ID_Gaz),
   FOREIGN KEY(ID_Type_gaz) REFERENCES Types_gaz(ID_Type_gaz) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Chef_agence(
   ID_Personnel INT,
   Dernier_diplome VARCHAR(128) NOT NULL,
   PRIMARY KEY(ID_Personnel),
   FOREIGN KEY(ID_Personnel) REFERENCES Personnel(ID_Personnel) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Agent_technique(
   ID_Personnel INT,
   PRIMARY KEY(ID_Personnel),
   FOREIGN KEY(ID_Personnel) REFERENCES Personnel(ID_Personnel) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Agent_administratif(
   ID_Personnel INT,
   PRIMARY KEY(ID_Personnel),
   FOREIGN KEY(ID_Personnel) REFERENCES Personnel(ID_Personnel) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Capteurs(
   ID_Capteur INT AUTO_INCREMENT,
   Actif BOOLEAN NOT NULL,
   ID_Ville INT NOT NULL,
   ID_Personnel INT NOT NULL,
   ID_Gaz INT NOT NULL,
   ID_Agence INT NOT NULL,
   PRIMARY KEY(ID_Capteur),
   FOREIGN KEY(ID_Ville) REFERENCES Villes(ID_Ville) ON DELETE CASCADE,
   FOREIGN KEY(ID_Personnel) REFERENCES Agent_technique(ID_Personnel),
   FOREIGN KEY(ID_Gaz) REFERENCES Gaz(ID_Gaz) ON DELETE CASCADE,
   FOREIGN KEY(ID_Agence) REFERENCES Agences(ID_Agence) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Releves(
   ID_Releve INT AUTO_INCREMENT,
   Nom_releve VARCHAR(128) NOT NULL,
   Date_releve DATE CHECK (Date_releve BETWEEN "2017-01-01" AND "2024-12-31") NOT NULL,
   Valeur DOUBLE NOT NULL,
   ID_Capteur INT NOT NULL,
   PRIMARY KEY(ID_Releve),
   FOREIGN KEY(ID_Capteur) REFERENCES Capteurs(ID_Capteur) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Rediger(
   ID_Rapport INT,
   ID_Personnel INT,
   PRIMARY KEY(ID_Rapport, ID_Personnel),
   FOREIGN KEY(ID_Rapport) REFERENCES Rapports(ID_Rapport) ON DELETE CASCADE,
   FOREIGN KEY(ID_Personnel) REFERENCES Agent_administratif(ID_Personnel) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Dependre(
   ID_Rapport INT,
   ID_Releve INT,
   PRIMARY KEY(ID_Rapport, ID_Releve),
   FOREIGN KEY(ID_Rapport) REFERENCES Rapports(ID_Rapport) ON DELETE CASCADE,
   FOREIGN KEY(ID_Releve) REFERENCES Releves(ID_Releve) ON DELETE CASCADE
);



-- LMD -------------------------------------------------------------------------------------------------------------------

-- Régions ---------------------------------------------------------------------------------------------------------------
INSERT INTO Regions(Region) 
VALUES
("Auvergne-Rhône-Alpes"),
("Bourgogne-Franche-Comté"),
("Bretagne"),
("Centre-Val de Loire"),
("Corse"),
("Grand Est"),
("Hauts-de-France"),
("Île-de-France"),
("Normandie"),
("Nouvelle-Aquitaine"),
("Occitanie"),
("Pays de la Loire"),
("Provence-Alpes-Côte d’Azur");

-- Villes ---------------------------------------------------------------------------------------------------------------
INSERT INTO Villes (Nom_ville, ID_Region) 
VALUES
-- 1. Auvergne-Rhône-Alpes
("Lyon", 1),                     
("Grenoble", 1),           
-- 2. Bourgogne-Franche-Comté
("Dijon", 2),                     
("Besançon", 2),
-- 3. Bretagne
("Rennes", 3),
("Brest", 3),
-- 4. Centre-Val de Loire
("Orléans", 4),
("Tours", 4),
-- 5. Corse
("Ajaccio", 5),
("Bastia", 5),
-- 6. Grand Est
("Strasbourg", 6),
("Metz", 6),
-- 7. Hauts-de-France
("Lille", 7),
("Amiens", 7),
-- 8. Île-de-France
("Paris", 8),
("Versailles", 8),
-- 9. Normandie
("Rouen", 9),
("Caen", 9),
-- 10. Nouvelle-Aquitaine
("Bordeaux", 10),
("Limoges", 10),
-- 11. Occitanie
("Toulouse", 11),
("Montpellier", 11),
-- 12. Pays de la Loire
("Nantes", 12),
("Le Mans", 12),
-- 13. Provence-Alpes-Côte d’Azur
("Marseille", 13),
("Nice", 13);

-- Types de gaz ---------------------------------------------------------------------------------------------------------------
INSERT INTO Types_gaz(Type)
VALUES
("GES"),
("GESI");

-- Gaz ---------------------------------------------------------------------------------------------------------------
INSERT INTO Gaz (Nom_gaz, Sigle, ID_Type_gaz) 
VALUES
("Protoxyde d'azote", "N2O", 1),
("Ozone troposphérique", "O3", 1),
("Méthane", "CH4", 1),
("Hydrofluorocarbures", "HFC", 2),
("Hexafluorure de soufre", "SF6", 2),
("Dioxyde de carbone", "CO2", 1);

-- Agences ---------------------------------------------------------------------------------------------------------------
INSERT INTO Agences (Nom_agence, Adresse, ID_Ville)
VALUES
("ClearData Lyon", "10 rue de la République", 1),          -- 1
("ClearData Dijon", "12 place Darcy", 3),                  -- 2
("ClearData Rennes", "8 boulevard de la Liberté", 5),      -- 3
("ClearData Orléans", "15 rue Jeanne d'Arc", 7),           -- 4
("ClearData Ajaccio", "3 avenue Napoléon", 9),             -- 5
("ClearData Strasbourg", "25 rue des Frères", 11),         -- 6
("ClearData Lille", "6 rue Nationale", 13),                -- 7
("ClearData Paris", "20 avenue des Champs-Élysées", 15),   -- 8
("ClearData Rouen", "18 rue du Gros-Horloge", 17),         -- 9
("ClearData Bordeaux", "30 cours de l’Intendance", 19),    -- 10
("ClearData Limoges", "4 rue François Chénieux", 20),      -- 11
("ClearData Toulouse", "22 allées Jean Jaurès", 21),       -- 12
("ClearData Nantes", "11 rue de Strasbourg", 23),          -- 13
("ClearData Marseille", "5 boulevard Longchamp", 25);      -- 14


-- Procédure Personnel -----------------------------------------------------------------------------------------------------
DELIMITER $$
CREATE PROCEDURE AjouterPersonnel (
    IN p_Nom_personnel VARCHAR(40),
    IN p_Prenom_personnel VARCHAR(40),
    IN p_Date_naissance DATE,
    IN p_Date_prise_poste DATE,
    IN p_Adresse_postale VARCHAR(128),
    IN p_Fonction VARCHAR(40),
    IN p_ID_Agence INT,
    IN p_Dernier_diplome VARCHAR(128)
)
BEGIN

	DECLARE variable_id INT;
    
    IF p_Fonction NOT IN ('chef', 'technique', 'administratif') THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Fonction non valide. Choisir "chef", "technique", ou "administratif".';
    END IF;

    INSERT INTO Personnel (Nom_personnel, Prenom_personnel, Date_naissance, Date_prise_poste, Adresse_postale, Fonction, ID_Agence)
    VALUES (p_Nom_personnel, p_Prenom_personnel, p_Date_naissance, p_Date_prise_poste, p_Adresse_postale, p_Fonction, p_ID_Agence);
    
    SET variable_id = LAST_INSERT_ID();
    
    IF p_Fonction = 'chef' THEN
        INSERT INTO Chef_agence (ID_Personnel, Dernier_diplome) 
        VALUES (variable_id, p_Dernier_diplome);
        
    ELSEIF p_Fonction = 'technique' THEN
        INSERT INTO Agent_technique (ID_Personnel) 
        VALUES (variable_id);
        
    ELSEIF p_Fonction = 'administratif' THEN
        INSERT INTO Agent_administratif (ID_Personnel) 
        VALUES (variable_id);
    END IF;

END$$
DELIMITER ;

-- Personnel ---------------------------------------------------------------------------------------------------------------

-- ClearData Lyon
CALL AjouterPersonnel("Durand", "Claire", "1985-04-12", "2018-06-01", "69003", "chef", 1, "MBA Management");
CALL AjouterPersonnel("Nguyen", "Tien", "1990-02-20", "2019-09-15", "69007", "administratif", 1, NULL);
CALL AjouterPersonnel("Lemoine", "Sophie", "1982-07-03", "2017-03-01", "69008", "technique", 1, NULL);

-- ClearData Dijon
CALL AjouterPersonnel("Patuano", "Alexandre", "1978-11-05", "2017-05-10", "21000", "chef", 2, "Ingénieur Pédagogique");
CALL AjouterPersonnel("Rashid", "Mariam", "1988-12-14", "2018-01-20", "21300", "administratif", 2, NULL);
CALL AjouterPersonnel("Garnier", "Nicolas", "1991-08-09", "2019-04-10", "21000", "technique", 2, NULL);

-- ClearData Rennes
CALL AjouterPersonnel("Giraud", "Marine", "1980-06-25", "2015-07-01", "35000", "chef", 3, "Master RH");
CALL AjouterPersonnel("Toure", "Amadou", "1992-09-18", "2019-02-01", "35200", "administratif", 3, NULL);
CALL AjouterPersonnel("Ruch", "Thomas", "1987-01-12", "2016-11-05", "35700", "technique", 3, NULL);

-- ClearData Orléans
CALL AjouterPersonnel("Perrin", "Alexandre", "1983-10-08", "2016-09-01", "45000", "chef", 4, "MBA International");
CALL AjouterPersonnel("Leroy", "Manon", "1990-03-30", "2018-02-15", "45100", "administratif", 4, NULL);
CALL AjouterPersonnel("Toretto", "Dominic", "1986-05-25", "2019-07-12", "45140", "technique", 4, NULL);

-- ClearData Ajaccio
CALL AjouterPersonnel("Faure", "Céline", "1975-12-03", "2015-01-10", "20000", "chef", 5, "Master Communication");
CALL AjouterPersonnel("Renard", "Benoît", "1991-06-14", "2017-08-25", "20200", "administratif", 5, NULL);
CALL AjouterPersonnel("Hunt", "Ethan", "1989-11-22", "2016-04-18", "20100", "technique", 5, NULL);

-- ClearData Strasbourg
CALL AjouterPersonnel("Millet", "Damien", "1984-02-17", "2017-06-15", "67000", "chef", 6, "Master Gestion");
CALL AjouterPersonnel("Silici-Sieng", "Kenzo", "1993-03-01", "2018-10-03", "67100", "administratif", 6, NULL);
CALL AjouterPersonnel("Benoit", "Arthur", "1987-07-19", "2019-01-10", "67200", "technique", 6, NULL);

-- ClearData Lille
CALL AjouterPersonnel("Hamilton", "Lewis", "1985-08-28", "2016-12-01", "59000", "chef", 7, "MBA Leadership");
CALL AjouterPersonnel("Ali", "Omar", "1994-10-05", "2018-05-15", "59800", "administratif", 7, NULL);
CALL AjouterPersonnel("Collet", "Élodie", "1986-02-14", "2019-03-20", "59160", "technique", 7, NULL);

-- ClearData Paris
CALL AjouterPersonnel("Lampard", "Frank", "1985-04-09", "2018-07-01", "75010", "chef", 8, "Master Finance");
CALL AjouterPersonnel("Mohammed", "Salim", "1990-12-11", "2019-10-25", "75015", "administratif", 8, NULL);
CALL AjouterPersonnel("Verceil", "Baptiste", "1993-01-26", "2017-12-01", "75020", "technique", 8, NULL);

-- ClearData Rouen
CALL AjouterPersonnel("Marchand", "Laura", "1982-03-21", "2016-05-01", "76000", "chef", 9, "Master Communication");
CALL AjouterPersonnel("Bonturi", "Sylvain", "1989-08-02", "2018-01-15", "76100", "administratif", 9, NULL);
CALL AjouterPersonnel("Senghor", "Aissatou", "1991-09-10", "2019-09-10", "76200", "technique", 9, NULL);

-- ClearData Bordeaux
CALL AjouterPersonnel("Jacquet", "Vincent", "1980-07-17", "2015-04-01", "33000", "chef", 10, "Master Management");
CALL AjouterPersonnel("Chavez", "Isabella", "1988-10-29", "2018-06-12", "33100", "administratif", 10, NULL);
CALL AjouterPersonnel("Navarro", "Lucas", "1993-11-15", "2019-02-01", "33200", "technique", 10, NULL);
CALL AjouterPersonnel("Onana", "Amadou", "1980-07-15", "2019-02-01", "33200", "technique", 10, NULL);
CALL AjouterPersonnel("Dupont", "Baptiste", "1971-01-02", "2019-02-01", "33200", "technique", 10, NULL);
CALL AjouterPersonnel("Verso", "Jean", "1998-10-23", "2019-02-01", "33200", "technique", 10, NULL);
CALL AjouterPersonnel("Patouano", "Romuald", "1997-03-01", "2019-02-01", "33200", "technique", 10, NULL);

-- ClearData Limoges (pas de chef)
CALL AjouterPersonnel("Mueller", "Sandra", "1993-01-25", "2019-05-22", "87100", "administratif", 11, NULL);
CALL AjouterPersonnel("Mendès", "Pierre", "1990-09-14", "2017-12-01", "87280", "technique", 11, NULL);

-- ClearData Toulouse
CALL AjouterPersonnel("Perrot", "Audrey", "1984-05-05", "2017-03-01", "31000", "chef", 12, "MBA RH");
CALL AjouterPersonnel("Ferrari", "Ferruccio", "1992-07-11", "2018-12-10", "31100", "administratif", 12, NULL);
CALL AjouterPersonnel("Vargas", "Inès", "1986-09-23", "2019-09-15", "31200", "technique", 12, NULL);

-- ClearData Nantes
CALL AjouterPersonnel("Lambert", "Olivier", "1979-06-06", "2016-08-20", "44000", "chef", 13, "Master Gestion Publique");
CALL AjouterPersonnel("Diaz", "Clara", "1990-01-17", "2019-01-01", "44100", "administratif", 13, NULL);
CALL AjouterPersonnel("Adam", "Quentin", "1994-04-02", "2018-03-05", "44300", "technique", 13, NULL);

-- ClearData Marseille
CALL AjouterPersonnel("Texier", "Julie", "1983-10-16", "2017-10-01", "13001", "chef", 14, "MBA Communication");
CALL AjouterPersonnel("Roy", "Émilie", "1987-05-07", "2019-04-20", "13008", "administratif", 14, NULL);
CALL AjouterPersonnel("Haddou", "Hatim", "1991-12-01", "2018-06-18", "13014", "technique", 14, NULL);

-- Capteurs ------------------------------------------------------------------------------------------------------------------------
INSERT INTO Capteurs (Actif, ID_Ville, ID_Personnel, ID_Gaz, ID_Agence)
VALUES

-- Agence de Lyon : Capteurs de Lyon
(True, 1, 3, 1, 1),            -- 1
(True, 1, 3, 2, 1),
(True, 1, 3, 3, 1),
(True, 1, 3, 4, 1),
(True, 1, 3, 5, 1),
(True, 1, 3, 6, 1),            -- 6
-- Agence de Lyon : Capteurs de Grenoble
(True, 2, 3, 1, 1),            -- 7
(True, 2, 3, 2, 1),
(True, 2, 3, 3, 1),
(True, 2, 3, 4, 1),
(True, 2, 3, 5, 1),
(True, 2, 3, 6, 1),            -- 12


-- Agence de Dijon : Capteurs de Dijon
(True, 3, 6, 1, 2),            -- 13          
(True, 3, 6, 2, 2),
(True, 3, 6, 3, 2),
(True, 3, 6, 4, 2),
(True, 3, 6, 5, 2),
(True, 3, 6, 6, 2),            -- 18
-- Agence de Dijon : Capteurs de Besançon 
(True, 4, 6, 1, 2),            -- 19
(True, 4, 6, 2, 2),
(True, 4, 6, 3, 2),
(True, 4, 6, 4, 2),
(True, 4, 6, 5, 2),
(True, 4, 6, 6, 2),            -- 24


-- Agence de Rennes : Capteurs de Rennes
(True, 5, 9, 1, 3),            -- 25   
(True, 5, 9, 2, 3),
(True, 5, 9, 3, 3),
(True, 5, 9, 4, 3),
(True, 5, 9, 5, 3),
(True, 5, 9, 6, 3),            -- 30    
-- Agence de Rennes : Capteurs de Brest
(True, 6, 9, 1, 3),            -- 31  
(True, 6, 9, 2, 3),
(True, 6, 9, 3, 3),
(True, 6, 9, 4, 3),
(True, 6, 9, 5, 3),
(True, 6, 9, 6, 3),            -- 36  


-- Agence d'Orléans : Capteurs d'Orléans 
(True, 7, 12, 1, 4),           -- 37 
(True, 7, 12, 2, 4),
(True, 7, 12, 3, 4),
(True, 7, 12, 4, 4),
(True, 7, 12, 5, 4),
(True, 7, 12, 6, 4),           -- 42
-- Agence d'Orléans : Capteurs de Tours
(True, 8, 12, 1, 4),           -- 43
(True, 8, 12, 2, 4),
(True, 8, 12, 3, 4),
(True, 8, 12, 4, 4),
(True, 8, 12, 5, 4),
(True, 8, 12, 6, 4),           -- 48

-- Agence d'Ajaccio : Capteurs d'Ajaccio
(True, 9, 15, 1, 5),           -- 49 
(True, 9, 15, 2, 5),
(True, 9, 15, 3, 5),
(True, 9, 15, 4, 5),
(True, 9, 15, 5, 5),
(True, 9, 15, 6, 5),           -- 54
-- Agence d'Ajaccio : Capteurs de Bastia
(True, 10, 15, 1, 5),          -- 55
(True, 10, 15, 2, 5),
(True, 10, 15, 3, 5),
(True, 10, 15, 4, 5),
(True, 10, 15, 5, 5),
(True, 10, 15, 6, 5),          -- 60


-- Agence de Strasbourg : Capteurs de Strasbourg
(True, 11, 18, 1, 6),          -- 61
(True, 11, 18, 2, 6),
(True, 11, 18, 3, 6),
(True, 11, 18, 4, 6),
(True, 11, 18, 5, 6),
(True, 11, 18, 6, 6),          -- 66
-- Agence de Strasbourg : Capteurs de Metz
(True, 12, 18, 1, 6),          -- 67
(True, 12, 18, 2, 6),
(True, 12, 18, 3, 6),
(True, 12, 18, 4, 6),
(True, 12, 18, 5, 6),
(True, 12, 18, 6, 6),          -- 72


-- Agence de Lille : Capteurs de Lille
(True, 13, 21, 1, 7),          -- 73
(True, 13, 21, 2, 7),
(True, 13, 21, 3, 7),
(True, 13, 21, 4, 7),
(True, 13, 21, 5, 7),
(True, 13, 21, 6, 7),          -- 78
-- Agence de Lille : Capteurs d'Amiens
(True, 14, 21, 1, 7),          -- 79
(True, 14, 21, 2, 7),
(True, 14, 21, 3, 7),
(True, 14, 21, 4, 7),
(True, 14, 21, 5, 7),
(True, 14, 21, 6, 7),          -- 84


-- Agence de Paris : Capteurs de Paris
(True, 15, 24, 1, 8),          -- 85
(True, 15, 24, 2, 8),
(True, 15, 24, 3, 8),
(True, 15, 24, 4, 8),
(True, 15, 24, 5, 8),
(True, 15, 24, 6, 8),          -- 90
-- Agence de Paris : Capteurs de Versailles
(True, 16, 24, 1, 8),          -- 91
(True, 16, 24, 2, 8),
(True, 16, 24, 3, 8),
(True, 16, 24, 4, 8),
(True, 16, 24, 5, 8),
(True, 16, 24, 6, 8),          -- 96


-- Agence de Rouen : Capteurs de Rouen 
(True, 17, 27, 1, 9),          -- 97
(True, 17, 27, 2, 9),
(True, 17, 27, 3, 9),
(True, 17, 27, 4, 9),
(True, 17, 27, 5, 9),
(True, 17, 27, 6, 9),          -- 102
-- Agence de Rouen : Capteurs de Caen
(True, 18, 27, 1, 9),          -- 103
(True, 18, 27, 2, 9),
(True, 18, 27, 3, 9),
(True, 18, 27, 4, 9),
(True, 18, 27, 5, 9),
(True, 18, 27, 6, 9),          -- 108


-- Agence de Bordeaux : Capteurs de Bordeaux
(True, 19, 30, 1, 10),         -- 109
(True, 19, 31, 2, 10),
(True, 19, 32, 3, 10),
(True, 19, 33, 4, 10),
(True, 19, 34, 5, 10),
(True, 19, 31, 6, 10),         -- 114


-- Agence de Limoges : Capteurs de Limoges
(True, 20, 36, 1, 11),         -- 115
(True, 20, 36, 2, 11),
(True, 20, 36, 3, 11),
(True, 20, 36, 4, 11),
(True, 20, 36, 5, 11),
(True, 20, 36, 6, 11),         -- 120


-- Agence de Toulouse : Capteurs de Toulouse
(True, 21, 39, 1, 12),         -- 121
(True, 21, 39, 2, 12),
(True, 21, 39, 3, 12),
(True, 21, 39, 4, 12),
(True, 21, 39, 5, 12),
(True, 21, 39, 6, 12),         -- 126
-- Agence de Toulouse : Capteurs de Montpellier
(True, 22, 39, 1, 12),         -- 127
(True, 22, 39, 2, 12),
(True, 22, 39, 3, 12),
(True, 22, 39, 4, 12),
(True, 22, 39, 5, 12),
(True, 22, 39, 6, 12),         -- 132   
 

-- Agence de Nantes : Capteurs de Nantes
(True, 23, 42, 1, 13),         -- 133
(True, 23, 42, 2, 13),
(True, 23, 42, 3, 13),
(True, 23, 42, 4, 13),
(True, 23, 42, 5, 13),
(True, 23, 42, 6, 13),         -- 138
-- Agence de Nantes : Capteurs du Mans
(True, 24, 42, 1, 13),         -- 139
(True, 24, 42, 2, 13),
(True, 24, 42, 3, 13),
(True, 24, 42, 4, 13),
(True, 24, 42, 5, 13),
(True, 24, 42, 6, 13),         -- 144


-- Agence de Marseille : Capteurs de Marseille
(True, 25, 45, 1, 14),        -- 145
(True, 25, 45, 2, 14),
(True, 25, 45, 3, 14),
(True, 25, 45, 4, 14),
(True, 25, 45, 5, 14),
(True, 25, 45, 6, 14),        -- 150
-- Agence de Marseille : Capteurs de Nice
(True, 26, 45, 1, 14),        -- 151
(True, 26, 45, 2, 14),
(True, 26, 45, 3, 14),
(True, 26, 45, 4, 14),
(True, 26, 45, 5, 14),
(True, 26, 45, 6, 14);        -- 156



-- Releves ----------------------------------------------------------------------------------------------------------------------
INSERT INTO Releves (Nom_releve, Date_releve, Valeur, ID_Capteur)
VALUES

-- Tous les relevés de Lyon
("LYO-1-1901", "2019-01-01", 0.33, 1),
("LYO-1-2207", "2022-07-01", 0.34, 1),
("LYO-2-1908", "2019-08-01", 0.032, 2),
("LYO-2-1901", "2019-01-01", 0.028, 2),
("LYO-3-2206", "2022-06-01", 1.99, 3),
("LYO-3-2312", "2023-12-01", 1.96, 3),
("LYO-4-2011", "2020-11-01", 0.00067, 4),
("LYO-4-2010", "2020-10-01", 0.00045, 4),
("LYO-5-2109", "2021-09-01", 0.0001, 5),
("LYO-5-1804", "2018-04-01", 0.0001, 5),
("LYO-6-2102", "2021-02-01", 395.3, 6),
("LYO-6-2103", "2021-03-01", 400.9, 6),


-- Tous les relevés de Grenoble
("GRE-7-1801", "2018-01-01", 0.367, 7),
("GRE-7-2201", "2022-01-01", 0.42, 7),
("GRE-8-1907", "2019-07-01", 0.033, 8),
("GRE-8-2208", "2022-08-01", 0.04, 8),
("GRE-9-2012", "2020-12-01", 2.3, 9),
("GRE-9-2112", "2021-12-01", 2, 9),
("GRE-10-2002", "2020-02-01", 0.00055, 10),
("GRE-10-2010", "2020-10-01", 0.0005, 10),
("GRE-11-2109", "2021-09-01", 0.0001, 11),
("GRE-11-1804", "2018-04-01", 0.0001, 11),
("GRE-12-1703", "2017-03-01", 425.89, 12),
("GRE-12-1803", "2018-03-01", 420.0, 12),

-- Tous les relevés de Dijon
("DIJ-13-1802", "2018-02-01", 0.35, 13),
("DIJ-13-2207", "2022-07-01", 0.39, 13),
("DIJ-14-1905", "2019-05-01", 0.031, 14),
("DIJ-14-2308", "2023-08-01", 0.037, 14),
("DIJ-15-2012", "2020-12-01", 2.2, 15),
("DIJ-15-2209", "2022-09-01", 2.05, 15),
("DIJ-16-2003", "2020-03-01", 0.00049, 16),
("DIJ-16-2401", "2024-01-01", 0.00053, 16),
("DIJ-17-1804", "2018-04-01", 0.0001, 17),
("DIJ-17-2109", "2021-09-01", 0.0001, 17),
("DIJ-18-1706", "2017-06-01", 430.98, 18),
("DIJ-18-2008", "2020-08-01", 421.6, 18),

-- Tous les relevés de Besançon

("BES-19-1901", "2019-01-01", 0.38, 19),
("BES-19-2307", "2023-07-01", 0.41, 19),
("BES-20-1809", "2018-09-01", 0.029, 20),
("BES-20-2402", "2024-02-01", 0.036, 20),
("BES-21-2105", "2021-05-01", 2.1, 21),
("BES-21-2206", "2022-06-01", 2.15, 21),
("BES-22-2001", "2020-01-01", 0.00044, 22),
("BES-22-2303", "2023-03-01", 0.00051, 22),
("BES-23-1803", "2018-03-01", 0.0001, 23),
("BES-23-2109", "2021-09-01", 0.0001, 23),
("BES-24-1711", "2017-11-01", 424.7, 24),
("BES-24-2005", "2020-05-01", 405.2, 24),


-- Tous les relevés de Rennes 
("REN-25-1902", "2019-02-01", 0.31, 25),
("REN-25-2205", "2022-05-01", 0.36, 25),
("REN-26-2101", "2021-01-01", 0.030, 26),
("REN-26-1809", "2018-09-01", 0.027, 26),
("REN-27-2207", "2022-07-01", 1.85, 27),
("REN-27-2305", "2023-05-01", 1.94, 27),
("REN-28-2006", "2020-06-01", 0.00049, 28),
("REN-28-1808", "2018-08-01", 0.00056, 28),
("REN-29-1904", "2019-04-01", 0.0001, 29),
("REN-29-2103", "2021-03-01", 0.0001, 29),
("REN-30-2202", "2022-02-01", 422.1, 30),
("REN-30-2401", "2024-01-01", 410.5, 30),

-- Tous les relevés de Brest 
("BRE-31-2105", "2021-05-01", 0.28, 31),
("BRE-31-2402", "2024-02-01", 0.29, 31),
("BRE-32-1807", "2018-07-01", 0.025, 32),
("BRE-32-2009", "2020-09-01", 0.029, 32),
("BRE-33-2005", "2020-05-01", 1.8, 33),
("BRE-33-2306", "2023-06-01", 2.1, 33),
("BRE-34-1908", "2019-08-01", 0.00053, 34),
("BRE-34-2204", "2022-04-01", 0.0006, 34),
("BRE-35-1709", "2017-09-01", 0.0001, 35),
("BRE-35-2107", "2021-07-01", 0.0001, 35),
("BRE-36-2306", "2023-06-01", 433.2, 36),
("BRE-36-2003", "2020-03-01", 419.6, 36),

-- Tous les relevés d'Orléans
("ORL-37-1903", "2019-03-01", 0.35, 37),
("ORL-37-2403", "2024-03-01", 0.32, 37),
("ORL-38-2008", "2020-08-01", 0.031, 38),
("ORL-38-1803", "2018-03-01", 0.029, 38),
("ORL-39-2106", "2021-06-01", 2.0, 39),
("ORL-39-2212", "2022-12-01", 2.1, 39),
("ORL-40-1806", "2018-06-01", 0.00058, 40),
("ORL-40-2201", "2022-01-01", 0.00054, 40),
("ORL-41-2108", "2021-08-01", 0.0001, 41),
("ORL-41-2404", "2024-04-01", 0.0001, 41),
("ORL-42-2307", "2023-07-01", 417.2, 42),
("ORL-42-1704", "2017-04-01", 425.0, 42),

-- Tous les relevés de Tours 
("TOU-43-1802", "2018-02-01", 0.36, 43),
("TOU-43-2308", "2023-08-01", 0.38, 43),
("TOU-44-1907", "2019-07-01", 0.027, 44),
("TOU-44-2209", "2022-09-01", 0.03, 44),
("TOU-45-2001", "2020-01-01", 2.05, 45),
("TOU-45-2305", "2023-05-01", 1.97, 45),
("TOU-46-1905", "2019-05-01", 0.00061, 46),
("TOU-46-1801", "2018-01-01", 0.00057, 46),
("TOU-47-1706", "2017-06-01", 0.0001, 47),
("TOU-47-2109", "2021-09-01", 0.0001, 47),
("TOU-48-2004", "2020-04-01", 429.4, 48),
("TOU-48-2405", "2024-05-01", 425.9, 48),

-- Tous les relevés d'Ajaccio 
("AJA-49-1805", "2018-05-01", 0.37, 49),
("AJA-49-2402", "2024-02-01", 0.33, 49),
("AJA-50-2301", "2023-01-01", 0.029, 50),
("AJA-50-2009", "2020-09-01", 0.027, 50),
("AJA-51-2203", "2022-03-01", 2.2, 51),
("AJA-51-1901", "2019-01-01", 2.05, 51),
("AJA-52-1707", "2017-07-01", 0.0006, 52),
("AJA-52-2103", "2021-03-01", 0.00052, 52),
("AJA-53-1808", "2018-08-01", 0.0001, 53),
("AJA-53-2309", "2023-09-01", 0.0001, 53),
("AJA-54-2106", "2021-06-01", 412.3, 54),
("AJA-54-2401", "2024-01-01", 423.0, 54),

-- Tous les relevés de Bastia
("BAS-55-2101", "2021-01-01", 0.35, 55),
("BAS-55-2406", "2024-06-01", 0.31, 55),
("BAS-56-2205", "2022-05-01", 0.033, 56),
("BAS-56-1906", "2019-06-01", 0.028, 56),
("BAS-57-1804", "2018-04-01", 1.98, 57),
("BAS-57-2002", "2020-02-01", 2.1, 57),
("BAS-58-2303", "2023-03-01", 0.00057, 58),
("BAS-58-2108", "2021-08-01", 0.0006, 58),
("BAS-59-1903", "2019-03-01", 0.0001, 59),
("BAS-59-1708", "2017-08-01", 0.0001, 59),
("BAS-60-2306", "2023-06-01", 427.7, 60),
("BAS-60-2006", "2020-06-01", 424.9, 60),

-- Tous les relevés de Strasbourg 
("STR-61-1809", "2018-09-01", 0.39, 61),
("STR-61-2407", "2024-07-01", 0.34, 61),
("STR-62-1703", "2017-03-01", 0.031, 62),
("STR-62-2203", "2022-03-01", 0.029, 62),
("STR-63-2301", "2023-01-01", 2.2, 63),
("STR-63-2007", "2020-07-01", 1.95, 63),
("STR-64-1909", "2019-09-01", 0.0006, 64),
("STR-64-1802", "2018-02-01", 0.0005, 64),
("STR-65-2104", "2021-04-01", 0.0001, 65),
("STR-65-2304", "2023-04-01", 0.0001, 65),
("STR-66-1905", "2019-05-01", 439.6, 66),
("STR-66-2402", "2024-02-01", 408.3, 66),

-- Tous les relevés de Metz 
("MET-67-1806", "2018-06-01", 0.29, 67),
("MET-67-2206", "2022-06-01", 0.33, 67),
("MET-68-2008", "2020-08-01", 0.034, 68),
("MET-68-2403", "2024-03-01", 0.028, 68),
("MET-69-2302", "2023-02-01", 2.05, 69),
("MET-69-2105", "2021-05-01", 1.9, 69),
("MET-70-1709", "2017-09-01", 0.00054, 70),
("MET-70-1807", "2018-07-01", 0.0006, 70),
("MET-71-2305", "2023-05-01", 0.0001, 71),
("MET-71-1907", "2019-07-01", 0.0001, 71),
("MET-72-2204", "2022-04-01", 405.7, 72),
("MET-72-2001", "2020-01-01", 425.4, 72),

-- Tous les relevés de Lille 
("LIL-73-2307", "2023-07-01", 0.32, 73),
("LIL-73-2106", "2021-06-01", 0.35, 73),
("LIL-74-1805", "2018-05-01", 0.030, 74),
("LIL-74-1904", "2019-04-01", 0.027, 74),
("LIL-75-2208", "2022-08-01", 2.0, 75),
("LIL-75-1702", "2017-02-01", 2.1, 75),
("LIL-76-2309", "2023-09-01", 0.00052, 76),
("LIL-76-2005", "2020-05-01", 0.00059, 76),
("LIL-77-1803", "2018-03-01", 0.0001, 77),
("LIL-77-2107", "2021-07-01", 0.0001, 77),
("LIL-78-2404", "2024-04-01", 400.0, 78),
("LIL-78-2002", "2020-02-01", 412.7, 78),

-- Tous les relevés d'Amiens
("AMI-79-1901", "2019-01-01", 0.31, 79),
("AMI-79-2207", "2022-07-01", 0.29, 79),
("AMI-80-1908", "2019-08-01", 0.035, 80),
("AMI-80-1901", "2019-01-01", 0.026, 80),
("AMI-81-2206", "2022-06-01", 2.05, 81),
("AMI-81-2312", "2023-12-01", 1.97, 81),
("AMI-82-2011", "2020-11-01", 0.0006, 82),
("AMI-82-2010", "2020-10-01", 0.0005, 82),
("AMI-83-2109", "2021-09-01", 0.0001, 83),
("AMI-83-1804", "2018-04-01", 0.0001, 83),
("AMI-84-2102", "2021-02-01", 420.2, 84),
("AMI-84-2103", "2021-03-01", 422.6, 84),

-- Tous les relevés de Paris
("PAR-85-2001", "2020-01-01", 0.37, 85),
("PAR-85-2207", "2022-07-01", 0.34, 85),
("PAR-86-2001", "2020-01-01", 0.031, 86),
("PAR-86-1908", "2019-08-01", 0.033, 86),
("PAR-87-2006", "2020-06-01", 2.11, 87),
("PAR-87-2312", "2023-12-01", 2.02, 87),
("PAR-88-2010", "2020-10-01", 0.00047, 88),
("PAR-88-2011", "2020-11-01", 0.00062, 88),
("PAR-89-2009", "2020-09-01", 0.0001, 89),
("PAR-89-1804", "2018-04-01", 0.0001, 89),
("PAR-90-2003", "2020-03-01", 445.8, 90),
("PAR-90-2102", "2021-02-01", 439.5, 90),

-- Tous les relvés de Versailles
("VER-91-1901", "2019-01-01", 0.36, 91),
("VER-91-2207", "2022-07-01", 0.35, 91),
("VER-92-1901", "2019-01-01", 0.030, 92),
("VER-92-1908", "2019-08-01", 0.032, 92),
("VER-93-2206", "2022-06-01", 2.06, 93),
("VER-93-2312", "2023-12-01", 2.08, 93),
("VER-94-2010", "2020-10-01", 0.00044, 94),
("VER-94-2011", "2020-11-01", 0.00061, 94),
("VER-95-2109", "2021-09-01", 0.0001, 95),
("VER-95-1804", "2018-04-01", 0.0001, 95),
("VER-96-2103", "2021-03-01", 420.1, 96),
("VER-96-2102", "2021-02-01", 417.3, 96),

-- Tous les relevés de Rouen
("ROU-97-1901", "2019-01-01", 0.32, 97),
("ROU-97-2207", "2022-07-01", 0.33, 97),
("ROU-98-1901", "2019-01-01", 0.029, 98),
("ROU-98-1908", "2019-08-01", 0.034, 98),
("ROU-99-2206", "2022-06-01", 2.14, 99),
("ROU-99-2312", "2023-12-01", 2.01, 99),
("ROU-100-2010", "2020-10-01", 0.00049, 100),
("ROU-100-2011", "2020-11-01", 0.00065, 100),
("ROU-101-2109", "2021-09-01", 0.0001, 101),
("ROU-101-1804", "2018-04-01", 0.0001, 101),
("ROU-102-2103", "2021-03-01", 423.9, 102),
("ROU-102-2102", "2021-02-01", 421.6, 102),

-- Tous les relevés de Caen
("CAE-103-1901", "2019-01-01", 0.35, 103),
("CAE-103-2207", "2022-07-01", 0.36, 103),
("CAE-104-1901", "2019-01-01", 0.027, 104),
("CAE-104-1908", "2019-08-01", 0.031, 104),
("CAE-105-2206", "2022-06-01", 2.19, 105),
("CAE-105-2312", "2023-12-01", 1.94, 105),
("CAE-106-2010", "2020-10-01", 0.00052, 106),
("CAE-106-2011", "2020-11-01", 0.00059, 106),
("CAE-107-2109", "2021-09-01", 0.0001, 107),
("CAE-107-1804", "2018-04-01", 0.0001, 107),
("CAE-108-2103", "2021-03-01", 428.1, 108),
("CAE-108-2102", "2021-02-01", 416.7, 108),

-- Tous les relevés de Bordeaux
("BOR-109-1901", "2019-01-01", 0.38, 109),
("BOR-109-2207", "2022-07-01", 0.39, 109),
("BOR-110-1901", "2019-01-01", 0.034, 110),
("BOR-110-1908", "2019-08-01", 0.037, 110),
("BOR-111-2206", "2022-06-01", 2.12, 111),
("BOR-111-2312", "2023-12-01", 2.00, 111),
("BOR-112-2010", "2020-10-01", 0.00048, 112),
("BOR-112-2011", "2020-11-01", 0.00063, 112),
("BOR-113-2109", "2021-09-01", 0.0001, 113),
("BOR-113-1804", "2018-04-01", 0.0001, 113),
("BOR-114-2103", "2021-03-01", 424.4, 114),
("BOR-114-2102", "2021-02-01", 432.2, 114),

-- Tous les relevés de Limoges
("LIM-115-1901", "2019-01-01", 0.33, 115),
("LIM-115-2207", "2022-07-01", 0.32, 115),
("LIM-116-1901", "2019-01-01", 0.028, 116),
("LIM-116-1908", "2019-08-01", 0.036, 116),
("LIM-117-2206", "2022-06-01", 2.09, 117),
("LIM-117-2312", "2023-12-01", 2.03, 117),
("LIM-118-2010", "2020-10-01", 0.00051, 118),
("LIM-118-2011", "2020-11-01", 0.00057, 118),
("LIM-119-2109", "2021-09-01", 0.0001, 119),
("LIM-119-1804", "2018-04-01", 0.0001, 119),
("LIM-120-2103", "2021-03-01", 417.9, 120),
("LIM-120-2102", "2021-02-01", 419.3, 120),

-- Tous les relevés de Toulouse
("TOU-121-1901", "2019-01-01", 0.37, 121),
("TOU-121-2207", "2022-07-01", 0.35, 121),
("TOU-122-1901", "2019-01-01", 0.032, 122),
("TOU-122-1908", "2019-08-01", 0.033, 122),
("TOU-123-2206", "2022-06-01", 2.08, 123),
("TOU-123-2312", "2023-12-01", 2.05, 123),
("TOU-124-2010", "2020-10-01", 0.00055, 124),
("TOU-124-2011", "2020-11-01", 0.0006, 124),
("TOU-125-2109", "2021-09-01", 0.0001, 125),
("TOU-125-1804", "2018-04-01", 0.0001, 125),
("TOU-126-2103", "2021-03-01", 429.3, 126),
("TOU-126-2102", "2021-02-01", 423.1, 126),

-- Tous les relvés de Montpellier
("MPL-127-1901", "2019-01-01", 0.34, 127),
("MPL-127-2207", "2022-07-01", 0.32, 127),
("MPL-128-1901", "2019-01-01", 0.029, 128),
("MPL-128-1908", "2019-08-01", 0.035, 128),
("MPL-129-2206", "2022-06-01", 2.15, 129),
("MPL-129-2312", "2023-12-01", 2.07, 129),
("MPL-130-2010", "2020-10-01", 0.00053, 130),
("MPL-130-2011", "2020-11-01", 0.00064, 130),
("MPL-131-2109", "2021-09-01", 0.0001, 131),
("MPL-131-1804", "2018-04-01", 0.0001, 131),
("MPL-132-2103", "2021-03-01", 422.8, 132),
("MPL-132-2102", "2021-02-01", 420.7, 132),

-- Tous les relvés de Nantes
("NAN-133-1901", "2019-01-01", 0.35, 133),
("NAN-133-2207", "2022-07-01", 0.36, 133),
("NAN-134-1901", "2019-01-01", 0.030, 134),
("NAN-134-1908", "2019-08-01", 0.032, 134),
("NAN-135-2206", "2022-06-01", 2.13, 135),
("NAN-135-2312", "2023-12-01", 2.09, 135),
("NAN-136-2010", "2020-10-01", 0.00049, 136),
("NAN-136-2011", "2020-11-01", 0.00061, 136),
("NAN-137-2109", "2021-09-01", 0.0001, 137),
("NAN-137-1804", "2018-04-01", 0.0001, 137),
("NAN-138-2103", "2021-03-01", 423.5, 138),
("NAN-138-2102", "2021-02-01", 418.4, 138),

-- Tous les relevés du Mans
("LEM-139-1901", "2019-01-01", 0.36, 139),
("LEM-139-2207", "2022-07-01", 0.33, 139),
("LEM-140-1901", "2019-01-01", 0.028, 140),
("LEM-140-1908", "2019-08-01", 0.034, 140),
("LEM-141-2206", "2022-06-01", 2.16, 141),
("LEM-141-2312", "2023-12-01", 2.04, 141),
("LEM-142-2310", "2023-06-01", 0.00044, 142),
("LEM-142-2311", "2023-07-01", 0.00063, 142),
("LEM-143-2109", "2021-09-01", 0.0001, 143),
("LEM-143-1804", "2018-04-01", 0.0001, 143),
("LEM-144-2103", "2021-03-01", 414.1, 144),
("LEM-144-2102", "2021-02-01", 411.0, 144),

-- Tous les relevés de Marseille
("MAR-145-1901", "2019-01-01", 0.33, 145),
("MAR-145-2207", "2022-07-01", 0.34, 145),
("MAR-146-1901", "2019-01-01", 0.031, 146),
("MAR-146-1908", "2019-08-01", 0.036, 146),
("MAR-147-2206", "2022-06-01", 2.12, 147),
("MAR-147-2312", "2023-12-01", 2.06, 147),
("MAR-148-2010", "2020-10-01", 0.00055, 148),
("MAR-148-2011", "2020-11-01", 0.0006, 148),
("MAR-149-2109", "2021-09-01", 0.0001, 149),
("MAR-149-1804", "2018-04-01", 0.0001, 149),
("MAR-150-2103", "2021-03-01", 429.0, 150),
("MAR-150-2102", "2021-02-01", 428.6, 150),

-- Tous les relevés de Nice 
("NIC-151-1901", "2019-01-01", 0.34, 151),
("NIC-151-2207", "2022-07-01", 0.36, 151),
("NIC-152-1901", "2019-01-01", 0.033, 152),
("NIC-152-1908", "2019-08-01", 0.037, 152),
("NIC-153-2206", "2022-06-01", 2.14, 153),
("NIC-153-2312", "2023-12-01", 2.10, 153),
("NIC-154-2010", "2020-10-01", 0.00056, 154),
("NIC-154-2011", "2020-11-01", 0.00063, 154),
("NIC-155-2109", "2021-09-01", 0.0001, 155),
("NIC-155-1804", "2018-04-01", 0.0001, 155),
("NIC-156-2108", "2021-08-01", 430.0, 156),
("NIC-156-2208", "2022-08-01", 421.5, 156);



-- Rapports ----------------------------------------------------------------------------------------------------------------------
INSERT INTO Rapports(Date_rapport, Titre, Contenu)
VALUES 
("2022-09-24", "Concentration en CO2 en baisse à Nice, en août.", "Nos récents relevés de valeurs effectués par les capteurs de Nice montrent une diminution drastique du CO2 dans l'air d'une année à une autre, en l'occurence de 2021 à 2022. Un rapport qui témoigne de l'efficacité des mesures mises en palce par la mairie."),
("2024-05-02", "Hexafluorure de soufre en Nouvelle-Aquitaine.", "Observation d'une nette stabilité au niveau des taux d'hexafluorure de soufre dans la région Nouvelle-Aquitaine : les deux agences situées là-bas nous informent que les concentrations en SF6 de Bordeaux et Limoges se sont stabilisées autour de 0.0001 ppm."),
("2020-03-15", "Augmentation linéaire d'ozone en Occitanie.", "L'agence de Toulouse nous communique une augmentation significative du taux d'ozone (O3) dans l'air durant l'année 2019, de janvier à août, et ce dans ses deux villes principales : Toulouse et Montpellier."),
("2021-04-20", "Lyon en dessous de la moyenne nationale en début d'année.", "C'est bien Lyon qui s'est montrée la plus propre en ce début d'année 2021 : de janvier à début mars, sa moyenne de concentration de dioxyde de carbone s'élevait proche de 400 ppm soit 20 ppm en dessous de la moyenne française en 2019."),
("2022-01-30", "Région parisienne plus polluée que les autres.", "Ces 3 dernières années, la région parisienne à toujours été la plus polluée de France, en effet, l'air francilien dépasse toutes les moyennes depuis 2019 avec des taux de CO2, de CH4 et de N20 bien au delà des autres régions : la densité de population expliquerait ce phénomène."),
("2024-12-06", "Hydrofluorocarbures à Besançon : 5 dernières années.", "La ville de Besançon présente un bilan positif au niveau des concentrations d'Hydrofluorocarbures : sur les 5 dernières années, leur concentration s'est presque toujours située en dessous de la valeur moyenne de 0.0005 ppm."),
("2021-10-28", "Dioxyde de carbone en Normandie durant l'hiver 2021.", "Nos capteurs situés à Rouen et à Caen, en Normandie nous indiquent des taux de CO2 dans l'atmoshpère dépassant les 420 ppm moyens, s'élevant parfois même à 430, ce qui est peu commun puisque c'est lors des mois de janvier, février et mars, soit en hiver."),
("2023-09-16", "Comparaison des niveaux de protoxyde d'azote entre Marseille et Bordeaux avant 2023.", "En 2022, une certaine stabilité a été observée dans le sud du pays, au niveau des concentrations de protoxyde d'azote N2O, s'élevant et se stabilisant autour de 0.36 ppm. Ce rapport se base sur les deux plus grandes agences du sud de la France pour constater une stabilité sur une année entière."),
("2023-07-20", "Taux d'hydrocarbures au Mans, été 2023.", "Durant l'été 2023, principalement de juin à juillet, les taux de HFC ont largement augmenté au Mans, passant de 0.00044 à 0.00063 ppm. Cela s'expliquerait par le centenaire des 24h du Mans et toute l'affluence que l'évènement à apporté à la ville, ce qui a affolé nos capteurs."),
("2023-10-16", "Les concentrations de méthane CH4 à Rennes.", "Depuis 2 ans, la ville de Rennes présente une concentration de méthane en dessous de 2 ppm (1.85 en 2022 et 1.94 en 2023), et principalement lors des saisons été et hiver, (données de mars et juillet). C'est alors la seule ville à se situer en dessous du 2 ppm symbolique. A étudier...");


-- Dependre ---------------------------------------------------------------------------------------------------------------------
INSERT INTO Dependre(ID_Rapport, ID_Releve)
VALUES
(1, 311),
(1, 312),
(2, 237),
(2, 238),
(2, 225),
(2, 226),
(3, 243),
(3, 244),
(3, 255),
(3, 256),
(4, 11),
(4, 12),
(5, 179),
(5, 180),
(5, 176),
(5, 169),
(5, 174),
(6, 43),
(6, 44),
(7, 203),
(7, 204),
(7, 215),
(7, 216),
(8, 217),
(8, 218),
(9, 283),
(9, 284),
(10, 53),
(10, 54);



-- Rediger -------------------------------------------------------------------------------------------------------------------------
INSERT INTO Rediger(ID_Rapport, ID_Personnel)
VALUES 
(1, 44),
(2, 23),
(3, 29),
(3, 35),
(4, 2),
(4, 5),
(5, 17),
(6, 8),
(7, 26),
(8, 38),
(9, 38),
(10, 20);



-- 1. Liste de l'ensemble des agences
SELECT Nom_agence AS "Noms des agences" FROM Agences;

-- 2. Liste de l'ensemble du personnel technique de l'agence de Bordeaux
SELECT P.Nom_personnel AS "Nom", P.Prenom_personnel AS "Prénom"
FROM (SELECT Nom_personnel, Prenom_personnel, ID_Personnel, ID_Agence FROM Personnel) P
NATURAL JOIN Agent_technique T 
NATURAL JOIN (SELECT ID_Agence, ID_Ville FROM Agences) A 
NATURAL JOIN (SELECT ID_Ville, Nom_ville FROM Villes) V 
WHERE V.Nom_ville = "Bordeaux";

-- 3. Nombre total de capteurs déployés
SELECT COUNT(*) AS "Nombre de capteurs déployés"
FROM (SELECT ID_Capteur, Actif FROM Capteurs) C WHERE C.Actif = True;

-- 4. Liste des rapports publiés entre 2018 et 2022
SELECT Titre AS "Titre du rapport"
FROM (SELECT Titre, Date_rapport FROM Rapports) r
WHERE r.Date_rapport BETWEEN '2018-01-01' AND '2022-12-31';

-- 5. Afficher les concentrations de CH4 (en ppm) dans les régions « Ile-de-France », « Bretagne » et « Occitanie » en mai et juin 2023
SELECT g.Nom_gaz AS "Gaz", g.Sigle, r.Region AS "Région", re.Valeur as "Concentration (ppm)"
FROM (SELECT ID_Gaz, Nom_gaz, Sigle FROM Gaz) g
NATURAL JOIN (SELECT ID_Capteur, ID_Gaz, ID_Agence FROM Capteurs) c 
NATURAL JOIN (SELECT ID_Releve, ID_Capteur, Date_releve, Valeur FROM Releves) re 
NATURAL JOIN (SELECT ID_Agence, ID_Ville FROM Agences) a 
NATURAL JOIN (SELECT ID_Ville, ID_Region FROM Villes) v 
NATURAL JOIN (SELECT ID_Region, Region FROM Regions) r 
WHERE g.Sigle = 'CH4'
AND r.Region IN ('Ile-de-France', 'Bretagne', 'Occitanie')
AND re.Date_releve BETWEEN '2023-05-01' AND '2023-06-30';

-- 6. Liste des noms des agents techniques maintenant des capteurs concernant les gaz à effet de serre provenant de l’industrie (GESI)
SELECT p.Nom_personnel AS "Nom", p.Prenom_personnel AS "Prénom"
FROM (SELECT ID_Personnel FROM Agent_technique) at
NATURAL JOIN (SELECT ID_Personnel, Nom_personnel, Prenom_personnel FROM Personnel) p 
NATURAL JOIN (SELECT ID_Capteur, ID_Personnel, ID_Gaz FROM Capteurs) c 
NATURAL JOIN (SELECT ID_Gaz, ID_Type_gaz FROM Gaz) g 
NATURAL JOIN (SELECT ID_Type_gaz, Type FROM Types_gaz) tg 
WHERE tg.Type = 'GESI'
GROUP BY p.Nom_personnel, p.Prenom_personnel;

-- 7. Titres et dates des rapports concernant des concentrations de CH4, classés par ordre anti-chronologique
SELECT R.Titre AS "Titre du rapport", R.Date_rapport AS "Date de publication" 
FROM (SELECT ID_Rapport, Date_rapport, Titre FROM Rapports) R
NATURAL JOIN Dependre D 
NATURAL JOIN (SELECT ID_Releve, ID_Capteur FROM Releves) re 
NATURAL JOIN (SELECT ID_Capteur, ID_Gaz FROM Capteurs) C 
NATURAL JOIN (SELECT ID_Gaz, Sigle FROM Gaz) G 
WHERE G.Sigle = 'CH4'
GROUP BY R.Titre, R.Date_rapport
ORDER BY R.Date_rapport DESC;

-- 8. Afficher le mois où la concentration de HFC a été la moins importante pour chaque région
SELECT r.region AS "Région", g.nom_gaz AS "Gaz", g.Sigle, MONTH(re.date_releve) AS Mois, re.valeur AS "Plus petite valeur de concentration"
FROM Regions r
NATURAL JOIN (Select id_ville, id_region from Villes) v
NATURAL JOIN (Select id_capteur, id_gaz, id_ville from Capteurs) c
NATURAL JOIN (Select id_gaz, nom_gaz, sigle from Gaz) g
NATURAL JOIN (Select valeur, date_releve, id_capteur from Releves) re
JOIN (
    SELECT r2.region, g2.sigle, MIN(re2.valeur) AS min_valeur
    FROM Regions r2
    NATURAL JOIN (Select id_ville, id_region from Villes) v2
    NATURAL JOIN (Select id_capteur, id_gaz, id_ville from Capteurs) c2
    NATURAL JOIN (Select id_gaz, nom_gaz, sigle from Gaz) g2
    NATURAL JOIN (Select valeur, date_releve, id_capteur from Releves) re2
    WHERE g2.sigle = "HFC"
    GROUP BY r2.region, g2.sigle
) 
AS minimaux ON r.region = minimaux.region AND g.sigle = minimaux.sigle AND re.valeur = minimaux.min_valeur
WHERE g.sigle = "HFC"
ORDER BY r.region;

-- 9. Moyenne des concentrations (en ppm) dans la région « Ile-de-France » en 2020, pour chaque gaz étudié
SELECT g.Nom_gaz AS "Gaz", r.Region AS "Région", AVG(re.Valeur) AS "Moyenne des concentrations (en ppm)"
FROM (SELECT ID_Capteur, ID_Gaz, ID_Agence FROM Capteurs) c
NATURAL JOIN (SELECT ID_Releve, ID_Capteur, Valeur, Date_releve FROM Releves) re
NATURAL JOIN (SELECT ID_Gaz, Nom_gaz FROM Gaz) g 
NATURAL JOIN (SELECT ID_Agence, ID_Ville FROM Agences) a 
NATURAL JOIN (SELECT ID_Ville, ID_Region FROM Villes) v 
NATURAL JOIN (SELECT ID_Region, Region FROM Regions) r 
WHERE r.Region = 'Ile-de-France'
AND YEAR(re.Date_releve) = 2020
GROUP BY g.Nom_gaz;

-- 10. Taux de productivité des agents administratifs de l'agence de Toulouse
SELECT P.Nom_personnel AS "Nom de l'agent", P.Prenom_personnel AS "Prénom de l'agent", ((COUNT(DISTINCT R.ID_Rapport) / NULLIF(TIMESTAMPDIFF(MONTH, P.Date_prise_poste, CURDATE()), 0))*100) AS "Taux de productivité (%)"
FROM Personnel P
NATURAL JOIN Agent_administratif at 
NATURAL JOIN (Select id_agence, id_ville from Agences) a
NATURAL JOIN (Select id_ville, nom_ville from Villes) V 
NATURAL JOIN Rediger Rg 
NATURAL JOIN Rapports R 
WHERE V.Nom_ville = 'Toulouse'
GROUP BY P.ID_Personnel;

-- 11. Pour un gaz donné, liste des rapports contenant des données qui le concernent

DROP PROCEDURE IF EXISTS Requete11;

DELIMITER $$
CREATE PROCEDURE Requete11(IN sigleGaz VARCHAR(255))
BEGIN
    SELECT DISTINCT 
        Rapports.ID_Rapport, 
        Rapports.Titre, 
        Rapports.Date_rapport, 
        Rapports.Contenu
    FROM Rapports
    JOIN Rediger ON Rapports.ID_Rapport = Rediger.ID_Rapport
    JOIN Dependre ON Rapports.ID_Rapport = Dependre.ID_Rapport
    JOIN Releves ON Dependre.ID_Releve = Releves.ID_Releve
    JOIN Capteurs ON Releves.ID_Capteur = Capteurs.ID_Capteur
    JOIN Gaz ON Capteurs.ID_Gaz = Gaz.ID_Gaz
    WHERE Gaz.Sigle = sigleGaz;
END $$

DELIMITER ;

CALL Requete11("CO2");

-- 12. Liste des régions dans lesquelles il y a plus de capteurs que de personnel d’agence
SELECT R.Region, COUNT(DISTINCT C.ID_Capteur) AS Nombre_Capteurs, COUNT(DISTINCT P.ID_Personnel) AS Nombre_Personnel
FROM (SELECT ID_Region, Region FROM Regions) R
JOIN (SELECT ID_Ville, ID_Region FROM Villes) V ON V.ID_Region = R.ID_Region
JOIN (SELECT ID_Agence, ID_Ville FROM Agences) A ON A.ID_Ville = V.ID_Ville
LEFT JOIN (SELECT ID_Capteur, ID_Agence FROM Capteurs) C ON C.ID_Agence = A.ID_Agence
LEFT JOIN (SELECT ID_Personnel, ID_Agence FROM Personnel) P ON P.ID_Agence = A.ID_Agence
GROUP BY R.Region
HAVING COUNT(DISTINCT C.ID_Capteur) > COUNT(DISTINCT P.ID_Personnel);


