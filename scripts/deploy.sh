#commandes que j'ai trouvée sur la doc officielle Azure : https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-cli 
#!/bin/bash

# Création du groupe de ressources
az group create --name webapp-project-rg --location "westeurope"

# Déploiement de l'infrastructure avec Bicep
az deployment group create \
    --name bicep-deployment \
    --resource-group webapp-project-rg \
    --template-file $GITHUB_WORKSPACE/infrastructure/main.bicep \
    --parameters elyassWebApp=elyassWebApp \
                 elyassAppServicePlan=elyassAppServicePlan \
                 elyassStorageAccount=elyassstorageacc \
                 storageAccountsku=Standard_LRS

echo "Déploiement Bicep terminé. Attente de 30 secondes pour que les ressources soient complètement créées..."

# Attendre que la Web App soit complètement créée
sleep 30

# Vérifier que la Web App existe
echo "Vérification de l'existence de la Web App..."
az webapp show --name elyassWebApp --resource-group webapp-project-rg

echo "Déploiement terminé avec succès !"

