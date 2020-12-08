# APIM-CICD-Fixer
## Azure API Management DevOps Resource Kit - PessimisticConcurrencyConflict, Operation on the API is in progress

When using the [Azure API Management DevOps Resource Kit](https://github.com/Azure/azure-api-management-devops-resource-kit) to extract and then deploy multiple APIs through a DevOps CI/CD pipeline, we would get the following error during deployment:<br/>
"statusMessage": "{\"error\":{\"code\":\"PessimisticConcurrencyConflict\",\"message\":\"Operation on the API is in progress\",\"details\":null}}"

We ultimately found that if we were able to ensure that each API and Product deployed one after the other, it would eliminate the parallel deployment error. The downside is that deployment could take a little more time this way. The powershell script contained in this project will loop through the folders in the project directory, and add the "dependsOn" attribute for each one; generating the sequential deployment by referencing the preceeding API. The extractor should be run with the 'SplitAPIs = true' condition so that each API is extracted to its own folder, and the script should run at the root of your extracted folder, 'APIM' in this case.

As of this writing, the ticket we referenced is still open: https://github.com/Azure/azure-api-management-devops-resource-kit/issues/340
