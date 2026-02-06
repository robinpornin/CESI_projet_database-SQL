DROP DATABASE IF EXISTS bdd_robin;
CREATE DATABASE IF NOT EXISTS bdd_robin;
USE bdd_robin;

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
