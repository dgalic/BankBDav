-- Insertion des données

INSERT INTO personne (nom_personne, prenom_personne) VALUES
('Galichet', 'David'), 
('Cruise', 'TOM'), 
('Pitt', 'Brad');
 
-- nom, seuil_remuneration, periode_remuneration, taux_remuneration
-- decouvert autorisé, taux_decouvert, agios, 
-- montant atomique pour la banque, montant hebdomadaire pour la banque
-- protection anti-decouvert (vrai/faux), 
-- portee de la carte, cout de la carte
-- montant atomique autres banques, montant hebdomadaire autres banques.
select creation_banque('Bnp', 1, 30, 0.05, 100, 0.05, 0, 200, 100, FALSE, 'internationale', 20, 100, 500);
select creation_banque('Lcl', 100, 15, 0.03, 0, 0, 0, 200, 100, FALSE, 'nationale', 20, 100, 500);
select creation_banque('Cic', 0, 10, 0, 0.1, 0, 0, 200, 100, FALSE, 'nationale', 20, 100, 500);
select creation_banque('Axa', 0, 1, 0, 0.005, 1000, 0, 200, 100, FALSE, 'nationale', 20, 100, 500);

select ouverture_compte('Galichet', 'David', 'Bnp');;
select ouverture_compte('Galichet', 'David', 'Bnp');;
select ouverture_compte('Galichet', 'David', 'Axa');;
select ouverture_compte('Cruise', 'TOM', 'Lcl');;
select ouverture_compte('Cruise', 'TOM', 'Cic');;
select ouverture_compte('Cruise', 'TOM', 'Bnp');;
select ouverture_compte('Pitt', 'Brad', 'Axa');;
select ouverture_compte('Pitt', 'Brad', 'Axa');;
select ouverture_compte('Pitt', 'Brad', 'Axa');;

select depot(1, 1000, 'especes');
select depot(6, 10000, 'especes');
select depot(8, 1000, 'especes');
select depot(7, 500, 'especes');
select depot(9, 6000, 'especes');
select depot(4, 1010, 'especes');
select depot(2, 200, 'especes');
select depot(5, 500, 'especes');
select depot(3, 6000, 'especes');

INSERT INTO interdit_bancaire(id_banque, id_client, date_debut) VALUES
(4, 2, 3);



