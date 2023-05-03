Workbook to list all Azure cache for Redis , AKS, APIM instances with versions
==============================================================================
The workbook provides a list of all Azure Redis caches, AKS clusters and APIM instances with version information which helps to keep track of retirements

The Workbook underneath is using [Azure Resource Graph](https://learn.microsoft.com/en-us/azure/governance/resource-graph/overview) which helps you to now programatically query the needed information on Azure resources for your subscriptions.

How to deploy the monitor workbook ?
------------------------------------

1. From Azure portal, search for Monitor
2. Navigate to the Workbooks blade and create a new workbook
3. Click and open the the advanced editor
![ ](/ServiceHealth/Adv.png)
4. Clear the contents and paste the contents of the workbook.json attached
5. Click done editing
6. Save the workbook
7. Workbook should be ready to be consumed

![Workbook sample screenshot](/Workbooks/WorkbookRedisAKSAPIM.png)