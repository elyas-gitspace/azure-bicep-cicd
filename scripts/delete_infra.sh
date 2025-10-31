#!/bin/bash

# Dans ce script, je supprime l'infrastructure (pour que je n'ai pas à le faire manuellement)

az group delete --name webapp-project-rg --yes --no-wait
