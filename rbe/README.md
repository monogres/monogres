# 📦 Setup a build cluster

## Configure your AWS credentials

Begin by adding to `~/.aws/config` a `monogres` profile:

```ini
[profile monogres]
region = eu-west-2
output = json
```

And valid credentials to `~/.aws/credentials`:

```ini
[monogres]
aws_access_key_id=XXXXXXXXXXXXXXXXX
aws_secret_access_key=xxxxxxxxxxxxxxxxxxx
```

Also, make sure the credentials file is only readable by your user.

Finally, set the profile in your working environment:

```sh
export AWS_PROFILE="monogres"
```

## Delegate subdomain

```sh
export SUBDOMAIN="rbe.monogres.dev"
export AWS_REGION="eu-west-2"

aws route53 create-hosted-zone \
    --name "$SUBDOMAIN" \
    --caller-reference "$(uuidgen)"

export ZONE_ID="$(
aws route53 list-hosted-zones-by-name \
    --dns-name "$SUBDOMAIN" \
    --query 'HostedZones[0].Id' \
    --output text | xargs basename
)"
```

If the `create-hosted-zone` fails due to permissions:

```sh
aws iam create-policy \
    --policy-name Route53HostedZoneManagement \
    --policy-document file:///dev/stdin <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:CreateHostedZone",
        "route53:GetHostedZone",
        "route53:ListHostedZones",
        "route53:GetHostedZoneCount",
        "route53:ListResourceRecordSets",
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": "*"
    }
  ]
}
EOF

aws iam attach-user-policy \
    --user-name "$USERNAME" \
    --policy-arn arn:aws:iam::857517990941:policy/Route53HostedZoneManagement
```

Finally, add the `NS` records for the subdomain to the main DNS zone:

```sh
aws route53 list-resource-record-sets \
    --hosted-zone-id "$ZONE_ID" \
    --query "ResourceRecordSets[?Type == 'NS'].ResourceRecords[*].Value | []" \
    --output text | tr '\t' '\n'
```

## Create policy ARNs

### `external-dns-route53-$SUBDOMAIN` policy

Setup a policy to update the subdomain DNS zone in Route53:

<!-- markdownlint-capture -->
<!-- markdownlint-disable MD013 -->

```sh
export POLICY_NAME="external-dns-route53-$SUBDOMAIN"

aws iam create-policy \
    --policy-name "$POLICY_NAME" \
    --description "This policy allows external-dns to manage DNS records in Route53 $SUBDOMAIN hosted zone." \
    --policy-document file:///dev/stdin <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "route53:ChangeResourceRecordSets",
      "Resource": "arn:aws:route53:::hostedzone/$ZONE_ID"
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets",
        "route53:ListTagsForResources"
      ],
      "Resource": "*"
    }
  ]
}
EOF

export POLICY_ARN="$(
aws iam list-policies \
    --query "Policies[?PolicyName=='$POLICY_NAME'].Arn" \
    --output text
)"
```

<!-- markdownlint-restore -->

Then, add the policy to the `attachPolicyARNs` of the `external-dns` service
account in the `iam` section of the EKS cluster config
(`eks/buildcluster.yaml`) so that it's attached to the service account on
cluster creation.

### `cert-manager-route53-$SUBDOMAIN` policy

Setup a policy for `cert-manager` to manage DNS records in Route53:

<!-- markdownlint-capture -->
<!-- markdownlint-disable MD013 -->

```sh
export POLICY_NAME="cert-manager-route53-$SUBDOMAIN"

aws iam create-policy \
    --policy-name "$POLICY_NAME" \
    --description "This policy allows cert-manager to manage records in Route53 $SUBDOMAIN hosted zone." \
    --policy-document file:///dev/stdin <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "route53:GetChange",
      "Resource": "arn:aws:route53:::change/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets",
        "route53:ListResourceRecordSets"
      ],
      "Resource": "arn:aws:route53:::hostedzone/$ZONE_ID"
    },
    {
      "Effect": "Allow",
      "Action": "route53:ListHostedZonesByName",
      "Resource": "*"
    }
  ]
}
EOF

export POLICY_ARN="$(
aws iam list-policies \
    --query "Policies[?PolicyName=='$POLICY_NAME'].Arn" \
    --output text
)"
```

<!-- markdownlint-restore -->

Then, add the policy to the `attachPolicyARNs` of the `cert-manager` service
account in the `iam` section of the EKS cluster config
(`eks/buildcluster.yaml`) so that it's attached to the service account on
cluster creation.

### `cert-secret-syncer-acm-$SUBDOMAIN` policy

Setup a policy for `cert-secret-syncer` to sync `cert-manager` non-ACM certs to
ACM:

<!-- markdownlint-capture -->
<!-- markdownlint-disable MD013 -->

```sh
export POLICY_NAME="cert-secret-syncer-acm-$SUBDOMAIN"

aws iam create-policy \
    --policy-name "$POLICY_NAME" \
    --description "This policy allows cert-secret-syncer to sync non-AMC certs created by cert-manager for Ingress to the AWS ACM so that they work with AWS LBC" \
    --policy-document file:///dev/stdin <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "acm:ImportCertificate",
        "acm:ListTagsForCertificate",
        "acm:AddTagsToCertificate"
      ],
      "Resource": "*"
    }
  ]
}
EOF

export POLICY_ARN="$(
aws iam list-policies \
    --query "Policies[?PolicyName=='$POLICY_NAME'].Arn" \
    --output text
)"
```

<!-- markdownlint-restore -->

