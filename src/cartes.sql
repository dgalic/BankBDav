DROP TABLE carte_retrait CASCADE;
DROP TABLE carte_paiement CASCADE;
DROP TABLE carte_credit CASCADE;
DROP TABLE carte CASCADE;

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
    anti_decouvert BOOLEAN NOT NULL,
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

-----------------------------------------------------
-- 4 triggers pour empêcher la modification sans passer par les fonctions.
-----------------------------------------------------

CREATE OR REPLACE FUNCTION t_interdit_carte() RETURNS TRIGGER AS $$
       DECLARE
       BEGIN
            RAISE  'Vous ne pouvez pas agir sur les cartes comme ça !';                END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER t_interdit_carte BEFORE INSERT OR UPDATE OR DELETE
ON carte
FOR EACH ROW
EXECUTE PROCEDURE t_interdit_carte();

----------------------------------------------------

CREATE TRIGGER t_interdit_paiement AFTER INSERT
ON carte_paiement
FOR EACH ROW
EXECUTE PROCEDURE t_interdit_carte();

------------------------------------------------

CREATE TRIGGER t_interdit_credit AFTER INSERT
ON carte_credit
FOR EACH ROW
EXECUTE PROCEDURE t_interdit_carte();

------------------------------------------------

CREATE TRIGGER t_interdit_retrait AFTER INSERT
ON carte_retrait
FOR EACH ROW
EXECUTE PROCEDURE t_interdit_carte();


---------------------------------------------------------

-- fonctions de commande de carte

---------------------------------------------------------

-- renvoie le prochain ID valide. à utiliser pour assurer la validité de l'héritage
CREATE OR REPLACE FUNCTION id_carte_suivant() RETURNS INTEGER AS $$
       DECLARE
         id INTEGER DEFAULT 0;
       BEGIN         
         SELECT id_carte INTO id FROM carte ORDER BY id_carte DESC LIMIT 1;
         IF id IS NULL THEN
           id := 0;
         END IF;
         id := id + 1;
         RETURN id;
       END;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION carte_retrait() RETURNS VOID AS $$
       DECLARE

       BEGIN
       
       END;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION carte_paiement() RETURNS VOID AS $$
       DECLARE

       BEGIN
       
       END;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION carte_credit(id_client INTEGER) RETURNS VOID AS $$
       DECLARE
        id INTEGER;
       BEGIN
        ALTER TABLE carte_credit DISABLE TRIGGER t_interdit_credit;
        id := id_carte_suivant();
        INSERT INTO carte_credit(id_carte, id_compte_personne, revolving) VALUES(id, id_client, 0);
        RAISE NOTICE 'Le client % possède maintenant la carte de crédit n°%', id_client, id;
        ALTER TABLE carte_credit ENABLE TRIGGER t_interdit_credit;
       END;
$$ LANGUAGE 'plpgsql';