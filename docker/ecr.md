## guild on how to push image to ecr https://docs.aws.amazon.com/AmazonECR/latest/userguide/getting-started-cli.html

```bash
docker build -t hello-world .
aws ecr get-login-password --region region | docker login --username AWS --password-stdin aws_account_id.dkr.ecr.region.amazonaws.com
aws ecr create-repository --repository-name hello-world --image-scanning-configuration scanOnPush=true --region us-east-1
docker tag hello-world:latest aws_account_id.dkr.ecr.us-east-1.amazonaws.com/hello-world:latest
docker push aws_account_id.dkr.ecr.us-east-1.amazonaws.com/hello-world:latest

