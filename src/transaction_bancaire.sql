-- Ouverture d'un compte
CREATE OR REPLACE FUNCTION ouverture_compte(nom text, prenom text, banque text)
RETURNS boolean as $$
DECLARE
    client int;
BEGIN

    IF is_banque(banque) THEN
        RAISE NOTICE 'La banque % n\' existe pas', banque;
        RETURN false;
    END IF;

    SELECT id_personne
    INTO client
    FROM personne
    WHERE nom_personne = nom 
    AND prenom_personne = prenom

    IF NOT FOUND THEN
        INSERT INTO personne (nom_personne, prenom_personne) VALUES (nom, prenom);
        RETURN ouverture_compte(nom, prenom, banque);
    END IF;

   IF is_interdit_bancaire(client) THEN
        RAISE NOTICE 'La banque % n\' existe pas', banque;
        RETURN false;
   END IF;
END;
$$ LANGUAGE plpgsql;
---------------------
