-- Insertion des données

INSERT INTO personne (nom_personne, prenom_personne) VALUES
('Terik', 'Anais'), 
('Cruise', 'Tom'), 
('Pitt', 'Brad');
 
-- nom, seuil_remuneration, periode_remuneration, taux_remuneration
-- decouvert autorisé, taux_decouvert, agios, 
-- montant atomique pour la banque, montant hebdomadaire pour la banque
-- dépassement de découvert autorisé (vrai/faux), 
-- portee de la carte, cout de la carte
-- montant atomique autres banques, montant hebdomadaire autres banques.
select creation_banque('Bnp', 1, 30, 0.05, 100, 0.5, 25, 200, 100, FALSE, 'internationale', 20, 100, 500);
select creation_banque('Lcl', 100, 15, 0.03, 0, 0, 30, 200, 100, TRUE, 'nationale', 20, 100, 500);
select creation_banque('Cic', 0, 10, 0, 0.1, 0, 40, 200, 100, FALSE, 'nationale', 20, 100, 500);
select creation_banque('Axa', 0, 1, 0.005, 0, 0.10, 50, 200, 100, TRUE, 'nationale', 20, 100, 500);

select ouverture_compte('Terik', 'Anais', 'Bnp');;
select ouverture_compte('Terik', 'Anais', 'Bnp');;
select ouverture_compte('Terik', 'Anais', 'Axa');;
select ouverture_compte('Cruise', 'Tom', 'Lcl');;
select ouverture_compte('Cruise', 'Tom', 'Cic');;
select ouverture_compte('Cruise', 'Tom', 'Bnp');;
select ouverture_compte('Pitt', 'Brad', 'Axa');;
select ouverture_compte('Pitt', 'Brad', 'Axa');;
select ouverture_compte('Pitt', 'Brad', 'Axa');;

select depot(1, 1000, 'especes');
select depot(6, 10000, 'especes');
select depot(8, 1000, 'especes');
select depot(7, 500, 'especes');
select depot(9, 6000, 'especes');
select depot(4, 1010, 'especes');
select depot(2, 300, 'especes');
select depot(5, 500, 'especes');
select depot(3, 6000, 'especes');

INSERT INTO interdit_bancaire(id_banque, id_client, date_debut, date_regularisation) VALUES
(4, 2, 1, 3);


