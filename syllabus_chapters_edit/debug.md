

Vérifier GPO client

:

Vérifier l'emplacement du script
Ouvrez l'éditeur de GPO
Allez dans : Configuration utilisateur > Paramètres Windows > Scripts
Vérifiez que le script est bien dans : \\maxtec.be\SYSVOL\maxtec.be\Policies\{ID-GPO}\User\Scripts\Logon
Vérifier les journaux d'événements
Sur le poste client, ouvrez l'Observateur d'événements
Regardez dans : Applications et Services Logs > Microsoft > Windows > Group Policy > Operational
Tester la GPO
Sur le poste client, ouvrez une invite de commande en administrateur
Tapez : gpresult /r pour voir si la GPO est bien appliquée
Tapez : gpresult /h rapport.html pour un rapport détaillé
Vérifier les permissions
Le script doit être accessible en lecture pour les utilisateurs
Vérifiez les ACLs sur le dossier SYSVOL