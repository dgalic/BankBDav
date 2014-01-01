-- test fonction d'identification du client et du compte et de la banque
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
