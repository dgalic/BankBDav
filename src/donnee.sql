-- Insertion des données

INSERT INTO temps (jour) VALUES
(5);

INSERT INTO personne (nom_personne, prenom_personne) VALUES
('Galichet','David'),
('Cruise','TOM'),
('Pitt','Brad');

select * From creation_banque('Bnp',0,0,0,0,0,0);
select * From creation_banque('Lcl',0,0,0,0,0,0);
select * From creation_banque('Cic',0,0,0,0,0,0);
select * From creation_banque('Axa',0,0,0,0,0,0);

INSERT INTO interdit_bancaire(id_banque, id_client, date_debut) VALUES
(4,2,3);

