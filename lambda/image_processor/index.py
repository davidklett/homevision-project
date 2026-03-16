import json
import logging
import os

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client("s3")
rekognition = boto3.client("rekognition")
cloudwatch = boto3.client("cloudwatch")

BUCKET_NAME = os.environ["BUCKET_NAME"]
HOUSES_PREFIX = os.environ["HOUSES_PREFIX"]
METRIC_NAMESPACE = os.environ.get("METRIC_NAMESPACE", "HomeVision")


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
            logger.info("Processing image: s3://%s/%s", bucket, key)

            if key.startswith(HOUSES_PREFIX):
                logger.info("Skipping file already in Houses/ folder: %s", key)
                continue

            try:
                response = rekognition.detect_labels(
                    Image={"S3Object": {"Bucket": bucket, "Name": key}},
                    MaxLabels=20,
                    MinConfidence=70,
                )

                labels = [label["Name"].lower() for label in response["Labels"]]
                logger.info("Detected labels: %s", labels)

                if "house" in labels or "building" in labels or "housing" in labels:
                    dest_key = HOUSES_PREFIX + key.split("/")[-1]
                    s3.copy_object(
                        Bucket=BUCKET_NAME,
                        CopySource={"Bucket": bucket, "Key": key},
                        Key=dest_key,
                    )
                    logger.info("House detected — copied to %s", dest_key)
                    emit_metrics({"HousesDetected": 1, "ImagesProcessed": 1})
                else:
                    logger.info("No house detected in image")
                    emit_metrics({"ImagesWithNoHouse": 1, "ImagesProcessed": 1})

            except Exception:
                logger.exception("Error processing image %s", key)
                emit_metrics({"ImageProcessingErrors": 1, "ImagesProcessed": 1})
