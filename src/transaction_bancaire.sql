-- Ouverture d'un compte
CREATE OR REPLACE FUNCTION ouverture_compte
(nom TEXT, prenom TEXT, n_banque TEXT,
    seuil_rem REAL DEFAULT NULL,
    periode_rem INTEGER DEFAULT NULL,
    taux_rem REAL DEFAULT NULL,
    decouvert REAL DEFAULT NULL,
    taux_dec REAL DEFAULT NULL,
    nb_agios REAL DEFAULT NULL)
RETURNS BOOLEAN as $$
DECLARE
    client INTEGER;
    id_b INTEGER;
    id_compte INTEGER;
    seuil_r real;
    periode_r INTEGER;
    taux_r real;
    dec real;
    taux_d real;
    ref_agios real;
    id_c INTEGER;
    depasse_ok BOOLEAN;
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

   SELECT seuil_remuneration, periode_remuneration, taux_remuneration, decouvert_autorise, taux_decouvert, agios, depassement_autorise
   INTO  seuil_r, periode_r, taux_r, dec, taux_d, ref_agios, depasse_ok
   FROM banque_reference
   WHERE id_banque = id_b;

   IF seuil_rem IS NOT NULL THEN
    seuil_r = seuil_rem;
   END IF;
   IF periode_rem IS NOT NULL THEN
    periode_r = periode_rem;
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
    decouvert_autorise,taux_decouvert,depassement_autorise,agios,chequier,id_banque) VALUES
    (id_compte, seuil_r, periode_r, taux_r, dec, taux_d, depasse_ok, ref_agios, false,id_b);
   
   INSERT INTO compte_personne (id_banque,id_compte,id_personne) VALUES
   (id_b, id_compte,client);
   
   id_c := to_compte_personne(client, id_compte, id_b);
   periode_r := periode_r+aujourdhui();
   INSERT INTO plan_remunerations VALUES(id_c, periode_r);

   UPDATE banque
   SET nombre_compte = nombre_compte + 1
   WHERE id_banque = id_b;
   
   RETURN true;
END;
$$ LANGUAGE 'plpgsql';
---------------------

-- fermeture d'un compte avec nom, prenom, nom de la banque et l'identifiant
CREATE OR REPLACE FUNCTION fermeture_compte(client_id INTEGER, banque_id INTEGER ,compte_id INTEGER)
RETURNS BOOLEAN as $$
DECLARE
   compte_t compte%ROWTYPE;
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

    SELECT * INTO compte_t
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
CREATE OR REPLACE FUNCTION fermeture_compte(nom_client TEXT, prenom_client TEXT, client_banque TEXT, identifiant_compte int)
RETURNS BOOLEAN as $$
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
CREATE OR REPLACE FUNCTION consultation_solde(nom TEXT, prenom text)
RETURNS TABLE(banque TEXT, id_banque INTEGER, compte INTEGER, solde REAL, type_compte type_compte) as $$
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
        (SELECT nom_banque, banque.id_banque, id_compte, solde_compte, typ_compte 
        FROM compte NATURAL JOIN banque NATURAL JOIN compte_personne 
        WHERE id_personne = client )
    LOOP
    RETURN QUERY
    SELECT client_compte.nom_banque, client_compte.id_banque, client_compte.id_compte, client_compte.solde_compte, client_compte.typ_compte;
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
RETURNS BOOLEAN  as $$
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
        RAISE NOTICE 'L identifiant % n existe pas', id_client_compte;
        RETURN false;
    END IF;

    IF  moyen_paiement = 'carte' THEN
        RAISE NOTICE 'Le depot par carte n est pas possible';
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

-- retire l'argent d'un compte, en vérifiant les affaires de découvert
CREATE OR REPLACE FUNCTION retrait( id_client_compte INTEGER, montant_retrait REAL, moyen_paiement type_paiement)
RETURNS BOOLEAN AS $$
DECLARE
    jour_actuel INTEGER;
    retrait_banque INTEGER;
    retrait_compte INTEGER;
    retrait_negatif REAL;
    _c compte%ROWTYPE;
BEGIN
    SELECT id_banque, id_compte
        INTO retrait_banque, retrait_compte
        FROM compte_personne
        WHERE id_compte_personne = id_client_compte;

    IF NOT FOUND THEN
        RAISE NOTICE 'L identifiant % n existe pas', id_client_compte;
        RETURN false;
    END IF;
         
    SELECT * INTO _c 
        FROM compte 
        WHERE id_compte = retrait_compte
        AND id_banque = retrait_banque;
         

            UPDATE compte 
                SET solde_compte = solde_compte - montant_retrait 
                WHERE id_compte = retrait_compte
                AND id_banque = retrait_banque;
            
            retrait_negatif = 0 - montant_retrait;
            INSERT INTO historique (jour, id_compte_personne, paiement, montant) 
                VALUES (jour_actuel, id_client_compte, moyen_paiement, montant_retrait);
           
           RETURN TRUE;
END;
$$ LANGUAGE 'plpgsql';
---------------------

-- depose un chéque sur un compte
CREATE OR REPLACE FUNCTION depot_cheque (id_dest INTEGER, montant_depot REAL, id_src INTEGER)
RETURNS BOOLEAN  as $$
DECLARE
    src_banque INTEGER;
    src_compte INTEGER;
