---
title: Azure-Pipelines
---

### azure-pipelines.yml

This is the YAML File which defined the main Pipeline while Docs have been deployed. Most Parts of it are referencing Templates which are located bellow the subfolder `/azure-pipelines`

It is reflecting the chosen Branching-Strategy you'll find in the previous Section.

```yaml title="azure-pipelines.yml" linenums="1"
--8<-- "azure-pipelines.yml"
```

#### validate Bicep

This is the Template which is validating the bicep files. It is also calling a template which is creating a resource group for the resources and If conditions are met, it is calling another template to finally deploy the resources to Azure Resource Manager:

``` yaml title="bicep_jobs.yml" linenums="1"
--8<-- "azure-pipelines/jobs/bicep_jobs.yml"
```

##### create ResourceGroup

``` yaml title="create_resourceGroup.yml" linenums="1"
--8<-- "azure-pipelines/jobs/steps/create_resourceGroup.yml"
```

##### Deploy Bicep

``` yaml title="deploy_bicep.yml" linenums="1"
--8<-- "azure-pipelines/jobs/steps/deploy_bicep.yml"
```

#### mkdocs-material

This template is used to build and deploy the documentation you are just looking at :sweat_smile::

``` yaml title="mkdocs-material.yml" linenums="1"
--8<-- "azure-pipelines/jobs/mkdocs-material.yml"
```
