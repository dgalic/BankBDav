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
$$ LANGUAGE plpgsql;
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
$$ LANGUAGE plpgsql;
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
$$ LANGUAGE plpgsql;
---------------------

-- test si une banque existe
CREATE OR REPLACE FUNCTION is_banque(nom text)
RETURNS boolean as $$
BEGIN
    RETURN nom IN (SELECT nom_banque  FROM banque);
END;
$$ LANGUAGE plpgsql;
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
            RETURN false;
        END IF;
    END LOOP;
    RETURN true;
END;
$$ LANGUAGE plpgsql;


