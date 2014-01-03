-- Ouverture d'un compte
CREATE OR REPLACE FUNCTION ouverture_compte
(nom text, prenom text, n_banque text,
    seuil_rem real DEFAULT NULL,
    periode_rem int DEFAULT NULL,
    taux_rem real DEFAULT NULL,
    decouvert real DEFAULT NULL,
    taux_dec real DEFAULT NULL,
    nb_agios real DEFAULT NULL)
RETURNS boolean as $$
DECLARE
    client int;
    id_b int;
    id_compte int;
    seuil_r real;
    periode_r int;
    taux_r real;
    dec real;
    taux_d real;
    ref_agios real;
BEGIN

    IF NOT is_banque(n_banque) THEN
        RAISE NOTICE 'La banque % n existe pas', n_banque;
        RETURN false;
    END IF;

    SELECT id_personne
    INTO client
    FROM personne
    WHERE nom_personne = nom 
    AND prenom_personne = prenom;

    IF NOT FOUND THEN
        INSERT INTO personne (nom_personne, prenom_personne) VALUES (nom, prenom);
        RETURN ouverture_compte(nom, prenom, n_banque);
    END IF;

   IF is_interdit_bancaire(client) THEN
        RAISE NOTICE 'Le client % % est interdit bancaire \n', nom, prenom;
        RETURN false;
   END IF;
   
   SELECT id_banque,nombre_compte INTO id_b, id_compte FROM banque WHERE nom_banque = n_banque ;

   SELECT seuil_remuneration, periode_remuneration, taux_remuneration, decouvert_autorise, taux_decouvert, agios
   INTO  seuil_r, periode_r, taux_r, dec, taux_d, ref_agios
   FROM banque_reference
   WHERE id_banque = id_b;

   IF seuil_rem IS NOT NULL THEN
    seuil_r = seuim_rem;
   END IF;
   IF periode_rem IS NOT NULL THEN
    periode_r = peridoe_rem;
   END IF;
   IF taux_rem IS NOT NULL THEN
    taux_r = taux_rem;
   END IF;
   IF decouvert IS NOT NULL THEN
    dec = decouvert;
   END IF;
   IF taux_dec IS NOT NULL THEN
    taux_d = taux_dec;
   END IF;
   IF nb_agios IS NOT NULL THEN
    ref_agios = agios;
   END IF;

   INSERT INTO compte  
    (id_compte, seuil_remuneration, periode_remuneration,taux_remuneration,
    decouvert_autorise,taux_decouvert,depassement,agios,chequier,id_banque) VALUES
    (id_compte, seuil_r, periode_r, taux_r, dec, taux_d, false, ref_agios, false,id_b);
   
   INSERT INTO compte_personne (id_banque,id_compte,id_personne) VALUES
   (id_b, id_compte,client);
   
   RETURN true;
END;
$$ LANGUAGE plpgsql;
---------------------
