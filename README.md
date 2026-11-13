# terraform-emulator

A local stand for one idea: a small Terraform stack can be applied to AWS Emulator, and a second stack that widens the same resources is refused.

This is a portfolio example. It is not an employer's account, and it contains no account identifier. The only account the apply talks to is the emulator's `000000000000`. [AWS Emulator](https://github.com/aws/aws-emulator) is the local API.

The `apply` workflow has to pass. The `widened (expected failure)` workflow fails on every push. That failure lists each mistake in `terraform/rejected`. A red mark on the commit is that refusal.

## What it creates

A registry with immutable tags. A bucket that blocks public access, versions objects, and encrypts them with a key that rotates. A second bucket holds a trail, also closed, with log-file validation. The CI role trusts this repository on `main`. Its policy names that registry and that bucket. `ecr:GetAuthorizationToken` is the one action AWS requires on `*`. The key policy's one statement is the root of the emulator account, because a key policy has no key ARN until the key exists.

A queue with a dead-letter queue, encryption, and a policy that allows one topic and one rule. The topic uses the key and is subscribed to the queue. A pipe reads a second queue and publishes to the topic. That pipe's role is allowed those two actions and nothing else. A schedule sends to the queue once an hour. A rule on its own bus does the same.

A table on demand, with hash key `id`. A stream kept for 48 hours. A delivery stream that writes into the bucket under `firehose/`. A log group kept for 14 days. A file system encrypted with the key.

A function, a state machine with one succeed state, and an ECS cluster with no services. CodeCommit, CodeBuild with no source, CodePipeline, and a CodeDeploy application for Lambda. Each of those roles trusts one service.

GuardDuty, an account Access Analyzer, and a regional web ACL whose default action is allow. A public hosted zone that is not delegated. A certificate request for that name. An SES identity for the same name. A Cognito pool with a 14-character password. AppConfig, a Cloud Map HTTP namespace, a schema registry, an X-Ray group, and a secret container with no secret value.

## What it does not show

The emulator does not evaluate the CI role's trust the way AWS does. A trust that would be denied in an account can still succeed here. The check reads the document back. It does not prove the denial.

The certificate is requested, not issued. The SES identity is only required to exist. The topic keeps the default policy AWS writes, and the check does not treat that policy as ours.

Glue is left out. Creating the database works, and the provider then reads its tags with an empty account id, because that lookup is skipped so S3 does not go through S3 Control. SSM is far from AWS. EC2, a VPC, EKS, RDS, ElastiCache, a load balancer, and CloudFormation are the weak side of the emulator, so a green apply there would not mean the same apply would work in an account.

Two fields are ignored on later plans. The emulator reports an unset DynamoDB on-demand maximum as `-1`, and it fills a Kinesis warm throughput the configuration does not set.

## The widened stack

`terraform/rejected` is the registry, the bucket, and the role, with the mistakes written in the files. Tags are mutable, and scan on push is off. The public access block is open. The trust is `StringLike` with a wildcard principal, subject, and audience. The policy allows `s3:GetObject` on `*`.

`scripts/reject` applies that stack to a fresh emulator. The apply completes. The check then names each mistake and exits, and that exit fails the `widened (expected failure)` workflow. The apply workflow does not run this stack.

## Run

Docker on macOS. The Linux package on Linux. Terraform 1.10 or newer, the AWS CLI, and Python 3.

```sh
scripts/apply
scripts/reject
```

`scripts/apply` points the AWS CLI and Terraform at `https://127.0.0.1:9297`, refuses to continue unless the caller is the emulator, applies the stack, reads it back, and plans again. The second plan has to be empty. That script is the apply workflow, and the workflow succeeds.

`scripts/reject` is the `widened (expected failure)` workflow. The workflow fails, and the log lists each mistake. Neither workflow has cloud credentials.

## License

[MIT](LICENSE)
