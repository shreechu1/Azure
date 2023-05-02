Alerts for Azure Compute Quotas
===============================

Many Azure services have quotas, which are the assigned number of resources for your Azure subscription. Each quota represents a specific countable resource, such as the number of virtual machines you can create, the number of storage accounts you can use concurrently, the number of networking resources you can consume, or the number of API calls to a particular service you can make.

The concept of quotas is designed to help protect customers from things like inaccurately resourced deployments and mistaken consumption. For Azure, it helps minimize risks from deceptive or inappropriate consumption and unexpected demand. Quotas are set and enforced in the scope of the subscription.

Adjustable and non-adjustable quotas
------------------------------------

Quotas can be adjustable or non-adjustable.


1. Adjustable quotas: Quotas for which you can request quota increases fall into this category. Each subscription has a default quota value for each quota. You can request an increase for an adjustable quota from the Azure Home My quotas page, providing an amount or usage percentage and submitting it directly. This is the quickest way to increase quotas.
2. Non-adjustable quotas: These are quotas which have a hard limit, usually determined by the scope of the subscription. To make changes, you must submit a support request, and the Azure support team will help provide solutions.

This article describes on how to automate alerts when a compute quota reaches its threshold. 

Logic
-----

Since there's no direct way to alert for a quota breach. This automation explains a custom way to query for compute quota usage using a powershell script using Azure automation account, Ingest the data to a custom log analytics workspace which is then used to create dymanic alerts for necessary threshold. 

Prerequities - 
Since we will have an automation account that periodically fires the powershell script, this scripts needs to be executed as a "Run as" account