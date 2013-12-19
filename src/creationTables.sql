-- Nettoyage de la base de donnees
DROP TABLE temps CASCADE;
DROP TABLE personne CASCADE;
DROP TABLE banque CASCADE;
DROP TABLE distribtuteur CASCADE;
DROP TABLE compte CASCADE;
DROP TABLE compte_joint CASCADE;


-- Creation des tables
CREATE TABLE temps (
    jour int CHECK (jour > 0) NOT NULL,
    idx int DEFAULT 1 CHECK (idx=1) PRIMARY KEY
);

CREATE TABLE personne (
       id_personne serial PRIMARY KEY,
       nom varchar(20) NOT NULL,
       prenom varchar(20) NOT NULL,
);

CREATE TABLE banque (
    id_banque serial PRIMARY KEY,
    nom varchar(20) NOT NULL
);

CREATE TABLE distributeur (
    id_distributeur serial PRIMARY KEY,
    id_banque int REFERENCES banque(id_banque)
);

CREATE TABLE compte (
    id_compte int NOT NULL,
    id_banque int REFERENCES banque(id_banque),
    id_personne int REFERENCES personne(id_personne),
    seuil_remuneration real NOT NULL,
    periode_remuneration int NOT NULL,
    taux remuneration real NOT NULL,
    decouvert_autorise real NOT NULL,
    taux_decouvert real NOT NULL,
    depassement boolean NOT NULL,
    agios real NOT NULL
);
CREATE TABLE compte_joint (
    id_compte int NOT NULL,
    id_banque int REFERENCES banque(id_banque)
    id_personne int REFERENCES personne(id_personne),
    type_compte varchar(2) ch
    id_mandataire int REFERENCES personne(id_personne),
);
