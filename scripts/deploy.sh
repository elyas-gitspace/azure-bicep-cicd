#!/bin/bash

#commandes que j'ai trouvée sur la doc officielle Azure : https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-cli 
az group create --name webapp-project-rg --location "westeurope"

az deployment group create \
	--name bicep-deployment \
	--resource-group webapp-project-rg \
	--template-file ../infrastructure/main.bicep \
	--parameters storageAccountType=Standard_LRS

echo "Déploiement terminé avec succès !"



