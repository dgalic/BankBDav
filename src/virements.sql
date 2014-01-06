DROP TABLE virement CASCADE;
DROP TABLE plan_virements CASCADE;
--CREATE TYPE interval_virement AS ENUM ('mensuel','trimestriel','semestriel','annuel'); 


CREATE TABLE virement (
    id_virement SERIAL PRIMARY KEY,
    id_debiteur INTEGER REFERENCES compte_personne(id_compte_personne),
    id_crediteur INTEGER REFERENCES compte_personne(id_compte_personne),
    montant REAL NOT NULL,
    cout_initial REAL NOT NULL,
    date_virement INTEGER NOT NULL,
    intervalle INTEGER,
    cout_periodique REAL,
     CHECK( intervalle IN(0,1,3,6,13) )
);

CREATE TABLE plan_virements(
       id_virement INTEGER REFERENCES virement,
       date_prochain INTEGER
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
       	IF retrait(id_src, mont + cout, 'virement') THEN 
	INSERT INTO virement(id_debiteur, id_crediteur, montant, cout_initial, date_virement) VALUES(id_src, id_dest, mont, cout, today);
	PERFORM depot(id_dest, mont, 'virement');
        END IF;
       END;
$$ LANGUAGE 'plpgsql';
----------------------

CREATE OR REPLACE FUNCTION virement_periodique(id_src INTEGER, id_dest INTEGER, montant REAL, cout_i REAL, inter INTEGER, cout_p REAL, date INTEGER DEFAULT NULL ) RETURNS VOID AS $$
       DECLARE
         id INTEGER;
       BEGIN
	IF date IS NULL THEN
       	     date := aujourdhui();
       	END IF;
	IF id_src = id_dest THEN
	cout_i := 0;
	END IF;
	IF retrait(id_src, cout_i, 'virement') THEN
           INSERT INTO virement(id_debiteur, id_crediteur, montant, cout_initial, date_virement, intervalle, cout_periodique) VALUES(id_src, id_dest, montant, cout_i, date, inter, cout_p);
           SELECT id_virement INTO id FROM virement ORDER BY id_virement DESC LIMIT 1;
           date := date + (inter*30);
           INSERT INTO plan_virements VALUES (id, date );
        END IF;
       END;
$$ LANGUAGE 'plpgsql';
----------------------


CREATE OR REPLACE FUNCTION plan_virements() RETURNS VOID AS $$
       DECLARE
         curs CURSOR FOR (SELECT * FROM plan_virements);
         entry RECORD;
         vir RECORD;
         today INTEGER;
       BEGIN
         OPEN curs;
         today := aujourdhui();
         LOOP
           FETCH FROM curs INTO entry;
           EXIT WHEN NOT FOUND;
           IF(entry.date_prochain = today ) THEN
             -- effectue un virement
             SELECT * INTO vir FROM virement WHERE intervalle != 0 AND id_virement = entry.id_virement;
             IF retrait(vir.id_debiteur, vir.montant + vir.cout_periodique, 'virement') THEN 
	       PERFORM depot(vir.id_crediteur, vir.montant, 'virement');
             END IF;
             UPDATE plan_virements SET date_prochain = 30*vir.intervalle+today WHERE id_virement = entry.id_virement;
           END IF;
         END LOOP;
         CLOSE curs;
       END;
$$ LANGUAGE 'plpgsql';