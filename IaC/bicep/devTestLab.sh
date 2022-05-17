#!/usr/bin/env bash

az group create --name exampleRG --location eastus
az deployment group create --resource-group exampleRG --template-file main.bicep --parameters labName=mauwiiLab vmName=mauwiiLabVMrrrr userName=mauwii
