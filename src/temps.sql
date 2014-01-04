
INSERT INTO temps VALUES(1);

-- renvoie le jour
CREATE OR REPLACE FUNCTION aujourdhui() RETURNS INTEGER AS $$
       DECLARE
	res INTEGER;
       BEGIN
	SELECT jour INTO res FROM temps;
	RETURN res;
       END;
$$ LANGUAGE 'plpgsql';
----------------------


-- fait passer n jours
CREATE OR REPLACE FUNCTION passe_jours(n INTEGER DEFAULT 1) RETURNS VOID AS $$
       DECLARE
         it INTEGER DEFAULT 1;
       BEGIN
         WHILE it <= n LOOP
           UPDATE temps SET jour = jour+1;
           it := it+1;
         END LOOP;
       END;
$$ LANGUAGE 'plpgsql';