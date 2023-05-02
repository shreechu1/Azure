Azure Service Health
====================

Azure offers a suite of experiences to keep you informed about the health of your cloud resources. This information includes current and upcoming issues such as service impacting events, planned maintenance, and other changes that may affect your availability.

[Service health] (https://learn.microsoft.com/en-us/azure/service-health/overview) provides a personalized view of the health of the Azure services and regions you're using. This is the best place to look for service impacting communications about outages, planned maintenance activities, and other health advisories because the authenticated Service Health experience knows which services and resources you currently use. The best way to use Service Health is to set up Service Health alerts to notify you via your preferred communication channels when service issues, planned maintenance, or other changes may affect the Azure services and regions you use. 

The other alternative is to have the view using the Azure Monitor workbook.

The workbook provides information about health service events 

Service Health events
---------------------
Service issues - Problems in the Azure services that affect you right now.
    
    ServiceHealthResources
    | where type =~ 'Microsoft.ResourceHealth/events'
    | extend eventType = properties.EventType, status = properties.Status, description = properties.Title, trackingId = properties.TrackingId, summary = properties.Summary, priority = properties.Priority, impactStartTime = properties.ImpactStartTime, impactMitigationTime = todatetime(tolong(properties.ImpactMitigationTime))
    | where eventType == 'HealthAdvisory’

Planned maintenance - Upcoming maintenance that can affect the availability of your services in the future.
Health advisories - Changes in Azure services that require your attention. Examples include deprecation of Azure features or upgrade requirements (e.g upgrade to a supported PHP framework)