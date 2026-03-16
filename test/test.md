You can test both pipelines by uploading files to the S3 bucket. First, get your bucket name:

  cd /Users/dklett/code/homevision-project/terraform
  export BUCKET=$(terraform output -raw upload_bucket_name)

  Test Image Pipeline

  Upload a photo of a house:
  aws s3 cp /path/to/house-photo.jpg s3://$BUCKET/test-house.jpg

  Then check if it landed in Houses/:
  aws s3 ls s3://$BUCKET/Houses/

  And check the Lambda logs:
  aws logs tail /aws/lambda/homevision-image-processor --since 5m

  Test Text Pipeline

  Create a test address file:
  cat > /tmp/test-addresses.txt << 'EOF'
  123 Main St, Springfield, IL 62701
  456 Oak Ave, Austin, TX 78701
  10 Downing Street, London, UK
  1600 Pennsylvania Ave, Washington, DC 20500
  8 Rue de Rivoli, Paris, France
  EOF

  Upload it:
  aws s3 cp /tmp/test-addresses.txt s3://$BUCKET/test-addresses.txt

  Check the output files:
  aws s3 ls s3://$BUCKET/us-addresses/
  aws s3 ls s3://$BUCKET/non-us-addresses/
  aws s3 cp s3://$BUCKET/us-addresses/test-addresses.txt -
  aws s3 cp s3://$BUCKET/non-us-addresses/test-addresses.txt -

  And check logs:
  aws logs tail /aws/lambda/homevision-text-processor --since 5m

  If something doesn't work

  Check the DLQs for failed messages:
  aws sqs get-queue-attributes --queue-url $(terraform output -raw image_dlq_url) --attribute-names ApproximateNumberOfMessages
  aws sqs get-queue-attributes --queue-url $(terraform output -raw text_dlq_url) --attribute-names ApproximateNumberOfMessages
