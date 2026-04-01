# 🎭 Azure Insiders Demo — Thomas vs Sisyphe

> **Session :** *Accélérez votre DevOps avec l'IA : du code au déploiement intelligent*  
> **Présentateurs :** Solution Engineer Software & Dev Productivity + Firas Mdimagh, CSA AI & Apps

---

## 🧱 Le Mythe de Thomas

Thomas est ingénieur DevOps dans une startup tech. Chaque semaine, il pousse son rocher en haut de la montagne. Et chaque vendredi à 17h, le rocher redescend.

Comme Sisyphe, Thomas est condamné à recommencer. **Mais aujourd'hui, ça change.**

> *"Il faut imaginer Sisyphe heureux. Nous, on préfère lui donner GitHub Copilot — et lui rendre ses week-ends."*

---

## 🪨 Les 4 Rochers de Thomas

| # | Le Rocher | Douleur | Outil qui brise le rocher |
|---|-----------|---------|--------------------------|
| 1 | **Pipeline cassé le vendredi** | CI/CD écrit à la main, 18 min de build, cassé en prod | GitHub Copilot (VS Code) |
| 2 | **Bug détecté en production** | Vulnérabilité SQL Injection découverte par un client | GitHub Copilot Coding Agent |
| 3 | **Incident de nuit, runbook page 47** | 2h du matin, runbook de 2021, Jean-Claude est parti | Agentic Workflows (GitHub Actions) |
| 4 | **Déploiement manuel : 18 min, les doigts croisés** | Anomalie post-deploy, Thomas est le pompier de service | Azure SRE Agent |

---

## 🎬 Les 4 Actes

### Acte I — Le Mythe
Présentation du personnage de Thomas et de la métaphore Sisyphe. Les 4 douleurs DevOps universelles. Le public reconnaît Thomas — c'est peut-être eux.

### Acte II — Le Rocher
Démonstration du problème : pipeline cassé, bug en prod, runbook illisible, déploiement risqué. Tout est réel, tout est douloureux.

### Acte III — Le Copilote
GitHub Copilot entre en scène. Chaque rocher est brisé, un par un, en temps réel devant le public.

### Acte IV — La Malédiction Brisée
Thomas n'est plus le pompier. Il est devenu **l'Architecte de la Fiabilité**. Mesures avant/après. Conclusion émotionnelle.

---

## 🎙️ Répartition des présentateurs

| Segment | Qui | Outil |
|---------|-----|-------|
| Intro — Le Mythe de Thomas | SE | Slides |
| Rocher 1 — Fix du pipeline | SE | Copilot in VS Code |
| Rocher 2 — Bug → PR automatique | SE | Coding Agent |
| Rocher 3 — Workflow incident | SE → Firas (transition) | Agentic Workflows |
| Rocher 4 — Azure SRE Agent | Firas | Azure SRE Agent |
| Conclusion — La malédiction brisée | Les deux | Slide finale |

---

## 🚀 Demo Flow — Instructions pas à pas

### Pré-requis avant la session
1. Fork ou clone ce repo dans un compte GitHub visible
2. Créer les 3 issues depuis `ISSUES_SEED.md`
3. Assigner l'Issue #1 (SQL Injection) à Copilot Coding Agent **10 min avant** la démo (il sera en train de travailler)
4. Pré-exécuter le workflow `incident-response.yml` et garder les logs ouverts dans un onglet
5. Ouvrir VS Code avec `app/app.py` et `.github/workflows/deploy.yml` prêts

---

### 🪨 Rocher 1 — Pipeline cassé (GitHub Copilot, ~5 min)

**Contexte à dire :** *"Thomas a écrit ce pipeline un vendredi soir. Vous voyez le commentaire en haut."*

