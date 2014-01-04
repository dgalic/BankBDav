DROP TABLE temps;

CREATE TABLE temps (
    date INTEGER NOT NULL
);


-- renvoie le jour courant
CREATE OR REPLACE FUNCTION aujourdhui() RETURNS INTEGER AS $$
       DECLARE
	res INTEGER;
       BEGIN
	SELECT date INTO res FROM temps;
	RETURN res;
       END;
$$ LANGUAGE 'plpgsql';
----------------------


-- fait passer n jours (par défaut, 1)
CREATE OR REPLACE FUNCTION passe_jours(n INTEGER DEFAULT 1) RETURNS VOID AS $$
       DECLARE
         it INTEGER DEFAULT 1;
       BEGIN
         ALTER TABLE temps DISABLE TRIGGER t_temps;
         WHILE it <= n LOOP
           UPDATE temps SET date = date+1;
           it := it+1;
         END LOOP;
         ALTER TABLE temps ENABLE TRIGGER t_temps;
       END;
$$ LANGUAGE 'plpgsql';
----------------------

-- déclenchement suite à une tentative de modification du temps
CREATE OR REPLACE FUNCTION t_temps() RETURNS TRIGGER AS $$
       DECLARE

       BEGIN
         RAISE NOTICE 'interdit de modifier le temps sans passer par la fonction passe_jours';
         RETURN OLD;
       END;
$$ LANGUAGE 'plpgsql';


DROP TRIGGER IF EXISTS t_temps ON temps;
DELETE FROM temps;
INSERT INTO temps VALUES(1);
CREATE TRIGGER t_temps BEFORE INSERT OR UPDATE OR DELETE
ON temps
FOR EACH ROW
EXECUTE PROCEDURE t_temps();
----------------------------
