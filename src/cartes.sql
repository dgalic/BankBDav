-----------------------------------------------------
-- 4 triggers pour empêcher la modification sans passer par les fonctions.
-----------------------------------------------------

CREATE OR REPLACE FUNCTION t_interdit_carte() RETURNS TRIGGER AS $$
       DECLARE
       BEGIN
            RAISE  'Vous ne pouvez pas agir sur les cartes comme ça !';                END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER t_interdit_carte BEFORE INSERT OR UPDATE OR DELETE
ON carte
FOR EACH ROW
EXECUTE PROCEDURE t_interdit_carte();

----------------------------------------------------

CREATE TRIGGER t_interdit_paiement AFTER INSERT
ON carte_paiement
FOR EACH ROW
EXECUTE PROCEDURE t_interdit_carte();

------------------------------------------------

CREATE TRIGGER t_interdit_credit AFTER INSERT
ON carte_credit
FOR EACH ROW
EXECUTE PROCEDURE t_interdit_carte();

------------------------------------------------

CREATE TRIGGER t_interdit_retrait AFTER INSERT
ON carte_retrait
FOR EACH ROW
EXECUTE PROCEDURE t_interdit_carte();


---------------------------------------------------------

-- fonctions de commande de carte

---------------------------------------------------------

-- renvoie le prochain ID valide. à utiliser pour assurer la validité de l'héritage
CREATE OR REPLACE FUNCTION id_carte_suivant() RETURNS INTEGER AS $$
       DECLARE
         id INTEGER DEFAULT 0;
       BEGIN         
         SELECT id_carte INTO id FROM carte ORDER BY id_carte DESC LIMIT 1;
         IF id IS NULL THEN
           id := 0;
         END IF;
         id := id + 1;
         RETURN id;
       END;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION carte_retrait() RETURNS VOID AS $$
       DECLARE

       BEGIN
       
       END;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION carte_paiement() RETURNS VOID AS $$
       DECLARE

       BEGIN
       
       END;
$$ LANGUAGE 'plpgsql';

-- création d'une carte de crédit pour le client 
CREATE OR REPLACE FUNCTION carte_credit(_id_personne INTEGER, _id_banque INTEGER, _id_compte INTEGER) RETURNS VOID AS $$
       DECLARE
        id INTEGER;
        id_cp INTEGER;
       BEGIN
        ALTER TABLE carte_credit DISABLE TRIGGER t_interdit_credit;
        id := id_carte_suivant();
        id_cp = to_compte_personne(_id_personne, _id_compte, _id_banque);
        IF id_cp IS NULL THEN
          RAISE 'Le client % n''a pas le compte % chez la banque %', _id_personne, _id_compte, _id_banque;
        END IF;
        INSERT INTO carte_credit(id_carte, id_compte_personne, revolving) VALUES(id, id_cp, 0);
        RAISE NOTICE 'Le client % possède maintenant la carte de crédit n°%', _id_personne, id;
        ALTER TABLE carte_credit ENABLE TRIGGER t_interdit_credit;
       END;
$$ LANGUAGE 'plpgsql';



-- ajoute du crédit à la carte tiré depuis le compte lié
CREATE OR REPLACE FUNCTION ajoute_revolving(_id_carte INTEGER,  montant REAL) RETURNS VOID AS $$
       DECLARE
         nv_montant REAL;
         infos RECORD;
         id_cp INTEGER;
       BEGIN
         IF montant <= 0 THEN
            RAISE 'pour faire un retrait, utiliser la fonction retrait_revolving';
         END IF;
          SELECT id_compte_personne INTO id_cp FROM carte WHERE id_carte = _id_carte;
         infos := from_compte_personne(id_cp);
         IF retrait(id_cp, montant, 'carte') THEN 
           ALTER TABLE carte_credit DISABLE TRIGGER t_interdit_credit;
           UPDATE carte_credit SET revolving = revolving+montant WHERE id_carte = _id_carte;
           ALTER TABLE carte_credit ENABLE TRIGGER t_interdit_credit;
           SELECT revolving INTO nv_montant FROM carte_credit WHERE id_carte = _id_carte;
           RAISE NOTICE 'nouveau crédit de la carte n°% : %', _id_carte, nv_montant;
           SELECT solde_compte INTO nv_montant FROM compte WHERE id_compte = infos.id_compte AND id_banque = infos.id_banque;
           RAISE NOTICE 'nouveau solde du compte n°% : %', infos.id_compte, nv_montant;
         ELSE
           RAISE 'vous ne pouvez pas retirer autant d''argent de ce compte';
         END IF;
       END;
$$ LANGUAGE 'plpgsql';
