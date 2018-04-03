            
# Processus de cooptation des personnes morales à la chaintech avec utilisation de Smart Contract

## Situation :

Après différentes tentatives ayant échoué pour les raisons suivantes :

- manque d’accord sur sa définition : par qui ? comment ? pourquoi ?
- le manque de temps des acteurs pour participer à une procédure qui nécessite un fort travail de recherche pour chaque personne morale postulante, qui a conduit à la formation d’une équipe réduite passant en revue un grand nombre de candidatures, dénaturant le process de son intérêt original,
- aucun intérêt économique à bien réaliser la procédure.

## Proposition :
### Le besoin :

L’association la Chaintech se veut être un interlocuteur de référence avec les pouvoirs publics, mais sans représenter des personnes morales. De plus il a toujours été voulu de mettre en avant les acteurs francophones effectuant un travail de qualité parmi la quantité de projets qui sont plus ou moins des arnaques (extrait de l’appel du 18 juin 2016 https://www.chaintech.fr/association : “ **dont la légitimité proviendrait du travail de terrain de ceux qui la portent au quotidien.** ”).

Est donc volontairement exclue de la liste des propositions l’adhésion des personnes morales ouverte à tous.

Il est par conséquent nécessaire que la procédure d’adhésion des personnes morales à l’association soit contraignante (mais pas trop); se pose alors plusieurs problèmes d’éthique et d’organisation. Qui doit le faire et comment ?

#### Un comité ?

Un comité réduit de « juges » chargés de traiter tous les dossiers et dont la légitimité proviendrait d’un quelconque mandat ? Cette solution soulève dès lors plusieurs problématiques :

- celle du temps nécessaire à ce groupe de personnes pour effectuer correctement ce travail,
- comment sont élus les "juges", quelle doit être leur légitimité, comment est mis en place la procédure, les garde-fous, ...
- du risque de "copinage" et avis biaisés.

Même si ce n’est pas la procédure qui avait été choisie pour opérer la cooptation, c’est quand même celle ci qui a prévalu en raison du manque de disponibilités de la majorité des personnes morales pour participer à l'exercice de cooptation. Il s’en est suivi de nombreuses critiques, légitimes, puis son arrêt.

#### Les personnes morales déjà acceptées dans l’association? 

Dès le début, l’association a su réunir plusieurs acteurs de référence, tant sur le plan national qu'international, considérés comme étant de confiance. L’objectif est donc d’étendre ce réseau de confiance par les personnes en font partie.

### Incitation économique :

Pour tenter de parer la problématique du temps nécessaire aux acteurs pour participer à cette procédure, il semble nécessaire qu’il y ait une incitation économique à le faire. La grande majorité des acteurs n'est pas intéressée par des € (invalidant l'intérêt de créer un token qui permettrait de bénéficier de réductions sur l'adhésion à l'association) et la procédure serait alimentée par des ethers, il semble donc judicieux que cet actif soit choisi pour la rémunération. De ce point de vue, le intérêts individuels peuvent être mis au service de l'association.

En adoptant un tel système, nous serions précurseurs en la matière : application d’un use case réel sur une nouvelle technologie qui est également le support de travail d'un grand nombre de nos membres. 

## Idée de procédure :

Un porteur de projet/personne morale se rend sur la page dédiée à cet effet. Lui est expliqué le fonctionnement de la cooptation et son prix. Il remplit le formulaire prévu à cet effet et une fois le formulaire validé un hash ipfs lui est transmis ainsi que l’adresse du contrat.

Il soumet sa candidature au smart contract de l’association, via une tx comprenant :

- Le hash ipfs (pas de restrictions, plusieurs postulations peuvent être faites simultanément)
- une donation proportionnelle au coût de la procédure, définie de la façon suivante : nombre d’acteurs * prix moyen des tx * variable_prix [1]. Cette donation permettra aux acteurs d’être rémunérés (en plus de couvrir les frais) en utilisant la fonction withdraw du SC.

Un service (automatique ou manuel) enverra un mail à tous les membres du smart contract pour qu’ils effectuent la procédure de vote.

Le timeout permettant à tous les membres de voter est de X (2) semaines. Au delà de cette période, seul le nombre minimum de vote du quorum est nécessaire pour pour valider le vote.

Le quorum est de ?? (1/3 des membres, 1/2?, accord positif de 75 % des participants au vote ?)

Le bureau possède un veto qui doit faire l’unanimité des membres du bureau et faire l’objet d’un compte rendu lors ce qu’il est employé.

- Lors ce que la personne morale a été acceptée, elle doit payer sa cotisation annuelle de 50€ (pour 3 membres, +10€ par membre de plus, (**à définir**)). Une fois le paiement effectué, un membre du bureau finalise la procédure et le postulant devient apte à participer à la procédure.

- En cas de résultat négatif au vote du quorum, un mail de refus avec les raisons invoqués par les membres sera transmis au postulant.

- En cas d’invalidation de la procédure par le veto, les personnes ayant voté à l’inverse du bureau ne recevront pas de compensation pour ce vote et les eth resteront en séquestre sur le SC jusqu’au prochain vote. Le veto fonctionne dans les 2 cas : acceptation et refus ; il se doit de rester une procédure d’urgence suite à une fraude clairement identifiée, ou tout autre raison particulièrement explicite.

Il n’y a pas de timeout sur la procédure et fonctionne en file d’attente : les acteurs doivent voter par ordre chronologique de manière à ce que ne soit pas validé un candidat ayant postulé plus tard que d’autres. Les acteurs peuvent tout de même voter sur plusieurs projets (une ou plusieurs tx??)

L’exclusion d’un membre votant se fait suite à un décision à l’unanimité du bureau. Elle fait suite à une assemblée générale extraordinaire car la personne morale n’a pas respecté le règlement de l’association.

L’exclusion d’un membre du bureau (suite à une assemblée générale extraordinaire) ou le transfert du droit de vote (suite au transfert du mandat) nécessite ⅔ signatures du bureau.

## Autres considérations techniques :
- [1] : peut être modifié à l’unanimité par le bureau. L’objectif est d’avoir un équilibre entre un coût assez élevé pour le postulant afin qu’il ne floode pas et que les votant soit suffisamment rémunérés pour être incité à le faire. Il ne faut pas non plus que ce soit trop cher pour ne pas décourager les potentiels postulants.
- La procédure doit pouvoir être modifiable sans que tout le système ai besoin de migrer de contrat

