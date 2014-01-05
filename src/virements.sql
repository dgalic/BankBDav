DROP TABLE virement CASCADE;
CREATE TYPE interval_virement AS ENUM ('mensuel','trimestriel','semestriel','annuel'); 


CREATE TABLE virement (
    id_virement SERIAL PRIMARY KEY,
    id_debiteur INTEGER REFERENCES compte_personne(id_compte_personne),
    id_crediteur INTEGER REFERENCES compte_personne(id_compte_personne),
    montant REAL NOT NULL,
    cout_initial REAL NOT NULL,
    date_virement INTEGER NOT NULL,
    interval interval_virement,
    cout_periodique REAL
);

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
	retrait(id_src, cout_i);   
       END;
$$ LANGUAGE 'plpgsql';
