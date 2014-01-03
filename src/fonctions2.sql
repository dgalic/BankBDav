CREATE OR REPLACE FUNCTION consulte_solde(nom VARCHAR(20), prenom VARCHAR(20) ) RETURNS REAL AS $$
       DECLARE
	res REAL;
       BEGIN
         SELECT solde INTO res FROM compte WHERE compte.nom = $1 AND compte.prenom = $2;
	 RETURN res;
       END;
$$ LANGUAGE 'plpgpsql';


CREATE OR REPLACE FUNCTION consulte_solde(id INTEGER ) RETURNS REAL AS $$
       DECLARE
	res REAL;
       BEGIN
         SELECT solde INTO res FROM compte WHERE compte.id = $1;
	 RETURN res;
       END;
$$ LANGUAGE 'plpgpsql';

CREATE OR REPLACE FUNCTION aujourdhui() RETURNS INTEGER AS $$
       DECLARE
	res INTEGER;
       BEGIN
	SELECT jour INTO res FROM temps;
	RETURN res;
       END;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION virement_unitaire(id_src INTEGER, id_dest INTEGER, mont REAL, cout REAL DEFAULT 0) RETURNS VOID AS $$
       DECLARE
	today INTEGER;
	bank1 VARCHAR(20);
	bank2 VARCHAR(20);
       BEGIN
	today := aujourdhui();
	IF id_src = id_dest THEN
	cout := 0;
	END IF;	
	INSERT INTO virement(id_debiteur, id_crediteur, montant, cout_initial, date_virement) VALUES(id_src, id_dest, mont, cout, today);
	retrait(id_src, montant + cout);   
	depot(id_dest, montant);
       END;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION virement_periodique(id_src INTEGER, id_dest INTEGER, montant REAL, cout_i REAL, inter INTEGER, cout_p REAL, date INTEGER DEFAULT NULL ) RETURNS VOID AS $$
       DECLARE
       BEGIN
	IF date IS NULL THEN
       	     date := aujourdhui();
       	END IF;
	IF id_src = id_dest THEN
	cout_i := 0;
	END IF;
       	INSERT INTO virement(id_debiteur, id_crediteur, montant, cout_initial, date_virement, intervalle, cout_periodique) VALUES(id_src, id_dest, montant, cout_i, today, inter, cout_p);
	retrait(id_src, montant + cout_i);   
	depot(id_dest, montant);       
       END;
$$ LANGUAGE 'plpgsql';