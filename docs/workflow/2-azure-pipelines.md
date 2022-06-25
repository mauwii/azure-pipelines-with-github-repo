---
title: Azure-Pipelines
# template: overrides/main.html
---

### azure-pipelines.yml

This is the YAML File which defined the main Pipeline while this Docs your are reading have been deployed. Most Parts of it are referencing Templates which are located bellow the subfolder `/azure-pipelines`.

I had the Idea to use this folder for pipeline Stage-Templates, then use the `azure-pipelines/jobs` subfolder for job-templates and finally a subfolder `azure-pipelines/jobs/steps` for, you guessed it, step-templates. But at the moment I am thinking to have another subfolder-stage `azure-pipelines/stages/jobs/steps`, and store pipelines directly in `azure-pipelines`, which atm are stored in `azure-pipelines/triggers` which feels kind of wrong.

??? quote "azure-pipelines.yml"

    ```yaml linenums="1"
    --8<-- "azure-pipelines.yml"
    ```

#### main.yml

This stage-template contains is defining the complete pipeline. I had it separated from `azure-pipelines.yml` to be able to run `validate_pr.yml` (pull request validation) with the same stages than `azure-pipelines.yml`, but while Writing this, I already get thoughts about a restructure, but would first need to test it out before I start writing documentation for it. In the end it could not work out and everything stays as it is :hear_no_evil:

??? quote "azure-pipelines/main.yml"

    ``` yaml linenums="1"
    --8<-- "azure-pipelines/stages/main.yml"
    ```

#### bicep_stage.yml

This stage is seperated in two jobs. where the first job is enumerating how often the second job needs to be run. Well, ok, this sounds a bit weird, but the secret is that it is not re-running the second job for x-times, but for every folder found in `IaC/bicep/deploy`. The steps which will then be done are found in the next section

??? quote "azure-pipelines/bicep_stage.yml"

    ``` yaml linenums="1"
    --8<-- "azure-pipelines/stages/bicep_stage.yml"
    ```

##### bicep_steps.yml

This step-template will:

1. validate that the bicep is buildable (which is converting it to a ARM Template)
2. create a resource group (no problem if called more than once and all runs belong to the same RG)
3. do some verifications if the bicep is valid and deployable
4. If conditions are met, it is calling another template to finally deploy the resources to Azure Resource Manager.

??? quote "azure-pipelines/jobs/steps/bicep_steps.yml"

    ``` yaml linenums="1"
    --8<-- "azure-pipelines/stages/jobs/steps/bicep_steps.yml"
    ```

##### create_resourceGroup.yml

Well, I think the headline has already explained what this step is all about :speak_no_evil:

??? quote "azure-pipelines/jobs/steps/create_resourceGroup.yml"

    ``` yaml linenums="1"
    --8<-- "azure-pipelines/stages/jobs/steps/create_resourceGroup.yml"
    ```

### mkdocs-material

This pipeline is validating, building and deploying the documentation you are just looking at :sweat_smile:

Validation is done with building the docs, if there is no error I suggest that everything will be fine after it is just a static website.

The Deployment step will only appear when the pipeline get run from `main` branch.

??? quote "azure-pipelines/mkdocs-material.yml"

    ``` yaml linenums="1"
    --8<-- "azure-pipelines/mkdocs-material.yml"
    ```

#### build_mkdocs.yml

??? quote "azure-pipelines/stages/jobs/steps/build_mkdocs.yml"

    ```yaml linenums="1"
    --8<-- "azure-pipelines/stages/jobs/steps/build_mkdocs.yml"
    ```

### devopsbuildagent.yml

This Pipeline will build a docker image of a DevOps-Agent, if you want to find out more about it's features, look [here](https://github.com/Mauwii/DevOpsBuildAgent/blob/main/README.md)

??? quote "azure-pipelines/devopsbuildagent.yml"

    ```yaml linenums="1"
    --8<-- "azure-pipelines/devopsbuildagent.yml"
    ```

### cleanup_automation.yml

This Pipeline will delete Resources in Subscriptions of the used Service Principal automatically. It differs between Resources which where available before and after a initial Date, which will have a defined range of days from creation before they will be deleted. While date is not reach, it will set a Tag on the Resource with the deletion date (which is just used for information). After the Resource has reached the defined age it will be deleted.

Necessary to use this Pipeline is a Service Principal with permission to delete Resources and Resource Locks.

??? quote "azure-pipelines/cleanup_automation.yml"

    ```yaml linenums="1"
    --8<-- "azure-pipelines/cleanup_automation.yml"
    ```

??? quote "scripts/cleanupautomation.ps1"

    ```powershell linenums="1"
    --8<-- "scripts/cleanupautomation.ps1"
    ```
