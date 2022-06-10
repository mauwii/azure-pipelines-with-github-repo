---
title: Repository
# template: overrides/main.html
---

In this Section you will find Information related to the Workflow of the Repository.

## Branching Strategy

### Table

| Branch name                         |  Create From   | deploy to  |                  accept PR from                  | Branch protection rules / other Info                                                                                       |
| :---------------------------------- | :------------: | :--------: | :----------------------------------------------: | :------------------------------------------------------------------------------------------------------------------------- |
| main                                |    git init    |  staging   | feature/\*<br>issue/\*<br>update/\*<br>hotfix/\* | Require linear history<br>Require status checks to pass before merging<br>Require branches to be up to date before merging |
| stable                              |  Pull-Request  | production |                main<br>hotfix/\*                 |                                                                                                                            |
| feature/\*<br>issue/\*<br>update/\* |  Head of main  | test local |                        -                         | must be up to date with main for PR                                                                                        |
| hotfix/*                            | Head of stable | test local |                        -                         |

Main branch is used as the working branch. To develope new features, create branch from main branch called `feature/<jira-id>/<feature-name>` for new features, or `issue/<jira-id>/<issue-name>` when solving a issue. When development of the feature or issue is done, create a pull request to merge it into main branch.

When time has come for a release, create a pull request to merge main into stable.

For bigger problems, like f.E. a zero-day, create a branch from stable and name it `hotfix/<jira-id>` and try to fix the issue asap. When done, merge this hotfix back into stable as well as main.

### Diagrams

#### Small

``` mermaid
graph LR
  featureBranch[feature/*<br>issue/*] --> main;
  main -.-> featureBranch;
  main --> stable;
  stable -.-> hotfix;
  hotfix --> stable & main;
```

#### Detailed

##### From feature/issue to main

``` mermaid
graph LR
  featureBranch[feature/*<br>issue/*] -- Pull Request ---> main;
  code[\update<br>Code/] -- Commit Changes --> featureBranch;
  main -. create branch .-> featureBranch;
  main -- Trigger Build --> CheckFeature{Built<br>successful};
  CheckFeature -- Yes --> mergePR[/merge PR/];
  CheckFeature -- No --> TryFixBugsFeature{Try to<br>fix bugs};
  mergePR --> deleteFeature;
  TryFixBugsFeature -- No --> deleteFeature[\Delete feature/issue branch\];
  TryFixBugsFeature -- Yes --> code;
```

##### From main to stable

``` mermaid
graph LR
  main -- Pull Request ---> stable;
  stable -- Trigger<br>Build --> validateBuild{Built<br>succesfull};
  stable -. create branch .-> hotfix;
  validateBuild -- Yes --> completePr[/merge PR/];
  completePr --> deployStable[/Deploy to<br>production/];
  validateBuild -- No --> hotfix;
  hotfix -- Pull Request--> main & stable;
```

#### commit flow example

``` mermaid
gitGraph
  commit
  branch stable
  branch feature-1
  checkout feature-1
  commit
  checkout main
  merge feature-1
  checkout stable
  merge main
  checkout main
  branch feature-2
  branch feature-3
  checkout feature-2
  commit
  checkout feature-3
  commit
  checkout main
  merge feature-2
  branch feature-4
  checkout feature-4
  commit
  checkout stable
  branch hotfix-1
  checkout hotfix-1
  commit
  checkout stable
  merge hotfix-1
  checkout main
  merge hotfix-1
  checkout feature-3
  commit
  checkout main
  merge feature-3
  checkout feature-4
  commit
  checkout main
  merge feature-4
  checkout stable
  merge main
```

### Automation

Of course the approach is to have as much automated as possible, which also means that pull-request should in the end get tested and resolved by themselves (...or the help of Azure-Pipelines :material-microsoft-azure-devops:)
