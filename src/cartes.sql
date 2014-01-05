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

-- création d'une carte de crédit pour le client 
CREATE OR REPLACE FUNCTION carte_credit(_id_personne INTEGER, _id_banque INTEGER, _id_compte INTEGER) RETURNS VOID AS $$
       DECLARE
        id INTEGER;
        id_cp INTEGER;
       BEGIN
        ALTER TABLE carte_credit DISABLE TRIGGER t_interdit_credit;
        id := id_carte_suivant();
        id_cp = to_compte_personne(_id_personne, _id_compte, _id_banque);
        IF id_cp IS NULL THEN
          RAISE 'Le client % n''a pas le compte % chez la banque %', _id_personne, _id_compte, _id_banque;
        END IF;
        INSERT INTO carte_credit(id_carte, id_compte_personne, revolving) VALUES(id, id_cp, 0);
        RAISE NOTICE 'Le client % possède maintenant la carte de crédit n°%', _id_personne, id;
        ALTER TABLE carte_credit ENABLE TRIGGER t_interdit_credit;
       END;
$$ LANGUAGE 'plpgsql';



-- ajoute du crédit à la carte tiré depuis le compte lié
CREATE OR REPLACE FUNCTION compte_to_revolving(_id_personne INTEGER, _id_carte INTEGER,  montant REAL) RETURNS VOID AS $$
       DECLARE
         nv_montant REAL;
         infos RECORD;
         id_cp INTEGER;
       BEGIN
         IF montant <= 0 THEN
            RAISE 'pour faire un retrait, utiliser la fonction retrait_revolving';
         END IF;
          SELECT id_compte_personne INTO id_cp FROM carte WHERE id_carte = _id_carte;
         infos := from_compte_personne(id_cp);
         IF infos IS NULL OR infos.id_personne != _id_personne THEN
           RAISE 'cette carte n''est pas le votre', _id_compte;
         END IF;
         IF retrait(infos.id_personne, infos.id_compte, infos.id_banque, montant) THEN 
           ALTER TABLE carte_credit DISABLE TRIGGER t_interdit_credit;
           UPDATE carte_credit SET revolving = revolving+montant;
           ALTER TABLE carte_credit ENABLE TRIGGER t_interdit_credit;
           SELECT revolving INTO nv_montant FROM carte_credit WHERE id_carte = _id_carte;
           RAISE 'nouveau crédit de la carte n°% : %', _id_carte, nv_montant;
         ELSE
           RAISE 'vous ne pouvez pas retirer autant d''argent de ce compte';
         END IF;
       END;
$$ LANGUAGE 'plpgsql';



-- ajoute du crédit à la carte par espèce
CREATE OR REPLACE FUNCTION ajoute_revolving(_id_personne INTEGER, _id_carte INTEGER, montant REAL) RETURNS VOID AS $$
       DECLARE
         id_c INTEGER;
         card carte_credit%ROWTYPE;
         nv_montant REAL;
       BEGIN
         IF montant <= 0 THEN
            RAISE 'pour faire un retrait, utiliser la fonction retrait_revolving';
         END IF;
         SELECT DISTINCT id_compte_personne INTO id_c FROM compte_personne NATURAL JOIN compte WHERE id_personne = _id_personne;
         SELECT * INTO card FROM carte_credit WHERE id_carte = _id_carte AND id_compte_personne = _id_c;
         IF card IS NULL THEN
           RAISE 'cette carte n''est pas la votre';
         END IF;
         ALTER TABLE carte_credit DISABLE TRIGGER t_interdit_credit;
         UPDATE carte_credit SET revolving = revolving+montant;
         ALTER TABLE carte_credit ENABLE TRIGGER t_interdit_credit;
         SELECT revolving INTO nv_montant FROM carte_credit WHERE id_carte = _id_carte;
         RAISE 'nouveau crédit de la carte n°% : %', _id_carte, nv_montant;
       END;
$$ LANGUAGE 'plpgsql';