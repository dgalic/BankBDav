-- Creation de type
CREATE TYPE type_paiement AS ENUM ('especes','cheque','carte','virement');
CREATE TYPE type_compte AS ENUM('AND', 'OR');

-- Creation des tables
CREATE TABLE personne (
    id_personne SERIAL UNIQUE PRIMARY KEY,
    nom_personne TEXT NOT NULL,
    prenom_personne TEXT NOT NULL
);

CREATE TABLE banque (
    id_banque SERIAL PRIMARY KEY,
    nom_banque TEXT NOT NULL,
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
    depassement_autorise BOOLEAN NOT NULL,
    portee VARCHAR(20) NOT NULL,
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
    depassement_autorise BOOLEAN NOT NULL,
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

CREATE TABLE virement (
    id_virement SERIAL PRIMARY KEY,
    id_debiteur INTEGER REFERENCES compte_personne(id_compte_personne),
    id_crediteur INTEGER REFERENCES compte_personne(id_compte_personne),
    montant REAL NOT NULL,
    cout_initial REAL NOT NULL,
    date_virement INTEGER NOT NULL,
    intervalle INTEGER,
    cout_periodique REAL,
     CHECK( intervalle IN(0,1,3,6,13) )
);

CREATE TABLE plan_virements(
       id_virement INTEGER REFERENCES virement,
       date_prochain INTEGER
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
    motif VARCHAR(40) , --TODO : créer un type motif
    date_debut INTEGER NOT NULL,
    date_regularisation INTEGER DEFAULT NULL
);

CREATE TABLE plan_remunerations(
    id_cp INTEGER REFERENCES compte_personne(id_compte_personne),
    date_prochain INTEGER
);

CREATE TABLE carte (
    id_carte SERIAL,
    id_compte_personne INTEGER REFERENCES compte_personne(id_compte_personne),
    UNIQUE(id_carte)
);

CREATE TABLE carte_retrait (
    portee varchar NOT NULL,
    montant_atomique_banque REAL NOT NULL, 
    montant_atomique_autre REAL,
    montant_hebdomadaire_banque REAL NOT NULL, 
    montant_hebdomadaire_autre REAL,
    depassement_autorise BOOLEAN NOT NULL,
    id_compte_personne INTEGER REFERENCES compte_personne(id_compte_personne)
) INHERITS (carte);

CREATE TABLE carte_paiement (
    portee varchar NOT NULL,
    debit_differe BOOLEAN NOT NULL,
    cout_annuel REAL NOT NULL,
    prestige varchar(20),
    id_compte_personne INTEGER REFERENCES compte_personne(id_compte_personne)
) INHERITS (carte);

CREATE TABLE carte_credit (
    revolving REAL check (revolving >= 0 ) NOT NULL,
    id_compte_personne INTEGER REFERENCES compte_personne(id_compte_personne)
) INHERITS (carte);

