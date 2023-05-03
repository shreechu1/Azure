Azure Service Health
====================

Azure offers a suite of experiences to keep you informed about the health of your cloud resources. This information includes current and upcoming issues such as service impacting events, planned maintenance, and other changes that may affect your availability.

[Service health](https://learn.microsoft.com/en-us/azure/service-health/overview) provides a personalized view of the health of the Azure services and regions you're using. This is the best place to look for service impacting communications about outages, planned maintenance activities, and other health advisories because the authenticated Service Health experience knows which services and resources you currently use. The best way to use Service Health is to set up Service Health alerts to notify you via your preferred communication channels when service issues, planned maintenance, or other changes may affect the Azure services and regions you use. 

The other alternative is to have the view using the Azure Monitor workbook.

The workbook provides information about health service events. 

Service Health events
---------------------

Using [Azure Resource Graph](https://learn.microsoft.com/en-us/azure/governance/resource-graph/overview) , you now programatically query the Service health events for your subscriptions.

Service issues - Problems in the Azure services that affect you right now.
    
    ServiceHealthResources
    | where type =~ 'Microsoft.ResourceHealth/events'
    | extend eventType = properties.EventType, status = properties.Status, description = properties.Title, trackingId = properties.TrackingId, summary = properties.Summary, priority = properties.Priority, impactStartTime = properties.ImpactStartTime, impactMitigationTime = todatetime(tolong(properties.ImpactMitigationTime))
    | where eventType == 'ServiceIssue'

Planned maintenance - Upcoming maintenance that can affect the availability of your services in the future.

    ServiceHealthResources
    | where type =~ 'Microsoft.ResourceHealth/events'
    | extend eventType = properties.EventType, status = properties.Status, description = properties.Title, trackingId = properties.TrackingId, summary = properties.Summary, priority = properties.Priority, impactStartTime = properties.ImpactStartTime, impactMitigationTime = todatetime(tolong(properties.ImpactMitigationTime))
    | where eventType == 'PlannedMaintenance

Health advisories - Changes in Azure services that require your attention. Examples include deprecation of Azure features or upgrade requirements (e.g upgrade to a supported PHP framework)

    ServiceHealthResources
    | where type =~ 'Microsoft.ResourceHealth/events'
    | extend eventType = properties.EventType, status = properties.Status, description = properties.Title, trackingId = properties.TrackingId, summary = properties.Summary, priority = properties.Priority, impactStartTime = properties.ImpactStartTime, impactMitigationTime = todatetime(tolong(properties.ImpactMitigationTime))
    | where eventType == 'HealthAdvisory’

Retirement Notices - Provides a quick view of all Azure retirements notices detected on the scoped subscriptions based on date parameter

KQL Query with date parameter
-----------------------------

    servicehealthresources
    | extend eventType = properties.EventType, status = properties.Status, description = properties.Title, trackingId = properties.TrackingId, summary = properties.Summary, priority = properties.Priority, impactStartTime = properties.ImpactStartTime, impactMitigationTime = todatetime(tolong(properties.ImpactMitigationTime))
    | mv-expand  propvalue = properties.Impact
    | extend ImpactedService = propvalue.ImpactedService
    | where eventType == "HealthAdvisory" and description contains "Retirement" and impactMitigationTime in ({RetirementDate})
    | project subscriptionId,eventType,impactMitigationTime,ImpactedService,description,properties,format_datetime(impactMitigationTime,'yyyy-dd-MM'),trackingId
    | join kind=inner (
    resourcecontainers
    | where type == 'microsoft.resources/subscriptions'
    |project subscriptionId,name
    ) 
    on subscriptionId
    | summarize by Retirement_Date=format_datetime(impactMitigationTime,'yyyy-dd-MM'),Subscription_ID=subscriptionId,Subscription_Name=name,Impacted_Service=tostring(ImpactedService),Description=tostring(description),Properties=tostring(properties),Tracking_ID=tostring(trackingId)

KQL Query without date parameter
--------------------------------

    servicehealthresources
    | extend eventType = properties.EventType, status = properties.Status, description = properties.Title, trackingId = properties.TrackingId, summary = properties.Summary, priority = properties.Priority, impactStartTime = properties.ImpactStartTime, impactMitigationTime = todatetime(tolong(properties.ImpactMitigationTime))
    | mv-expand  propvalue = properties.Impact
    | extend ImpactedService = propvalue.ImpactedService
    | where eventType == "HealthAdvisory" and description contains "Retirement"
    | project subscriptionId,eventType,impactMitigationTime,ImpactedService,description,properties,format_datetime(impactMitigationTime,'yyyy-dd-MM'),trackingId
    | join kind=inner (
    resourcecontainers
    | where type == 'microsoft.resources/subscriptions'
    |project subscriptionId,name
    ) 
    on subscriptionId
    | summarize by Retirement_Date=format_datetime(impactMitigationTime,'yyyy-dd-MM'),Subscription_ID=subscriptionId,Subscription_Name=name,Impacted_Service=tostring(ImpactedService),Description=tostring(description),Properties=tostring(properties),Tracking_ID=tostring(trackingId)  

![Sample screenshot of retirements](/ServiceHealth/retirements.png))

How to deploy the monitor workbook ?
------------------------------------

1. From Azure portal, search for Monitor
2. Navigate to the Workbooks blade and create a new workbook
3. Open the advanced editor
4. Clear the contents and paste the contents of the workbook.json attached
5. Click done editing 
6. Save the workbook
7. Workbook should be ready to be consumed 

![Workbook sample screenshot](/ServiceHealth/WorkbookScreenshot.png)