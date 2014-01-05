-- Nettoyage de la base de donnees
DROP TABLE interdit_bancaire;
DROP TABLE historique CASCADE;
DROP TABLE compte_personne CASCADE;
DROP TABLE compte CASCADE;
DROP TABLE distributeur CASCADE;
DROP TABLE personne CASCADE;
DROP TABLE banque_reference CASCADE;
DROP TABLE banque CASCADE;
DROP TABLE temps CASCADE;

-- Creation de type
DROP TYPE type_compte;
DROP TYPE type_paiement;

-- Creation de type
CREATE TYPE type_compte AS ENUM ('AND','OR');
CREATE TYPE type_paiement AS ENUM ('espece','cheque','carte','virement');

-- Creation des tables
CREATE TABLE personne (
    id_personne SERIAL PRIMARY KEY,
    nom_personne TEXT NOT NULL,
    prenom_personne TEXT NOT NULL
);

CREATE TABLE banque (
    id_banque SERIAL PRIMARY KEY,
    nom_banque VARCHAR(25) NOT NULL,
    nombre_compte INTEGER DEFAULT 0
);

CREATE TABLE banque_reference (
    seuil_remuneration REAL NOT NULL,
    periode_remuneration INTEGER NOT NULL,
    taux_remuneration REAL NOT NULL,
    decouvert_autorise REAL NOT NULL,
    taux_decouvert REAL NOT NULL,
    agios REAL NOT NULL,
    atom_banque REAL NOT NULL,
    hebdo_banque REAL NOT NULL,
    anti_decouvert BOOL NOT NULL,
    portee VARCHAR(10) NOT NULL,
    cout REAL NOT NULL,
    atom_autre REAL,
    hebdo_autre REAL,
    id_banque INTEGER REFERENCES banque(id_banque)
);    

CREATE TABLE distributeur (
    id_distributeur SERIAL PRIMARY KEY,
    id_banque INTEGER REFERENCES banque(id_banque)
);

CREATE TABLE compte (
    id_compte INTEGER,
    solde_compte REAL DEFAULT 0,
    seuil_remuneration REAL NOT NULL,
    periode_remuneration INTEGER NOT NULL,
    taux_remuneration REAL NOT NULL,
    decouvert_autorise REAL NOT NULL,
    taux_decouvert REAL NOT NULL,
    depassement BOOLEAN NOT NULL,
    agios REAL NOT NULL,
    chequier BOOLEAN NOT NULL,
    typ_compte type_compte DEFAULT NULL,
    id_banque INTEGER REFERENCES banque(id_banque),
    PRIMARY KEY (id_compte, id_banque)
);

CREATE TABLE compte_personne (
    id_compte_personne SERIAL PRIMARY KEY,
    id_compte INTEGER,
    id_banque INTEGER,
    id_personne INTEGER REFERENCES personne(id_personne),
    FOREIGN KEY (id_compte, id_banque) REFERENCES compte (id_compte, id_banque)
);

CREATE TABLE historique (
    jour INTEGER CHECK (jour > 0),
    id_compte_personne INTEGER REFERENCES compte_personne(id_compte_personne),
    paiement type_paiement NOT NULL,
    montant REAL NOT NULL
);

CREATE TABLE interdit_bancaire (
    id_banque INTEGER REFERENCES banque(id_banque) NOT NULL,
    id_client INTEGER REFERENCES personne(id_personne) NOT NULL,
    motif varchar(20) , --TODO : créer un type motif
    date_debut INTEGER NOT NULL,
    date_regularisation INTEGER DEFAULT NULL
)
