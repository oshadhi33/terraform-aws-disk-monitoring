import os
import json
import urllib.request

def lambda_handler(event, context):
    webhook_url = os.environ['SLACK_WEBHOOK_URL']

    for record in event.get('Records', []):
        sns = record.get('Sns', {})
        raw_message = sns.get('Message', '').strip()

        if not raw_message:
            print("Empty SNS message.")
            continue

        try:
            parsed = json.loads(raw_message)
            alert_text = "\n".join(f"*{k.capitalize()}:* {v}" for k, v in parsed.items())
            title = parsed.get("alert", "🚨 Alert")
        except json.JSONDecodeError:
            alert_text = raw_message
            title = "🚨 Alert"

        parsed = json.loads(raw_message)
        alert_text = "\n".join(f"*{k.capitalize()}:* {v}" for k, v in parsed.items())
        title = parsed.get("alert", "🚨 Alert")
        
        payload = {
            "blocks": [
                {
                    "type": "header",
                    "text": {
                        "type": "plain_text",
                        "text": f"🚨 {title}"
                    }
                },
                {
                    "type": "section",
                    "text": {
                        "type": "mrkdwn",
                        "text": alert_text
                    }
                }
            ]
        }


        req = urllib.request.Request(
            webhook_url,
            data=json.dumps(payload).encode('utf-8'),
            headers={'Content-Type': 'application/json'}
        )

        try:
            with urllib.request.urlopen(req) as response:
                print(f"Message sent: {response.status}")
        except Exception as e:
            print(f"Error sending message: {str(e)}")
