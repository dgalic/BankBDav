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
   
   UPDATE banque
   SET nombre_compte = nombre_compte + 1
   WHERE id_banque = id_b;

   RETURN true;
END;
$$ LANGUAGE 'plpgsql';
---------------------

-- fermeture d'un compte avec nom, prenom, nom de la banque et l'identifiant
CREATE OR REPLACE FUNCTION fermeture_compte(client_id INTEGER, banque_id INTEGER ,compte_id INTEGER)
RETURNS boolean as $$
DECLARE
   compte_t type_compte;
BEGIN
    IF NOT is_compte_personne(client_id,compte_id,banque_id) THEN
       RAISE NOTICE 'Ce compte ne vous appartiernt pas';
       RETURN false;
    END IF;

    IF NOT (consulte_solde(compte_id, banque_id) = 0) THEN
       RAISE NOTICE 'Ce compte n est pas vide';
       RETURN false;
    END IF;
    
    --TODO si le temps implementer les comptes joints
    --TODO si carte implementer supprimer les cartes jointes au compte
    --TODO supprimer l'historique du compte

    SELECT compte INTO compte_t
    FROM compte
    WHERE id_compte = compte_id
    AND id_banque = banque_id;
    
    DELETE FROM compte_personne
    WHERE id_personne = client_id
    AND id_banque = banque_id
    AND id_compte = compte_id;

    DELETE FROM compte
    WHERE id_banque = banque_id
    AND id_compte = compte_id;

    UPDATE banque
    SET nombre_compte = nombre_compte - 1
    WHERE id_banque = banque_id;

    RETURN true;
END
$$ LANGUAGE 'plpgsql';
---------------------

-- fermeture d'un compte avec nom, prenom, nom de la banque et l'identifiant
CREATE OR REPLACE FUNCTION fermeture_compte(nom_client text, prenom_client text, client_banque text, identifiant_compte int)
RETURNS boolean as $$
DECLARE
    id_b INTEGER;
    id_p INTEGER;
BEGIN
    SELECT id_banque
    INTO id_b
    FROM banque
    WHERE nom_banque = client_banque;

   IF NOT FOUND THEN
        RAISE NOTICE 'La banque % n existe pas', n_banque;
        RETURN false;
    END IF;

    SELECT id_personne
    INTO id_p
    FROM personne
    WHERE nom_personne = nom_client
    AND prenom_personne = prenom_client;

    IF NOT FOUND THEN
        RAISE NOTICE 'Le client % % n existe pas', nom_client, prenom_client;
        RETURN false;
    END IF;
    RETURN  fermeture_compte(id_p,id_b,identifiant_compte);
END;
$$ LANGUAGE 'plpgsql';
---------------------
