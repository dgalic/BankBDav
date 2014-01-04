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

-- consultation du solde des compte ou du compte de la personne
CREATE OR REPLACE FUNCTION consultation_solde(nom text, prenom text)
RETURNS TABLE(banque text, compte INTEGER, solde REAL, type_compte type_compte) as $$
DECLARE
    client_compte record; 
    client INTEGER;
BEGIN
    SELECT id_personne
    INTO client
    FROM personne
    WHERE nom_personne = nom 
    AND prenom_personne = prenom;

    IF NOT FOUND THEN
        RAISE NOTICE 'Le client % % n existe pas', nom_client, prenom_client;
        RETURN ;
    END IF;

    FOR client_compte IN
        (SELECT nom_banque , id_compte, solde_compte, typ_compte 
        FROM compte NATURAL JOIN banque NATURAL JOIN compte_personne 
        WHERE id_personne = client )
    LOOP
    RETURN QUERY
    SELECT client_compte.nom_banque, client_compte.id_compte, client_compte.solde_compte, client_compte.typ_compte;
    END LOOP;
END;
$$ LANGUAGE 'plpgsql';
----------------------

-- consultation du solde des compte ou du compte de la personne
CREATE OR REPLACE FUNCTION consultation_historique(id_client_compte INTEGER)
RETURNS TABLE(jour_de_la_transaction INTEGER, montant_transaction REAL, moyen_de_paiement type_paiement) as $$
DECLARE
    jour_actuel INTEGER;
    historique_mois record;
BEGIN
    IF NOT id_client_compte IN (SELECT id_compte_personne  FROM compte_personne) THEN
        RAISE NOTICE 'L identifiant n existe pas';
        RETURN ;
    END IF;

    jour_actuel = aujourdhui() / 30;

    FOR historique_mois IN
        SELECT jour, montant, paiement
        FROM historique
        WHERE id_compte_personne = id_client_compte
        AND (jour/30) = jour_actuel
    LOOP
        RETURN QUERY
        SELECT historique_mois.jour, historique_mois.montant, historique_mois.paiement;
    END LOOP;
END;
$$ LANGUAGE 'plpgsql';
----------------------

-- depot sur un compte en donnant le moyen de paiement
CREATE OR REPLACE FUNCTION depot (id_client_compte INTEGER, montant_depot REAL, moyen_paiement type_paiement)
RETURNS boolean  as $$
DECLARE
    jour_actuel INTEGER;
    depot_banque INTEGER;
    depot_compte INTEGER;
BEGIN
    SELECT id_banque, id_compte
    INTO depot_banque, depot_compte
    FROM compte_personne
    WHERE id_compte_personne = id_client_compte;

    IF NOT FOUND THEN
        RAISE NOTICE 'L identifiant n existe pas';
        RETURN false;
    END IF;

    IF  moyen_paiement = 'carte' THEN
        RAISE NOTICE 'Le depot par carte n est pas possible';
        RETURN false;
    END IF;
    
    --TODO vérifier si la id-> à vraiment un chéquier
    IF  moyen_paiement = 'chéque' THEN
        RAISE NOTICE 'Le depot par chéque n est pas possible';
        RETURN false;
    END IF;

    --TODO vérifier que le virement existe
    IF  moyen_paiement = 'virement' THEN
        RAISE NOTICE 'Le depot par virement n est pas possible';
        RETURN false;
    END IF;

    IF montant_depot < 0 THEN
        RAISE NOTICE 'Le montant à déposer ne peut être négatif';
        RETURN false;
    END IF;
    
    jour_actuel = aujourdhui();
   
    UPDATE compte
    SET solde_compte = solde_compte + montant_depot
    WHERE id_compte = depot_compte
    AND id_banque = depot_banque;

    INSERT INTO historique (jour, id_compte_personne, paiement, montant) 
    VALUES (jour_actuel, id_client_compte, moyen_paiement, montant_depot);

    RETURN true;
END;
$$ LANGUAGE 'plpgsql';
----------------------
