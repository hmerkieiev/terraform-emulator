# terraform-emulator

A local stand for one idea: a small Terraform stack can be applied to AWS Emulator, and the resources can be read back in the shape that was asked for.

This is a portfolio example. It is not an employer's account, and it contains no account identifier. The only account the apply talks to is the emulator's `000000000000`.

## What it creates

A registry with immutable tags, a bucket that blocks public access, and a role. The role trusts one GitHub subject, this repository on `main`, and its policy names that registry and that bucket. `ecr:GetAuthorizationToken` is the one action AWS requires on `*`.

## What it does not show

The emulator does not evaluate IAM the way AWS does. A trust that would be denied in an account can still succeed here. The check reads the document back. It does not prove the denial. A cluster, a VPC, and an apply against an account are a different step, and the emulator is a weak stand-in for those.

## Run

Docker on macOS. The Linux package on Linux. Terraform 1.10 or newer, the AWS CLI, and Python 3.

```sh
scripts/apply
```

The script points the AWS CLI and Terraform at `https://127.0.0.1:9297`, refuses to continue unless the caller is the emulator, applies the stack, reads it back, and plans again. The second plan has to be empty. The same script is the CI job. That job has no cloud credentials.

## License

[MIT](LICENSE)
