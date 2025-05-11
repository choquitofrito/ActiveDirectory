# Simple and intermediate exercices plan

## Goal 

Create series of exercices for Active Directory dealing with:

- Organizational Units
- Groups
- Users
- Computers
- Permissions
- Services
- Shares
- etc... 


## Infrastructure

We have a Virtualized environment with 3 VMs:

- 1 AD DS Domain Controller
- 1 Workstation (W10) for the moment

## Rules

- When asked, create simple, engaging and practical exercices, we'll create more complex exercices later
- Exercices will be linked to real situations whenever possible based on our infrastructure
  
- Use the concepts learnt in previous chapters.
- The exercices MUST be created to use the infrastructure defined in the previous chapter (partially or fully)
- Use the tools and commands learnt in previous chapters (no powershell for the moment)
- Use the domain maxtec.be (as defined in the previous chapter), but remember that we have just the server `dns1.maxtec.be` (DC) and two workstations `ws-compta-01.maxtec.be` and `ws-02.maxtec.be`. These exist in the virtualized environment, so exercices will be created to use them.
- Use the IP addresses defined in the previous chapter for the 


## Rules for creating exercices and solutions

- **IMPORTANT**: Don't modify any existing exercices files or solutions files unless asked to do so.

- You'll be prompted to create exercices for a certain chapter.

### Exemple of exercice creation

"Create exercices for chapter `Chapitre 4.Gestion_des_Utilisateurs.md`"

will add exercices to a file called `ex_Chapitre 4.Gestion_des_Utilisateurs.md` in the folder `/exercices/enonces` 

**IMPORTANT**: the file will already exist, so add your exercices to the end of the file. The subjects for the exercices are in a table of contents inside the file, but you can add new subjects taken from the corresponding syllabus file (syllabus folder) if it's useful.


# Exemple of solution creation
- Solutions will be created **only when asked**
- Solutions will explaining using sequences of commands in the GUI (no powershell). Simplify as much as possible. 
- Solutions will be created in .md format in the folder `/exercices/solutions` with a coherent structure.

- **IMPORTANT**: before creating solutions, ask for permission since we may choose only a few exercices to store and others will be ignored
