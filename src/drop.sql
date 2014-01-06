
-- Nettoyage des Triggers
DROP TRIGGER IF EXISTS t_interdit_carte ON carte;
DROP TRIGGER IF EXISTS t_interdit_paiement ON carte_paiement;
DROP TRIGGER IF EXISTS t_interdit_credit ON carte_credit;
DROP TRIGGER IF EXISTS t_interdit_retrait ON carte_retrait;

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
DROP FUNCTION retrait(id_client_compte INTEGER, montant_retrait REAL, moyen_paiement type_paiement);
DROP FUNCTION depot_cheque (id_dest INTEGER, montant_depot REAL, id_src INTEGER);
DROP FUNCTION check_liberations();
DROP FUNCTION check_decouverts();
DROP FUNCTION plan_remuneration();

-- Nettoyage des fonctions du fichier fonction.sql
DROP FUNCTION list_personne();
DROP FUNCTION list_banque();
DROP FUNCTION is_personne(nom TEXT, prenom text);
DROP FUNCTION is_banque(nom text);
DROP FUNCTION is_interdit_bancaire(client int);
DROP FUNCTION creation_banque
(nom_b TEXT,
seuil_rem REAL,
periode_rem INTEGER,
taux_rem REAL,
decouvert REAL,
taux_dec REAL,
agios REAL,
atom_banque REAL,
hebdo_banque REAL,
anti_dec BOOLEAN,
portee VARCHAR(20),
cout REAL,
atom_autre REAL,
hebdo_autre INTEGER );
DROP FUNCTION consulte_solde(id_compte INTEGER, id_banque INTEGER);
DROP FUNCTION is_compte_personne(client_id INTEGER, compte_id INTEGER, banque_id INTEGER);
DROP FUNCTION to_compte_personne(client_id INTEGER, compte_id INTEGER, banque_id INTEGER);
DROP FUNCTION from_compte_personne(id INTEGER);
DROP FUNCTION obtenir_chequier(id_client_compte INTEGER);

-- Nettoyage des fonctions du fichier carte.sql
DROP FUNCTION id_carte_suivant();
DROP FUNCTION carte_retrait();
DROP FUNCTION carte_paiement();
DROP FUNCTION carte_credit(_id_personne INTEGER, _id_banque INTEGER, _id_compte INTEGER);
DROP FUNCTION ajoute_revolving(_id_personne INTEGER, _id_carte INTEGER,  montant REAL);
DROP FUNCTION t_interdit_carte();

-- Nettoyage des fonctions du fichier virement.sql
DROP FUNCTION virement_unitaire(id_src INTEGER, id_dest INTEGER, mont REAL, cout REAL);
DROP FUNCTION virement_periodique(id_src INTEGER, id_dest INTEGER, montant REAL, cout_i REAL, inter INTEGER, cout_p REAL, date INTEGER);
DROP FUNCTION plan_virements();

-- Nettoyage de la base de donnees
DROP TABLE plan_virements CASCADE;
DROP TABLE plan_remunerations CASCADE;
DROP TABLE interdit_bancaire;
DROP TABLE historique CASCADE;
DROP TABLE compte_personne CASCADE;
DROP TABLE compte CASCADE;
DROP TABLE personne CASCADE;
DROP TABLE banque_reference CASCADE;
DROP TABLE banque CASCADE;
DROP TABLE carte CASCADE;
DROP TABLE virement CASCADE;

-- Nettoyage des types
DROP TYPE type_compte;
DROP TYPE type_paiement;
