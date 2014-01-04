DROP TABLE carte_retrait CASCADE;
DROP TABLE carte_paiement CASCADE;
DROP TABLE carte_credit CASCADE;
DROP TABLE carte CASCADE;

CREATE TABLE carte (
    id_carte SERIAL CHECK ( id_carte > 0),
    id_compte_personne INTEGER REFERENCES compte_personne(id_compte_personne),
    UNIQUE(id_carte)
);

CREATE TABLE carte_retrait (
    portee varchar NOT NULL,
    montant_atomique_banque REAL NOT NULL, 
    montant_atomique_autre REAL,
    montant_hebdomadaire_banque REAL NOT NULL, 
    montant_hebdomadaire_autre REAL,
    anti_decouvert BOOLEAN NOT NULL
) INHERITS (carte);

CREATE TABLE carte_paiement (
    portee varchar NOT NULL,
    debit_differe BOOLEAN NOT NULL,
    cout_annuel REAL NOT NULL,
    prestige varchar(20)
) INHERITS (carte);

CREATE TABLE carte_credit (
    revolving REAL check (revolving >= 0 ) NOT NULL 
) INHERITS (carte);

-----------------------------------------------------
-- les trois triggers suivant servent à garantir la validité des id
-- même à travers l'héritage (bancal en pgsql).
----------------------------------------------------
CREATE OR REPLACE FUNCTION t_insert_paiement() RETURNS TRIGGER AS $$
       DECLARE
         id INTEGER;
         line record;
       BEGIN
         SELECT id_carte INTO id FROM carte ORDER BY id_carte DESC LIMIT 1;
         id := id + 1;
         UPDATE carte_paiement SET id_carte = id WHERE id_carte = NEW.id_carte;
         --INSERT INTO carte_paiement VALUES(id, NEW.id_compte_personne, NEW.portee, NEW.debit_differe, NEW.cout_annuel, NEW.prestige);
         RETURN NEW;
       END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER t_insert_paiement AFTER INSERT
ON carte_paiement
FOR EACH ROW
EXECUTE PROCEDURE t_insert_paiement();

------------------------------------------------

CREATE OR REPLACE FUNCTION t_insert_credit() RETURNS TRIGGER AS $$
       DECLARE
         id INTEGER;
         line record;
       BEGIN
         SELECT id_carte INTO id FROM carte ORDER BY id_carte DESC LIMIT 1;
         id := id + 1;
         UPDATE carte_credit SET id_carte = id WHERE id_carte = NEW.id_carte;
         --INSERT INTO carte_paiement VALUES(id, NEW.id_compte_personne, NEW.portee, NEW.debit_differe, NEW.cout_annuel, NEW.prestige);
         RETURN NEW;
       END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER t_insert_credit AFTER INSERT
ON carte_credit
FOR EACH ROW
EXECUTE PROCEDURE t_insert_credit();

------------------------------------------------

CREATE OR REPLACE FUNCTION t_insert_retrait() RETURNS TRIGGER AS $$
       DECLARE
         id INTEGER;
         line record;
       BEGIN
         SELECT id_carte INTO id FROM carte ORDER BY id_carte DESC LIMIT 1;
         id := id + 1;
         UPDATE carte_retrait SET id_carte = id WHERE id_carte = NEW.id_carte;
         --INSERT INTO carte_retrait VALUES(id, NEW.id_compte_personne, NEW.portee, NEW.debit_differe, NEW.cout_annuel, NEW.prestige);
         RETURN NEW;
       END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER t_insert_retrait AFTER INSERT
ON carte_retrait
FOR EACH ROW
EXECUTE PROCEDURE t_insert_retrait();