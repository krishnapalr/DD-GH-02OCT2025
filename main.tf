terraform {
  required_providers {
    datadog = {
      source  = "datadog/datadog"
      version = "~> 3.74.0" # You can adjust version as needed
    }
  }
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
}


resource "datadog_monitor" "PRD-TCD-Azure_App_Service_5xx_Error_namename" {
  evaluation_delay = 300
  new_group_delay = 60
  on_missing_data = "show_no_data"
  require_full_window = false
  monitor_thresholds {
    critical = 5
  }
  name = "Azure App Service 5xx Error – {{name.name}}"
  type = "query alert"
  tags = ["env:prd", "deploy_by:iac", "tr_application-asset-insight-id:208548"]
  query = <<EOT
sum(last_15m):sum:azure.app_services.http5xx{env:prd OR tr_application-asset-insight-id:208548} by {name}.as_count() / sum:azure.app_services.requests{env:prd OR tr_application-asset-insight-id:208548} by {name}.as_count() * 100 > 5
EOT
  message = <<EOT
@krishnapal.rajput@thomsonreuters.com

**Azure App Service 5xx Alert**

Service: {{name.name}}

We detected an elevated number of HTTP 5xx errors:
- Value: {{value}}
- Threshold: {{threshold}}

This may indicate backend issues or service instability. Please investigate logs, recent deployments, and dependencies.

Tags: {{tags}}
Time: {{timestamp}}

[View in Datadog]({{link}})

---

**Recovery Notice**

The 5xx error rate has returned to normal for service: {{name.name}}.
- Current Value: {{value}}
- Recovery Threshold: {{threshold}}

No further action is required unless issues reoccur.

Tags: {{tags}}
Time: {{timestamp}}

[View in Datadog]({{link}})

EOT
}