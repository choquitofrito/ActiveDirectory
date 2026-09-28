## Annexe : ouvrir une session sur le contrôleur de domaine avec un compte utilisateur ?

Pour tester une délégation ou une permission avec un utilisateur (`ivan`, `cindy`…), on est tenté de se connecter directement sur `dns1` avec ce compte. Par défaut, Windows refuse : « La méthode de connexion que vous tentez d'utiliser n'est pas autorisée ». **C'est voulu, et il ne faut pas le contourner.**

### Pourquoi on ne donne pas ce droit sur un DC

Le droit **Permettre l'ouverture d'une session locale** d'un contrôleur de domaine est défini par la GPO **Default Domain Controllers Policy**. Par défaut, seuls des groupes d'administration l'ont (Administrateurs, Opérateurs de compte, de sauvegarde, d'impression, de serveur, ENTERPRISE DOMAIN CONTROLLERS).

L'accorder à des utilisateurs ordinaires serait une faille :

- un DC contient la base de tous les comptes du domaine (`ntds.dit`) ; tout accès interactif élargit la surface d'attaque ;
- une session ouverte sur le DC laisse des identifiants en mémoire et permet d'y exécuter des programmes ;
- une fois le droit donné « pour tester », il est rarement retiré.

En entreprise, même les administrateurs ouvrent le moins possible de sessions sur un DC.

### La bonne méthode

| Besoin | Où le tester |
|--------|--------------|
| Tester ce que voit un **utilisateur** (partages, GPO, lecteurs réseau) | Sur le **poste client** `ws-IT-01` (ou `ws-RH-01`), connecté avec `MAXTEC\ivan`, `MAXTEC\cindy`… |
| Tester une **délégation d'administration** (ex. réinitialiser des mots de passe dans une OU) | Sur le **poste client**, avec les outils d'administration **RSAT** installés, connecté avec le compte délégué |

**Installer RSAT sur Windows 11** (session administrateur local, avec accès Internet ou via **Paramètres > Système > Fonctionnalités facultatives > Ajouter une fonctionnalité**, rechercher « RSAT ») :

```powershell
Get-WindowsCapability -Online -Name "Rsat.ActiveDirectory*" | Add-WindowsCapability -Online
Get-WindowsCapability -Online -Name "Rsat.GroupPolicy*"     | Add-WindowsCapability -Online
```

Ensuite, `dsa.msc` (Utilisateurs et ordinateurs Active Directory) et le module PowerShell `ActiveDirectory` sont disponibles sur le poste, et le compte délégué ne peut faire que ce que la délégation lui permet.

!!! tip "Sans Internet sur le poste client"
    L'installation de RSAT télécharge les composants depuis Windows Update. Branchez temporairement une carte NAT sur la VM cliente le temps de l'installation, puis retirez-la.
