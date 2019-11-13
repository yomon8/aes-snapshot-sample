#!/bin/bash

# 設定ファイルの読み込み
source ./settings.sh

# Lambda Layerとして必要なPythonライブラリをダウンロード
docker run --rm -v $(pwd)/layer/python:/python python:3.7.5-alpine pip install -t /python requests-aws4auth elasticsearch elasticsearch-curator

# Cloudformation でデプロイ
aws cloudformation package --template-file ./template.yaml --output-template-file ./package.yaml \
    --s3-bucket ${STACK_S3_BUCKET} \
    --s3-prefix ${STACK_S3_PREFIX} 
aws cloudformation deploy --template-file ./package.yaml --capabilities CAPABILITY_IAM \
    --stack-name ${STACK_NAME} \
    --parameter-overrides \
    AESHost=${AES_HOST} \
    LambdaSubnetId=${LAMBDA_SUBNET_ID} \
    LambdaSecurityGroupId=${LAMBDA_SECURITY_GROUP_ID} \
    SnapshotRepositoryName=${SNAPSHOT_REPOSITORY_NAME} \
    SnapshotPrefix=${SNAPSHOT_PREFIX} 

# メッセージ表示
echo ""
echo "1. 最初に一回、以下のコマンドを実行します."
echo aws lambda invoke --function-name $(aws cloudformation describe-stacks --stack-name ${STACK_NAME} --query 'Stacks[].Outputs[?OutputKey == `RegistSnapshotFunctionName`].OutputValue' --output text):live /dev/null
echo ""
echo "2. スナップショットを手動で取得するには、以下のコマンドを実行します."
echo "   なお、こちらのLambdaはスケジュール実行も設定されています."
echo aws lambda invoke --function-name $(aws cloudformation describe-stacks --stack-name ${STACK_NAME} --query 'Stacks[].Outputs[?OutputKey == `RotateSnapshotFunctionName`].OutputValue' --output text):live /dev/null
echo ""