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