BEGIN
    -- vérifie que id_src existe
    SELECT id_banque, id_compte
    INTO src_banque, src_compte
    FROM compte_personne
    WHERE id_compte_personne = id_src;

    IF NOT FOUND THEN
        RAISE NOTICE 'L identifiant de la source % n existe pas', id_src;
        RETURN false;
    END IF;

    IF NOT 
        (SELECT chequier 
            FROM compte 
            WHERE id_compte = src_compte 
            AND id_banque = src_banque) THEN
        RAISE NOTICE 'La source % ne posséde pas de chequier', id_src;
        RETURN false;
    END IF;

    IF NOT retrait(id_src, montant, 'cheque')THEN
        RAISE NOTICE 'L identifiant de la source % n existe pas', id_src;
        RETURN false;
    END IF;

    RETURN depot(id_dest, montant_depot, 'cheque');
END;
$$ LANGUAGE 'plpgsql';
----------------------


CREATE TABLE plan_remunerations(
    id_cp INTEGER REFERENCES compte_personne(id_compte_personne),
    date_prochain INTEGER
);


CREATE OR REPLACE FUNCTION plan_remuneration() RETURNS VOID AS $$
       DECLARE
         curs CURSOR FOR (SELECT * FROM plan_remunerations);
         entry RECORD;
         account RECORD;
         today INTEGER;
         nv_solde REAL;
       BEGIN
         OPEN curs;
         today := aujourdhui();
         LOOP
           FETCH FROM curs INTO entry;
           EXIT WHEN NOT FOUND;
           IF(entry.date_prochain = today) THEN
             --on doit vérifier que le client atteint le seuil de rémunération
             SELECT solde_compte, seuil_remuneration, taux_remuneration, periode_remuneration, id_compte, id_banque INTO account FROM compte NATURAL JOIN (SELECT * FROM compte_personne WHERE id_compte_personne = entry.id_cp) AS c;
             IF (account.solde_compte >= account.seuil_remuneration) THEN
               nv_solde := account.solde_compte * (1.0 + account.taux_remuneration);
               UPDATE compte SET solde_compte = nv_solde WHERE id_compte = account.id_compte AND id_banque = account.id_banque;
             END IF;
             today := today + account.periode_remuneration;
             UPDATE plan_remunerations SET date_prochain = today WHERE id_cp = entry.id_cp;
           END IF;
         END LOOP;
         CLOSE curs;
       END;
$$ LANGUAGE 'plpgsql';
----------------------


CREATE OR REPLACE FUNCTION check_decouverts() RETURNS VOID AS $$
       DECLARE
         curs CURSOR FOR (SELECT * FROM compte WHERE solde_compte < 0);
         entry RECORD;
         test RECORD;
         today INTEGER;
         client INTEGER;
         nv_solde REAL;
       BEGIN
         OPEN curs;
         LOOP
           FETCH FROM curs INTO entry;
           EXIT WHEN NOT FOUND;
           -- les éléments du curseur sont les clients à découvert
           nv_solde := entry.solde_compte *(1 + entry.taux_decouvert);
           UPDATE compte SET solde_compte = nv_solde WHERE id_compte = entry.id_compte AND id_banque = entry.id_banque; -- prise de la commission
           IF  entry.depassement_autorise THEN
             --dépassement de découvert autorisé : prise d'agios
             nv_solde := entry.solde_compte - entry.agios;
             UPDATE compte SET solde_compte = nv_solde WHERE id_compte = entry.id_compte AND id_banque = entry.id_banque; -- prise de la commission
           ELSE
             --dépassement de découvert interdit : mis en interdit banquaire
             SELECT id_personne INTO client FROM compte_personne WHERE id_compte = entry.id_compte AND id_banque = entry.id_banque;
             today := aujourdhui();
             -- test des interdictions encore en validité sur cette banque
             SELECT  * INTO test FROM interdit_bancaire WHERE id_banque = entry.id_banque AND id_client = client AND (date_regularisation IS NULL OR date_regularisation > today);
             IF test IS NULL THEN
               -- on va pas insérer plusieurs fois
               INSERT INTO interdit_bancaire VALUES(entry.id_banque, client, 'dépassement de découvert', today, today+5*30*12);
             END IF;
           END IF;
         END LOOP;
         CLOSE curs;
       END;
$$ LANGUAGE 'plpgsql';
----------------------



CREATE OR REPLACE FUNCTION check_liberations() RETURNS VOID AS $$
       DECLARE
         interdits CURSOR FOR (SELECT * FROM interdit_bancaire);
         comptes REFCURSOR;
         entry_i RECORD;
         entry_c RECORD;
         today INTEGER;
         client INTEGER;
         count_dec INTEGER;
         nv_solde REAL;
       BEGIN
         OPEN interdits;
         today := aujourdhui();
         LOOP
           FETCH FROM interdits INTO entry_i;
           EXIT WHEN NOT FOUND;
           --pour chaque personne interdite, on regarde si dans chacun de ses comptes elle est revenu en positif. dès qu'on trouve 1 compte à découvert, on passe.
           count_dec := 0;
           OPEN comptes FOR (SELECT * FROM compte NATURAL JOIN (SELECT * FROM compte_personne WHERE id_personne = entry_i.id_client AND id_banque = entry_i.id_banque) AS cp);
           LOOP
             FETCH FROM comptes INTO entry_c;
             --on regarde tous les comptes de la banque, voir si ils sont encore à découvert ou non
             EXIT WHEN NOT FOUND;
             IF entry_c.solde_compte < 0 THEN
               count_dec := count_dec+1;
             END IF;
           END LOOP;
           IF count_dec > 0 THEN
             UPDATE interdit_bancaire SET date_regularisation = today WHERE id_client = entry_i.id_client AND id_banque = entry_i.id_banque;
           END IF;
           CLOSE comptes;
         END LOOP;
         CLOSE interdits;       
       END;
$$ LANGUAGE 'plpgsql';
---------------------