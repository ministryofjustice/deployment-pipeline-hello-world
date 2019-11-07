# Deployment Pipeline Hello World
https://dsdmoj.atlassian.net/browse/AM-224

An example of continuous deployment using a Spring Boot application that will be deployed into AWS from CircleCI. 

## What we wanted to find out
We are trying to define what our ideal deployment pipeline looks like for [CCMS Provider User Interface and Connector](https://github.com/ministryofjustice/laa-ccms-pui).

The codebases are currently a little messy. There are 2 applications in a single git repo, and what should probably be shared libraries in the same.

A more idiomatic, greenfield application might look a little different.

To learn about how we might go about creating something that is a Dockerised Java application which talks to a database and is deployed via CircleCI, we created a greenfield thing that shows us what the golden path might be. This is the "Hello World" app.

The prototype deploys to 2 different environments in different AWS accounts to show how differnet environments can be managed with Terraform.

We decided not to include a database in this prototype, because:

- we think that databases will be managed through a seperate pipeline ([ADR 42](https://github.com/ministryofjustice/laa-architectural-decisions/blob/master/doc/adr/0042-database-pipeline.md)) and application changes shouldn't be rolled out at the same time as database changes
- we will also learn something from deploying the [CCMS provider details API](https://github.com/ministryofjustice/laa-ccms-provider-details-api)

We based much of this on the work the OPG infrastructure team have already done. For more information, see:
- [CircleCI Pipeline for the Use an LPA service](https://github.com/ministryofjustice/opg-use-an-lpa/blob/aaea7c51715d0149953abdd4a4f746e9934c10e8/.circleci/config.yml)
- [ADR on Continuous Delivery](https://github.com/ministryofjustice/opg-use-an-lpa/blob/master/docs/architecture/decisions/0006-continuous-delivery.md)
- [ADR on Splitting Terraform Configuration](https://github.com/ministryofjustice/opg-use-an-lpa/blob/master/docs/architecture/decisions/0007-split-terraform-configuration.md)

We are aiming to match OPG's cycle times:
- sub-10 minutes for dev cycle
- sub-15 minute for promote changes to from dev through to production

## How it works
This is a Dockerised Spring Boot application.
We are using CircleCI to manage the deployment pipelines, and Terraform to manage infrastructure in AWS.

We create the following infrastructure in AWS using Terraform:
- An ECR repository
- An ECS cluster
- A load balancer
- Security groups for the load balancer
- Route53 DNS records
- Cloudwatch alarms
- Cloudwatch logs

We use different Terraform workspaces for the different environments.

The pipeline:
- Runs unit tests using Gradle
- Builds the JAR file
- Pushes the JAR file to the ECR repository
- Creates a plan of the infrastructure changes in the dev environement
- Makes the infrastructure changes in the dev environment (after manually approving the previous step)
- Creates a plan of the infrastructure changes in the test environement
- Makes the infrastructure changes in the test environment (after manually approving the previous step)

## What we didn't do

Tags aren't working. We think this is a setting that is disabled in users not created recently enough, and this might be fixed by creating a new user. There is [a screenshot](https://user-images.githubusercontent.com/12000935/51914181-87d06380-23d8-11e9-9234-c38c1b76c709.png) showing the setting we think we need to tick on [this similar issue](https://github.com/terraform-providers/terraform-provider-aws/issues/7373).

We would like to have some kind of smoke test after deploying to the first environment. This could be similar to what we have for the Connector (hitting a health check) or like what we have Provider UI (running an end-to-end test in the browser)

There is a git pre-commit linter hook script we can make use of [here](https://github.com/ministryofjustice/laa-git-pre-commit-lint), which lints several different file types before you commit a change.

In this pipeline, we only have 2 envrionments, and we run the pipeline on every branch. For a real application, we would have two workflows:
- `integration` runs only on branches, and should deploy an ephemeral environment to the `test` account
- `path-to-live` runs only on master, and should deploy to the `staging` account and then `production`

The main difference between the two is that `integration` uses a unique terraform workspace per branch so that we can test branches in parallel. It requires an approval step before destroying the terraform resources, because the infrastructure is temporary but may be needed for exploratory testing as long as the PR is open.

The minimal `path-to-live` workflow is to deploy to `staging` and then, if the smoke tests pass, to `production`. For an ideal app where we are confident in our automated tests, and we can deploy without downtime, this should be fully automated, so a developer simply needs to merge the PR and then monitor the `path-to-live` workflow in CircleCI.

There is no downtime to deploy the hello world application, as Terraform creates a new task definition when the image changes, Fargate waits until the tasks from this new definition are healthly and then directs the load balancer to these task instances.  The old task definition is marked as inactive and the task instances are drained and stopped.  This method relies on the application being stateless, so we would need to ensure the production application is as well if we want zero downtime deployments using this method, or investigate other methods such as blue green deployments.

We may or may not want to move the creation of the ECR resource to the shared [laa-aws-infrastructure](https://github.com/ministryofjustice/laa-aws-infrastructure) repository. Moving it out would mean that if we tear down the infrastracture we wouldn't lose previous builds. We should decide if we actually need to keep these or are happy to lose them.

## Other improvements
We had to create the dev and test workspaces by temporarily adding a job to our CircleCI config which ran some Terraform to create them, and then removing it after the workspace was created. We might want to create a script that we can run to create new workspaces if we need to.

When adding new infrastructure we had to run many CircleCI jobs instead of running the terraform directly, because we could not assume the role that let us run terraform from developer machines. This was very slow. We may want to consider letting developers assume the terraform role in the development account, so that we can test that terraform code works before checking it in.

There are also Git pre-commit hooks we can run, which is not actually part of the pipeline so we didn't include it here. Examples used elsewhere are the [laa-git-pre-commit-lint](https://github.com/ministryofjustice/laa-git-pre-commit-lint) hook and [git-secrets-ahoy](https://github.com/ministryofjustice/git-secrets-ahoy).