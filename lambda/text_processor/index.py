import json
import logging
import os
import re

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client("s3")
cloudwatch = boto3.client("cloudwatch")

BUCKET_NAME = os.environ["BUCKET_NAME"]
US_PREFIX = os.environ["US_PREFIX"]
NON_US_PREFIX = os.environ["NON_US_PREFIX"]
METRIC_NAMESPACE = os.environ.get("METRIC_NAMESPACE", "HomeVision")

US_STATE_PATTERN = re.compile(
    r",\s*(AL|AK|AZ|AR|CA|CO|CT|DE|FL|GA|HI|ID|IL|IN|IA|KS|KY|LA|ME|MD|"
    r"MA|MI|MN|MS|MO|MT|NE|NV|NH|NJ|NM|NY|NC|ND|OH|OK|OR|PA|RI|SC|SD|"
    r"TN|TX|UT|VT|VA|WA|WV|WI|WY|DC)\s+\d{5}"
)


def is_us_address(line):
    """Classify an address as US if it matches a state abbreviation + ZIP pattern."""
    return bool(US_STATE_PATTERN.search(line))


def emit_metrics(metrics):
    """Emit a batch of custom metrics to CloudWatch."""
    try:
        cloudwatch.put_metric_data(
            Namespace=METRIC_NAMESPACE,
            MetricData=[
                {"MetricName": name, "Value": value, "Unit": "Count"}
                for name, value in metrics.items()
            ],
        )
    except Exception:
        logger.exception("Failed to emit CloudWatch metrics")


def handler(event, context):
    for record in event["Records"]:
        body = json.loads(record["body"])
        s3_records = body.get("Records", [body])

        for s3_record in s3_records:
            bucket = s3_record["s3"]["bucket"]["name"]
            key = s3_record["s3"]["object"]["key"]
            logger.info("Processing text file: s3://%s/%s", bucket, key)

            if key.startswith(US_PREFIX) or key.startswith(NON_US_PREFIX):
                logger.info("Skipping output file: %s", key)
                continue

            obj = s3.get_object(Bucket=bucket, Key=key)
            content = obj["Body"].read().decode("utf-8")
            lines = [line.strip() for line in content.splitlines() if line.strip()]

            if not lines:
                logger.warning("Empty text file: %s", key)
                return

            us_addresses = []
            non_us_addresses = []

            for line in lines:
                if is_us_address(line):
                    us_addresses.append(line)
                else:
                    non_us_addresses.append(line)

            base_name = key.split("/")[-1]

            if us_addresses:
                us_key = US_PREFIX + base_name
                s3.put_object(
                    Bucket=BUCKET_NAME,
                    Key=us_key,
                    Body="\n".join(us_addresses) + "\n",
                )
                logger.info("Wrote %d US addresses to %s", len(us_addresses), us_key)

            if non_us_addresses:
                non_us_key = NON_US_PREFIX + base_name
                s3.put_object(
                    Bucket=BUCKET_NAME,
                    Key=non_us_key,
                    Body="\n".join(non_us_addresses) + "\n",
                )
                logger.info(
                    "Wrote %d non-US addresses to %s",
                    len(non_us_addresses),
                    non_us_key,
                )

            emit_metrics({
                "USAddresses": len(us_addresses),
                "NonUSAddresses": len(non_us_addresses),
                "TextFilesProcessed": 1,
            })
