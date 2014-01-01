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
    SELECT client.b;
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
    SELECT nom_personne as n, prenom_personne as p FROM personne
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
DECLARE
    banque record;
BEGIN
    FOR banque IN
    SELECT nom_banque as b FROM banque
    LOOP
    IF client.n = nom THEN
        RETURN true;
    END IF;
    END LOOP;
    RETURN false;
END;
$$ LANGUAGE plpgsql;
---------------------
