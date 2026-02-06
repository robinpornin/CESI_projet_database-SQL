# Projet Bases de données – CESI Nice

🎓 Étudiant : Robin Pornin  
📅 2ème année Cycle préparatoire – Spécialité Informatique  

## Contexte
Le ministère de la Transition Écologique souhaite centraliser et fiabiliser les données sur la qualité de l’air dans les grandes villes de France. Ce projet vise à créer une base de données relationnelle capable de stocker :  
- les mesures de pollution atmosphérique,  
- la structure des agences régionales et leur personnel,  
- les capteurs utilisés,  
- et les rapports d’analyse produits.  

La base permet la consultation, l’ajout et la suppression de données, tout en respectant l’intégrité et le RGPD.

## Structure de la base
Tables principales :  
- **Regions, Villes, Agences**  
- **Personnel, Agent_administratif, Agent_technique**  
- **Capteurs, Gaz, Releves**  
- **Rapports, Dependre, Rediger**  

Contraintes mises en place :  
- Clés primaires auto-incrémentées  
- Clés étrangères avec `ON DELETE CASCADE` là où nécessaire  
- Contraintes CHECK sur les dates et valeurs critiques  

## Peuplement de la base
- 13 régions, 2 villes par région  
- 14 agences, 41 employés minimum  
- 6 capteurs par ville, 2 relevés par capteur → 312 relevés  
- 10 rapports minimum  

## Requêtes SQL travaillées
1. Liste de l'ensemble des agences  
2. Liste du personnel technique de l'agence de Bordeaux  
3. Nombre total de capteurs  
4. Rapports publiés entre 2018 et 2022  
5. Concentrations de CH4 en Ile-de-France, Bretagne et Occitanie en mai/juin 2023  
6. Agents techniques des GESI  
7. Titres et dates des rapports sur CH4 (ordre anti-chronologique)  
8. Mois avec concentration minimale de HFC par région  
9. Moyenne des concentrations par gaz pour Ile-de-France en 2020  
10. Taux de productivité des agents administratifs à Toulouse  
11. Rapports liés à un gaz donné (paramètre)  
12. Régions avec plus de capteurs que de personnel  

## Librairies / outils utilisés
- MySQL / SQLite  
- Python : `sqlite3`, `pandas`, `matplotlib` (optionnel pour visualisation)  

## Visualisations
Toutes les captures d’écran des tables et requêtes sont disponibles dans le dossier `assets/`.

