# ⏰ AWS EventBridge Scheduler Stack - CloudFormation Template

This AWS CloudFormation template provisions an **EventBridge Scheduler** to periodically invoke a specified **Lambda function**, supporting integration tasks such as data polling or updates. The stack includes an **IAM execution role**, customizable **schedule expression**, and **input payload**, ensuring flexible and secure execution control.

---

## 📌 Features

- Creates an **EventBridge Scheduler** using AWS Scheduler service
- Configurable **cron expression** for schedule frequency
- Dynamically targets a **Lambda function**
- Supports **custom JSON input** for the target function
- Includes **IAM role** with least privilege for Lambda invocation
- Configurable **retry policy** and **event age**

## 🧭 Architecture Overview

This stack is designed to schedule periodic polling of XML data from **Wine Owners (Wine Hub)** APIs. The architecture includes the following components:

- ⏲️ **EventBridge Scheduler**: Triggers a Lambda function daily at **5:00 AM UTC** based on a cron expression.
- 🧠 **Lambda Function**: Sends an API request to Wine Owners and receives an **XML response**. This response is passed to a Python-based parser.
- ⚙️ **Python Parser**: Parses the XML data, generates **SQL scripts**, and stores them in an **Amazon S3 bucket** for downstream processing or archival.
- 🔐 **IAM Role**: Grants the EventBridge Scheduler permission to securely invoke the Lambda function.
- 📩 **SNS (Simple Notification Service)**: Configured as a **failure destination** for the Lambda function.

### 🛡️ Failure Handling

If the Lambda function execution fails, it triggers an **SNS topic** that acts as a centralized failure notification mechanism. This SNS topic has three subscribers:

- 📧 **Email**: Sends email alerts to system administrators or stakeholders.
- 💬 **Slack**: Posts real-time alerts to a configured Slack channel.
- 🛠️ **Lambda Function**: Executes additional failure handling logic, such as logging, retry mechanisms, or other corrective actions.

This robust architecture ensures high visibility and quick response to integration issues.

![VPC Architecture](../architecture-diagram/eventbridge.drawio.png)

## 📝 Parameters

Customize the EventBridge Scheduler deployment using the parameters below:

### 🔧 Scheduler Configuration

| Parameter                    | Description                            | Type     | Default                                          | Constraints                     |
|-----------------------------|----------------------------------------|----------|--------------------------------------------------|---------------------------------|
| `EnvironmentName`           | Name of the environment                | String   | `prod`                                           | `dev` / `prod` / `test`         |
| `EventBridgeSchedulerName`  | Name of the EventBridge scheduler      | String   | `cru-integrations-flow-eventbridge-scheduler`   | Must be unique per region       |
| `TargetLambdaFunctionName`  | Lambda function to invoke              | String   | `cru-integrations-data-poller`                  | Must exist in your account      |
| `ScheduleExpression`        | Cron expression for schedule           | String   | `cron(0 5 * * ? *)`                              | Follows AWS cron format         |
| `TargetInput`               | JSON input payload for the Lambda      | String   | JSON array with `countryCode`, `method`, `url`  | Must be valid JSON              |
| `MaxEventAge`               | Max event age in seconds               | Number   | `7200`                                           | 60–86400 seconds                |
| `MaxRetryAttempts`          | Number of retry attempts               | Number   | `5`                                              | 0–185                           |
| `SchedulerState`            | State of the scheduler                 | String   | `ENABLED`                                        | `ENABLED` / `DISABLED`          |

## 🔐 Security Considerations

- **IAM Role**: Grants the EventBridge Scheduler permission to invoke the Lambda function, scoped by function name and account ID.
    
- **Scoped Lambda Access**: The IAM policy restricts invocation to only the intended Lambda function and its aliases or versions.
    
- **Input Validation**: Payload is configurable but should conform to the expected schema in the target Lambda.

## 🚀 Usage

You can deploy this stack using the AWS Management Console, AWS CLI, or automation pipelines.

### ✅ Example: Deploy using AWS CLI

```bash
aws cloudformation deploy \
  --template-file eventbridge-scheduler.yaml \
  --stack-name cru-eventbridge-scheduler \
  --parameter-overrides \
    EnvironmentName=prod \
    EventBridgeSchedulerName=cru-integrations-flow-eventbridge-scheduler \
    TargetLambdaFunctionName=cru-integrations-data-poller \
    ScheduleExpression="cron(0 5 * * ? *)" \
    TargetInput='[{"countryCode": "UK", "method": "GET", "url": "https://v22-services.hub.wine/xml/CWUK-DATA-BACKU-564FD5/data-backup/huborganisation"}, {"countryCode": "FR", "method": "GET", "url": "https://v22-services.hub.wine/xml/CWFR-DATAFEEDFO-1E7712/data-backup/huborganisation"}]' \
    MaxEvent
