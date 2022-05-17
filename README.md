# Azure-DevOps with GitHub-Repo

## Intro

Until yet I have only been using Azure-Repos in my DevOps Projects, but since this is done different at a recent project I am participating, I felt the need for a playground with similar conditions to explore the differences which appear when using Azure-DevOps with a GitHub Repository instead of the integrated Azure-Repos. Welcome to the Result :see_no_evil:

## What is being used

- [GitHub](https://github.com/Mauwii/azure-pipelines-with-github-repo.git)
- [Azure-DevOps](https://dev.azure.com/Mauwii/azure-pipelines-with-github-repo)
- [Jira](https://mauwii.atlassian.net/jira/software/c/projects/DG/issues)
- [MkDocs-Material](https://squidfunk.github.io/mkdocs-material/)
- [FastAPI](https://github.com/Azure-Samples/opencensus-with-fastapi-and-azure-monitor.git)

## Documentation

Since I had the needs for things I could play around with build-pipelines as well as a documentation framework, I decided to use MkDocs-Material since (imho):

- it is easy to use,
- fits everything I could need for code Documentation
- looks good
- has tons of addons available
- is hostable for free
- and maybe more ...

You can find the Documentation [here](https://mauwii.github.io/django_devops/), while it's sources are located in the [docs](https://github.com/Mauwii/django_devops/tree/stable/docs) folder. Until yet I only build the stable Branch automatically, but I am already thinking about using the "mike" plugin to have the ability of versioning the Documentation.

Also one of my next steps will be to have a second Environment for the Docs where I will build the docs for the main branch, which you will find here as soon as I have done so.

## Useful Stuff

### Mermaid live editor

[https://mermaid.live/](https://mermaid.live/) can be very useful when creating new Mermaid Diagrams. Source can be found [here](https://github.com/mermaid-js/mermaid-live-editor)
