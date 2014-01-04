CREATE OR REPLACE FUNCTION consulte_solde(nom VARCHAR(20), prenom VARCHAR(20) ) RETURNS REAL AS $$
       DECLARE
	res REAL;
       BEGIN
         SELECT solde_compte INTO res FROM compte WHERE compte.nom = $1 AND compte.prenom = $2;
	 RETURN res;
       END;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION consulte_solde(id INTEGER ) RETURNS REAL AS $$
       DECLARE
	res REAL;
       BEGIN
         SELECT solde_compte INTO res FROM compte WHERE compte.id = $1;
	 RETURN res;
       END;
$$ LANGUAGE 'plpgsql';


