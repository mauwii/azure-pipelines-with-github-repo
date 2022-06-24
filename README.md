# Azure-DevOps with GitHub-Repo

[![Build Status](https://dev.azure.com/Mauwii/azure-pipelines-with-github-repo/_apis/build/status/azure-pipelines.yml?branchName=main)](https://dev.azure.com/Mauwii/azure-pipelines-with-github-repo/_build/latest?definitionId=19&branchName=main)

## Intro

First of all a huge Thank you to Microsoft for the free Build Agents!!! Finally I can continue to use my playground as before :kissing_heart:

Until yet I have only been using Azure-Repos in my DevOps Projects, but since this is done different at a recent project I am participating, I felt the need for a playground with similar conditions to explore the differences which appear when using Azure-DevOps with a GitHub Repository instead of the integrated Azure-Repos. Welcome to the Result :see_no_evil:

Of course this is one of the things which will obviously never finish, but the reason is that I cannot imagine mysellf stopping from playing around with stuff like this in my spare time :trollface:

## What is being used

- [GitHub](https://github.com/Mauwii/azure-pipelines-with-github-repo/)
- [Azure-DevOps](https://dev.azure.com/Mauwii/azure-pipelines-with-github-repo/)
- [Jira](https://mauwii.atlassian.net/jira/software/c/projects/APWGR/issues)
- [MkDocs-Material](https://squidfunk.github.io/mkdocs-material/)

### will be added soon...

- [FastAPI](https://github.com/Azure-Samples/fastapi-on-azure-functions.git)
- [Jfrog Platform](https://mauwii.jfrog.io)

## Documentation

Since I had the needs for things I could play around with build-pipelines as well as a documentation framework, I decided to use MkDocs-Material since (imho):

- it is easy to use,
- fits everything I could need for code Documentation
- looks good
- has tons of addons available
- is hostable for free
- and maybe more ...

You can find the built Documentation [here](https://mauwii.github.io/azure-pipelines-with-github-repo/), while it's sources are located in [`docs`](./docs/) and the framework which was used to built it is located in [`src/mkdocs-material`](src/mkdocs-material/). At the moment only the docs of the main Branch are built, but I am already thinking about using the plugin [`mike`](https://squidfunk.github.io/mkdocs-material/setup/setting-up-versioning/#versioning) to built it for the stable branch as well.

## Useful Stuff

### Mermaid live editor

[https://mermaid.live/](https://mermaid.live/) can be very useful when creating new Mermaid Diagrams. Source can be found [here](https://github.com/mermaid-js/mermaid-live-editor)
