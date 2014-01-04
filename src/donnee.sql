-- Insertion des données

INSERT INTO temps (jour) VALUES
(5);

INSERT INTO personne (nom_personne, prenom_personne) VALUES
('Galichet','David'),
('Cruise','TOM'),
('Pitt','Brad');

select creation_banque('Bnp',0,0,0,0,0,0);
select creation_banque('Lcl',0,0,0,0,0,0);
select creation_banque('Cic',0,0,0,0,0,0);
select creation_banque('Axa',0,0,0,0,0,0);

select ouverture_compte('Galichet','David','Bnp');;
select ouverture_compte('Galichet','David','Bnp');;
select ouverture_compte('Galichet','David','Axa');;
select ouverture_compte('Cruise','TOM','Lcl');;
select ouverture_compte('Cruise','TOM','Cic');;
select ouverture_compte('Cruise','TOM','Bnp');;
select ouverture_compte('Pitt','Brad','Axa');;
select ouverture_compte('Pitt','Brad','Axa');;
select ouverture_compte('Pitt','Brad','Axa');;

INSERT INTO interdit_bancaire(id_banque, id_client, date_debut) VALUES
(4,2,3);