1. Ouvrir `.github/workflows/deploy.yml` dans VS Code
2. Montrer les problèmes : runner `ubuntu-18.04`, jobs séquentiels, `python 3.8`, pas de cache
3. Ouvrir **Copilot Chat** : *"Explique pourquoi ce pipeline est sous-optimal et propose une version optimisée"*
4. Copilot explique en langage naturel
5. Montrer `deploy-fixed.yml` comme résultat : jobs parallèles, `ubuntu-latest`, cache pip, bandit scan
6. **Stat à annoncer : 18 min → 6 min, -67% de build**

**Punchline :** *"Thomas ne cherche plus la page 47 du runbook. Il demande en français, Copilot lui répond."*

---

### 🪨 Rocher 2 — Bug en prod (Coding Agent, ~7 min)

**Contexte à dire :** *"Un client a envoyé ce payload à 3h du matin. L'équipe a découvert la vulnérabilité en production."*

1. Ouvrir l'Issue #1 `[SECURITY] SQL Injection` dans le navigateur
2. Montrer le payload d'exemple dans l'issue
3. Cliquer **"Assign to Copilot"** sur l'issue (ou montrer que c'est déjà assigné)
4. **Parler au public pendant 2-3 min** (Coding Agent travaille en arrière-plan)
5. Rafraîchir → Copilot a ouvert une **Pull Request** avec :
   - Le fix (requête paramétrée)
   - Les tests manquants pour `/login`
   - Une description PR expliquant la remédiation
6. Montrer le diff — souligner que Copilot a ajouté les tests

**Punchline :** *"Avant, Thomas apprenait le bug par un client furieux. Maintenant, Copilot le résout pendant que Thomas boit son café."*

---

### 🪨 Rocher 3 — Incident de nuit (Agentic Workflow, ~6 min)

**Contexte à dire :** *"2h du matin. Une alerte. Thomas ouvre le runbook. Page 1... page 23... page 47."*

1. Ouvrir `runbooks/incident-runbook.md` — montrer rapidement la longueur et le step 47
2. **Transition :** *"Et si le workflow faisait ça automatiquement ?"*
3. Déclencher `incident-response.yml` via workflow_dispatch (ou montrer un run complété)
4. Parcourir les steps : Detect → Correlate → Diagnose → Remediate → Report
5. Montrer l'issue créée automatiquement avec le rapport d'incident structuré

**Punchline :** *"2h du matin, Thomas dort. Le workflow est déjà en train de rédiger le post-mortem."*

---

### 🪨 Rocher 4 — Azure SRE Agent (Firas, ~7 min)

*Handoff à Firas — voir script séparé Azure SRE Agent*

**Contexte à dire :** *"La PR est mergée, le déploiement tourne. Et là... une anomalie apparaît dans Azure Monitor."*

---

## 📁 Structure du projet

```
azure-insiders-demo/
├── README.md                           # Ce fichier
├── app/
│   ├── app.py                          # Flask app (avec vulnérabilité intentionnelle)
│   ├── requirements.txt
│   └── tests/
│       └── test_app.py                 # Tests incomplets (pour Coding Agent)
├── .github/
│   └── workflows/
│       ├── deploy.yml                  # ⚠️ Pipeline cassé (Rocher 1)
│       ├── deploy-fixed.yml            # ✅ Pipeline optimisé (post-Copilot)
│       └── incident-response.yml       # 🤖 Workflow agentic (Rocher 3)
├── infra/
│   └── main.bicep                      # Infrastructure Azure (App Service + SQL)
├── runbooks/
│   └── incident-runbook.md             # 😱 Runbook de 2021 (Rocher 3 — page 47)
└── ISSUES_SEED.md                      # Issues à créer avant la démo
```

---

## 📊 Métriques avant/après (pour les slides)

| Métrique | Avant (Thomas seul) | Après (Thomas + GitHub AI) |
|----------|--------------------|-----------------------------|
| Temps de build CI | 18 min | 6 min (-67%) |
| Temps de fix vulnérabilité | 2h | < 10 min |
| Temps de réponse incident | 2h (nuit) | Automatique |
| Déploiement manuel | 45 min | Supervisé + rollback auto |

---

*Projet créé pour Azure Insiders — Avril 2026*
