-- Nettoyage de la base de donnees
DROP TABLE historique CASCADE;
DROP TABLE virement CASCADE;
DROP TABLE compte CASCADE;
DROP TABLE compte_joint CASCADE;
DROP TABLE distributeur CASCADE;
DROP TABLE personne CASCADE;
DROP TABLE banque CASCADE;
DROP TABLE temps CASCADE;

-- Creation de type
DROP TYPE type_compte;
DROP TYPE type_paiement;

-- Creation de type
CREATE TYPE type_compte AS ENUM ('ET','OR');
CREATE TYPE type_paiement AS ENUM ('espece','cheque','carte','virement');

-- Creation des tables
CREATE TABLE temps (
    jour int CHECK (jour > 0) NOT NULL,
    idx int DEFAULT 1 CHECK (idx=1) PRIMARY KEY
);

CREATE TABLE personne (
       id_personne serial PRIMARY KEY,
       nom varchar(20) NOT NULL,
       prenom varchar(20) NOT NULL
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
    taux_remuneration real NOT NULL,
    decouvert_autorise real NOT NULL,
    taux_decouvert real NOT NULL,
    depassement boolean NOT NULL,
    agios real NOT NULL,
    chequier boolean NOT NULL,
    PRIMARY KEY (id_compte,id_banque)
);
CREATE TABLE compte_joint (
    id_compte int NOT NULL,
    id_banque int REFERENCES banque(id_banque),
    id_personne int REFERENCES personne(id_personne),
    compte type_compte NOT NULL 
);

CREATE TABLE virement (
    id_virement serial PRIMARY KEY,
    id_banque int REFERENCES banque(id_banque),
    id_personne int REFERENCES personne(id_personne),
    montant real NOT NULL,
    cout_initial real NOT NULL,
    date_virement int NOT NULL,
    intervalle int ,
    cout_periodique real
);

CREATE TABLE historique (
    jour int CHECK (jour > 0),
    id_banque int REFERENCES banque(id_banque),
    id_personne int REFERENCES personne(id_personne),
    paiement type_paiement NOT NULL,
    montant real NOT NULL
);