Then, add the policy to the `attachPolicyARNs` of the `cert-secret-syncer`
service account in the `iam` section of the EKS cluster config
(`eks/buildcluster.yaml`) so that it's attached to the service account on
cluster creation.

## Create the Kubernetes cluster

```sh
export EKS_CLUSTER_NAME="buildcluster"

eksctl create cluster --config-file "eks/${EKS_CLUSTER_NAME}.yaml"
```

## [Install AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/deploy/installation/)

```sh
helm install \
    aws-load-balancer-controller \
    aws-load-balancer-controller \
    --repo https://aws.github.io/eks-charts \
    --version 1.13.3 \
    --namespace aws-lbc \
    --set "clusterName=$EKS_CLUSTER_NAME" \
    --set "serviceAccount.name=aws-lbc" \
    --set "serviceAccount.create=false"
```

## [Install `cert-manager`](https://cert-manager.io/docs/installation/helm/)

Also, see [`cert-manager` + EKS + Let's
Encrypt tutorial](https://cert-manager.io/docs/tutorials/getting-started-aws-letsencrypt/).

```sh
helm install \
    cert-manager \
    cert-manager \
    --repo https://charts.jetstack.io \
    --version v1.18.2 \
    --namespace cert-manager \
    --create-namespace \
    --set crds.enabled=true \
    --set "serviceAccount.name=cert-manager" \
    --set "serviceAccount.create=false"
```

## [Install `cert-secret-syncer`](https://)

```sh

helm install \
    cert-secret-syncer \
    cert-secret-syncer \
    --repo https://jenkins-x-charts.github.io/repo \
    --version v1.3.3 \
    --namespace cert-secret-syncer \
    --create-namespace \
    --set "serviceAccount.name=cert-secret-syncer" \
    --set "serviceAccount.create=false"
```

## [Install `external-dns`](https://kubernetes-sigs.github.io/external-dns/latest/docs/tutorials/aws-load-balancer-controller/)

<!-- markdownlint-capture -->
<!-- markdownlint-disable MD013 -->

```sh
export EXTERNAL_DNS_ROLE_ARN="$(
eksctl get iamserviceaccount \
    --cluster "$EKS_CLUSTER_NAME" \
    --name external-dns \
    --namespace external-dns \
    -o json | jq -r '.[0].status.roleARN'
)"

export EXTERNAL_DNS_ROLE="$(basename "$EXTERNAL_DNS_ROLE_ARN")"

helm install \
    external-dns \
    external-dns \
    --repo https://kubernetes-sigs.github.io/external-dns/ \
    --version 1.18.0 \
    --namespace external-dns \
    --set provider.name=aws \
    --set "extraArgs[0]=--domain-filter=$SUBDOMAIN" \
    --set "env[0].name=AWS_DEFAULT_REGION" \
    --set "env[0].value=$AWS_REGION" \
    --set "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn=$EXTERNAL_DNS_ROLE_ARN" \
    --set "serviceAccount.name=external-dns" \
    --set "serviceAccount.create=false"
```

<!-- markdownlint-restore -->

## Deploy BuildBarn

The `kustomize` configs are based off the Kubernetes example in
[buildbarn/bb-deployments].

```sh
kubectl apply --kustomize k8s/buildbarn
```

Make sure to create a secret with the registry credentials so that the workers
can use private container images:

```sh
kubectl create secret docker-registry ghcr-secret \
    --namespace=buildbarn \
    --docker-server=https://ghcr.io \
    --docker-username=USERNAME \
    --docker-password=ghp_GH_TOKEN_WITH_READ_PACKAGE_PERMISSIONS
```

[buildbarn/bb-deployments]: https://github.com/buildbarn/bb-deployments

## Check DNS

```sh
kubectl get ingress --namespace buildbarn

aws route53 list-resource-record-sets --hosted-zone-id "$ZONE_ID"
```

Test with:

```sh
grpcurl \
    -d '{}' \
    "$SUBDOMAIN:443" \
    build.bazel.remote.execution.v2.Capabilities/GetCapabilities

curl -vk "https://browser.$SUBDOMAIN"

curl -vk "https://scheduler.$SUBDOMAIN"
```

## Cleanup Kubernetes

```sh
kubectl delete --kustomize k8s/buildbarn
```

## Delete cluster

```sh
eksctl delete cluster --name="$EKS_CLUSTER_NAME" --region="$AWS_REGION"
```

## Frequently used commands

### Manually set cluster in `.kube/config`

After `eksctl` creates the cluster, it sets it as the default cluster in
`.kube/config`, but if you need to manually set it, use:

```sh
aws eks update-kubeconfig --name "$EKS_CLUSTER_NAME" --region "$AWS_REGION"
```

### Get an overview of the cluster

```sh
kubectl get all --namespace=buildbarn -o wide
```

### Describe a pod and get logs (when running)

```sh
kubectl describe --namespace=buildbarn <POD>
```

```sh
kubectl logs --namespace=buildbarn <POD>
```

### Create service account attaching policy

```sh
eksctl create iamserviceaccount \
    --cluster "$EKS_CLUSTER_NAME" \
    --name "external-dns" \
    --namespace "external-dns" \
    --attach-policy-arn "$POLICY_ARN" \
    --approve
```

### Attach policy to service account

```sh
aws iam attach-role-policy \
    --role-name "$EXTERNAL_DNS_ROLE" \
    --policy-arn "$POLICY_ARN"
```

### List attached policies

```sh
aws iam list-attached-role-policies \
    --role-name "$EXTERNAL_DNS_ROLE"
```

### Check certificate

```sh
kubectl get certificate --namespace buildbarn

kubectl get secret rbe-cert --namespace buildbarn -o yaml
```
