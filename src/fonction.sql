-- list les personnes existante
CREATE OR REPLACE FUNCTION list_personne()
RETURNS TABLE(nom TEXT, prenom TEXT, id INTEGER) as $$
DECLARE
    client record;
BEGIN
    FOR client IN
    SELECT nom_personne as n, prenom_personne as p, id_personne as i FROM personne
    LOOP
    RETURN QUERY
    SELECT client.n, client.p, client.i;
    END LOOP;
END;
$$ LANGUAGE 'plpgsql';
---------------------

-- list les banques existante
CREATE OR REPLACE FUNCTION list_banque()
RETURNS TABLE(nom TEXT, id INTEGER) as $$
DECLARE
    banque record;
BEGIN
    FOR banque IN
    SELECT nom_banque as b, id_banque as i FROM banque
    LOOP
    RETURN QUERY
    SELECT banque.b, banque.i;
    END LOOP;
END;
$$ LANGUAGE 'plpgsql';
---------------------

-- renvoie l'id de la personne
CREATE OR REPLACE FUNCTION get_id(nom TEXT, prenom TEXT) RETURNS INTEGER AS $$
       DECLARE
         id INTEGER;
       BEGIN
         SELECT id_personne INTO id FROM personne WHERE nom_personne = nom AND prenom_personne = prenom;
         RETURN id;
       END;
$$ LANGUAGE 'plpgsql';



-- test si une personne existe
CREATE OR REPLACE FUNCTION is_personne(nom TEXT, prenom text)
RETURNS BOOLEAN as $$
DECLARE
    client record;
BEGIN
    FOR client IN
    SELECT nom_personne as n, prenom_personne as p
    FROM personne
    LOOP
    IF client.n = nom and client.p = prenom THEN
        RETURN true;
    END IF;
    END LOOP;
    RETURN false;
END;
$$ LANGUAGE 'plpgsql';
---------------------

-- test si une banque existe
CREATE OR REPLACE FUNCTION is_banque(nom text)
RETURNS BOOLEAN as $$
BEGIN
    RETURN nom IN (SELECT nom_banque  FROM banque);
END;
$$ LANGUAGE 'plpgsql';
---------------------

-- test si un client est interdit bancaire
CREATE OR REPLACE FUNCTION is_interdit_bancaire(client int)
RETURNS BOOLEAN as $$
DECLARE
    date_actuel INTEGER;
    interdit record;
BEGIN
    date_actuel := aujourdhui();
    FOR interdit IN
    SELECT date_debut AS debut, date_regularisation AS fin
    FROM interdit_bancaire
    WHERE id_client = client
    LOOP
        IF date_actuel > interdit.debut AND  date_actuel < interdit.fin THEN
            RETURN true;
        END IF;
    END LOOP;
    RETURN false;
END;
$$ LANGUAGE 'plpgsql';
---------------------

-- creation d'une banque avec valeur de reference pour le compte
CREATE OR REPLACE FUNCTION creation_banque
(nom_b TEXT, seuil_rem REAL, periode_rem INTEGER, taux_rem REAL, decouvert REAL, taux_dec REAL, agios REAL, atom_banque REAL DEFAULT 500, hebdo_banque REAL DEFAULT 2500, depasse_ok BOOLEAN DEFAULT TRUE, portee VARCHAR(20) DEFAULT 'nationale', cout REAL DEFAULT 20, atom_autre REAL DEFAULT 200, hebdo_autre INTEGER DEFAULT 1000)
RETURNS BOOLEAN as $$
DECLARE
   id_b INTEGER;
BEGIN
    if is_banque(nom_b) THEN
        RAISE NOTICE 'La banque % existe déjà', nom_b;
        RETURN false;
    END IF;
--    RAISE NOTICE 'la banque % autorise les découverts : %', nom_b, depasse_ok;
    INSERT INTO banque (nom_banque) VALUES (nom_b);
    SELECT id_banque INTO id_b FROM banque WHERE nom_banque = nom_b ;
    INSERT INTO banque_reference
    (id_banque, seuil_remuneration, periode_remuneration, taux_remuneration, decouvert_autorise, taux_decouvert, agios, atom_banque, hebdo_banque, depassement_autorise, portee, cout, atom_autre, hebdo_autre) VALUES
    (id_b, seuil_rem, periode_rem, taux_rem, decouvert, taux_dec, agios, atom_banque, hebdo_banque, depasse_ok, portee, cout, atom_autre, hebdo_autre);
    RETURN true;
END;
$$ LANGUAGE 'plpgsql';
--------------------

-- consultation du solde d'un compte à partir de son numéro de compte et de l'identifiant de la banque
CREATE OR REPLACE FUNCTION consulte_solde(id_compte INTEGER, id_banque INTEGER)
RETURNS REAL AS $$
DECLARE
	res REAL;
BEGIN
    SELECT solde_compte INTO res FROM compte WHERE compte.id_compte = $1 and compte.id_banque = $2;
	RETURN res;
END;
$$ LANGUAGE 'plpgsql';
----------------------

-- test si compte appartient à une personne
CREATE OR REPLACE FUNCTION is_compte_personne(client_id INTEGER, compte_id INTEGER, banque_id INTEGER)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN client_id IN (
        SELECT id_personne 
        FROM compte_personne 
        WHERE  id_banque = banque_id 
        AND id_compte = compte_id);
END;
$$ LANGUAGE 'plpgsql';
----------------------

CREATE OR REPLACE FUNCTION to_compte_personne(client_id INTEGER, compte_id INTEGER, banque_id INTEGER DEFAULT NULL)
RETURNS INTEGER AS $$
        DECLARE
          id INTEGER DEFAULT NULL;
        BEGIN
          IF banque_id IS NULL THEN
            SELECT DISTINCT id_compte_personne INTO id FROM compte_personne WHERE id_compte = compte_id AND id_personne = client_id;
            RETURN id;
          END IF;
          SELECT id_compte_personne INTO id FROM compte_personne WHERE id_compte = compte_id AND id_banque = banque_id AND id_personne = client_id;
          RETURN id;
        END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION from_compte_personne(id INTEGER)
RETURNS RECORD AS $$
        DECLARE
          res RECORD;
        BEGIN
          SELECT id_personne, id_banque, id_compte INTO res FROM compte_personne WHERE id_compte_personne = id;
          RETURN res;
        END;
$$ LANGUAGE 'plpgsql';

-- test si une banque existe
CREATE OR REPLACE FUNCTION obtenir_chequier(id_client_compte INTEGER)
RETURNS BOOLEAN as $$
DECLARE
    client_compte INTEGER;
    client_banque INTEGER;
    info_chequier BOOLEAN;
BEGIN
    SELECT id_compte, id_banque
        INTO client_compte, client_banque
        FROM compte_personne
        WHERE id_compte_personne = id_client_compte;

    IF NOT FOUND THEN
        RAISE NOTICE 'L identifiant % n existe pas', id_src;
        RETURN false;
    END IF;

    SELECT chequier
        INTO info_chequier
        FROM compte
        WHERE id_compte = client_compte
        AND id_banque = client_banque;

    IF info_chequier THEN  
        RAISE NOTICE 'Le compte % possède déjà le droit d avoir un chéquier', client_compte;
        RETURN false;
   END IF; 


    UPDATE compte 
        SET chequier = TRUE
        WHERE id_compte = retrait_compte
        AND id_banque = retrait_banque;
END;
$$ LANGUAGE 'plpgsql';
---------------------


