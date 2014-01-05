-- Nettoyage des fonctions du fichier transaction_bancaire.sql
DROP FUNCTION ouverture_compte
(nom TEXT, prenom TEXT, n_banque TEXT,
    seuil_rem REAL,
    periode_rem INTEGER,
    taux_rem REAL,
    decouvert REAL,
    taux_dec REAL,
    nb_agios REAL);
DROP FUNCTION fermeture_compte(client_id INTEGER, banque_id INTEGER ,compte_id INTEGER);
DROP FUNCTION fermeture_compte(nom_client TEXT, prenom_client TEXT, client_banque TEXT, identifiant_compte int);
DROP FUNCTION consultation_solde(nom TEXT, prenom text);
DROP FUNCTION consultation_historique(id_client_compte INTEGER);
DROP FUNCTION depot (id_client_compte INTEGER, montant_depot REAL, moyen_paiement type_paiement);
DROP FUNCTION retrait(_id_client INTEGER, _id_compte INTEGER, _id_banque INTEGER, montant REAL);
-- Nettoyage des fonctions du fichier fonction.sql
DROP FUNCTION list_personne();
DROP FUNCTION list_banque();
DROP FUNCTION is_personne(nom TEXT, prenom text);
DROP FUNCTION is_banque(nom text);
DROP FUNCTION is_interdit_bancaire(client int);
DROP FUNCTION creation_banque
(nom_b VARCHAR(25),
seuil_rem REAL,
periode_rem INTEGER,
taux_rem REAL,
decouvert REAL,
taux_dec REAL,
agios REAL,
atom_banque REAL,
hebdo_banque REAL,
anti_dec BOOLEAN,
portee VARCHAR(10),
cout REAL,
atom_autre REAL,
hebdo_autre INTEGER );
DROP FUNCTION consulte_solde(id_compte INTEGER, id_banque INTEGER);
DROP FUNCTION is_compte_personne(client_id INTEGER, compte_id INTEGER, banque_id INTEGER);
DROP FUNCTION to_compte_personne(client_id INTEGER, compte_id INTEGER, banque_id INTEGER);
DROP FUNCTION from_compte_personne(id INTEGER);
DROP FUNCTION from_compte_personne(id INTEGER);


-- Nettoyage de la base de donnees
DROP TABLE interdit_bancaire;
DROP TABLE historique CASCADE;
DROP TABLE compte_personne CASCADE;
DROP TABLE compte CASCADE;
DROP TABLE distributeur CASCADE;
DROP TABLE personne CASCADE;
DROP TABLE banque_reference CASCADE;
DROP TABLE banque CASCADE;

-- Nettoyage des types
DROP TYPE type_compte;
DROP TYPE type_paiement;