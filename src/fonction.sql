-- list les personnes existante
CREATE OR REPLACE FUNCTION list_personne()
RETURNS TABLE(nom varchar(20), prenom varchar(20)) as $$
DECLARE
    client record;
BEGIN
    FOR client IN
    SELECT nom_personne as n, prenom_personne as p FROM personne
    LOOP
    RETURN QUERY
    SELECT client.n, client.p;
    END LOOP;
END;
$$ LANGUAGE 'plpgsql';
---------------------

-- list les banques existante
CREATE OR REPLACE FUNCTION list_banque()
RETURNS TABLE(nom varchar(20)) as $$
DECLARE
    banque record;
BEGIN
    FOR banque IN
    SELECT nom_banque as b FROM banque
    LOOP
    RETURN QUERY
    SELECT banque.b;
    END LOOP;
END;
$$ LANGUAGE 'plpgsql';
---------------------

-- test si une personne existe
CREATE OR REPLACE FUNCTION is_personne(nom text, prenom text)
RETURNS boolean as $$
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
RETURNS boolean as $$
BEGIN
    RETURN nom IN (SELECT nom_banque  FROM banque);
END;
$$ LANGUAGE 'plpgsql';
---------------------

-- test si un client est interdit bancaire
CREATE OR REPLACE FUNCTION is_interdit_bancaire(client int)
RETURNS boolean as $$
DECLARE
    date_actuel int;
    interdit record;
BEGIN
    SELECT jour INTO date_actuel FROM temps;
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
(nom_b text, seuil_rem real, periode_rem int, taux_rem real, decouvert real, taux_dec real, agios real)
RETURNS boolean as $$
DECLARE
   id_b int;
BEGIN
    if is_banque(nom_b) THEN
        RAISE NOTICE 'La banque % existe déjà', nom_b;
        RETURN false;
    END IF;
    INSERT INTO banque (nom_banque) VALUES (nom_b);
    SELECT id_banque INTO id_b FROM banque WHERE nom_banque = nom_b ;
    INSERT INTO banque_reference
    (id_banque, seuil_remuneration, periode_remuneration, taux_remuneration, decouvert_autorise, taux_decouvert, agios) VALUES
    (id_b, seuil_rem, periode_rem, taux_rem, decouvert, taux_dec, agios);
    RETURN true;
END;
$$ LANGUAGE 'plpgsql';
--------------------

-- consultation du solde d'un compte
CREATE OR REPLACE FUNCTION consulte_solde(id_compte INTEGER, id_banque INTEGER) RETURNS REAL AS $$
    DECLARE
	    res REAL;
    BEGIN
        SELECT solde INTO res FROM compte WHERE compte.id_compte = $1 and compte.id_banque = $2;
	    RETURN res;
    END;
$$ LANGUAGE 'plpgsql';
----------------------

-- revoie le jour
CREATE OR REPLACE FUNCTION aujourdhui() RETURNS INTEGER AS $$
       DECLARE
	res INTEGER;
       BEGIN
	SELECT jour INTO res FROM temps;
	RETURN res;
       END;
$$ LANGUAGE 'plpgsql';
----------------------

-- test si compte appartient à une personne
CREATE OR REPLACE FUNCTION is_compte_personne(client_id INTEGER, compte_id INTEGER, banque_id INTEGER)
RETURNS boolean AS $$
BEGIN
    RETURN client_id IN (
        SELECT id_personne 
        FROM compte_personne 
        WHERE  id_banque = banque_id 
        AND id_compte = compte_id);
END;
$$ LANGUAGE 'plpgsql';
----------------------
