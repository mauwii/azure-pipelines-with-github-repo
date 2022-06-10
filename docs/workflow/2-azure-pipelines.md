---
title: Azure-Pipelines
# template: overrides/main.html
---

### azure-pipelines.yml

This is the YAML File which defined the main Pipeline while this Docs your are reading have been deployed. Most Parts of it are referencing Templates which are located bellow the subfolder `/azure-pipelines`.

I had the Idea to use this folder for pipeline Stage-Templates, then use the `azure-pipelines/jobs` subfolder for job-templates and finally a subfolder `azure-pipelines/jobs/steps` for, you guessed it, step-templates. But at the moment I am thinking to have another subfolder-stage `azure-pipelines/stages/jobs/steps`, and store pipelines directly in `azure-pipelines`, which atm are stored in `azure-pipelines/triggers` which feels kind of wrong.

??? quote "YAML"

    ```yaml title="azure-pipelines.yml" linenums="1"
    --8<-- "azure-pipelines.yml"
    ```

#### main.yml

This stage-template contains is defining the complete pipeline. I had it separated from `azure-pipelines.yml` to be able to run `validate_pr.yml` (pull request validation) with the same stages than `azure-pipelines.yml`, but while Writing this, I already get thoughts about a restructure, but would first need to test it out before I start writing documentation for it. In the end it could not work out and everything stays as it is :hear_no_evil:

??? quote "YAML"

    ``` yaml title="azure-pipelines/main.yml" linenums="1"
    --8<-- "azure-pipelines/stages/main.yml"
    ```

#### bicep_stage.yml

This stage is seperated in two jobs. where the first job is enumerating how often the second job needs to be run. Well, ok, this sounds a bit weird, but the secret is that it is not re-running the second job for x-times, but for every folder found in `IaC/bicep/deploy`. The steps which will then be done are found in the next section

??? quote "YAML"

    ``` yaml title="azure-pipelines/bicep_stage.yml" linenums="1"
    --8<-- "azure-pipelines/stages/bicep_stage.yml"
    ```

##### bicep_steps.yml

This step-template will:

1. validate that the bicep is buildable (which is converting it to a ARM Template)
2. create a resource group (no problem if called more than once and all runs belong to the same RG)
3. do some verifications if the bicep is valid and deployable
4. If conditions are met, it is calling another template to finally deploy the resources to Azure Resource Manager.

??? quote "YAML"

    ``` yaml title="azure-pipelines/jobs/steps/bicep_steps.yml" linenums="1"
    --8<-- "azure-pipelines/stages/jobs/steps/bicep_steps.yml"
    ```

##### create_resourceGroup.yml

Well, I think the headline has already explained what this step is all about :speak_no_evil:

??? quote "YAML"

    ``` yaml title="azure-pipelines/jobs/steps/create_resourceGroup.yml" linenums="1"
    --8<-- "azure-pipelines/stages/jobs/steps/create_resourceGroup.yml"
    ```

#### mkdocs-material

This template is used to build and deploy the documentation you are just looking at :sweat_smile:

Validation is done with building the docs, if there is no error I suggest that everything will be fine after it is just a static website.

The Deployment will only run if parameter `mkdocsDeploy` is `true`

??? quote "YAML"

    ``` yaml title="azure-pipelines/jobs/mkdocs-material.yml" linenums="1"
    --8<-- "azure-pipelines/stages/jobs/mkdocs-material.yml"
    ```
