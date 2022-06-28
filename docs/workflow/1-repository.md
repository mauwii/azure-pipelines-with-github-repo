---
title: Repository
# template: overrides/main.html
---

In this Section you will find Information related to the Workflow of the Repository.

## Branching Strategy

### Table

| Branch name                         | Create From  |           accept PR from            | Branch protection rules / other Info                                                                                       |
| :---------------------------------- | :----------: | :---------------------------------: | :------------------------------------------------------------------------------------------------------------------------- |
| main                                |   git init   | feature/\*<br>issue/\*<br>update/\* | Require linear history<br>Require status checks to pass before merging<br>Require branches to be up to date before merging |
| feature/\*<br>issue/\*<br>update/\* | Head of main |                  -                  | must be up to date with main for PR                                                                                        |

Main branch is used as the working branch. To develope new features, create a branch from the main branch with a reasonable Name ( like `feature/<jira-id>/<feature-name>` for new features, or `issue/<jira-id>/<issue-name>` when solving a issue). When development of the feature or issue is done, create a pull request to merge it into main branch.

### Diagrams

#### From feature/issue/update to main

``` mermaid
graph LR
  featureBranch[feature/*<br>issue/*<br>update/*] -- Pull Request ---> main;
  code[\update<br>Code/] -- Commit Changes --> featureBranch;
  main -. create branch .-> featureBranch;
  main -- Trigger Build --> CheckFeature{Built<br>successful};
  CheckFeature -- Yes --> mergePR[/merge PR/];
  CheckFeature -- No --> TryFixBugsFeature{Try to<br>fix bugs};
  mergePR --> deleteFeature;
  TryFixBugsFeature -- No --> deleteFeature[\Delete feature/issue branch\];
  TryFixBugsFeature -- Yes --> code;
```

#### commit flow example

``` mermaid
gitGraph
  commit
  branch feature-1
  checkout feature-1
  commit
  checkout main
  merge feature-1
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
  checkout feature-3
  commit
  checkout main
  merge feature-3
  checkout feature-4
  commit
  checkout main
  merge feature-4
```

### Automation

Of course the approach is to have as much done automatic as possible, which also means that pull-request should in the end get tested and resolved by themselves, as long as you did not overwrite code which does not belong to yourself. For the last, a Review by the code-owner would be necessary.
