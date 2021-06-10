# hw-static-site
Example of creating and deploying a Static Website with S3 and Terraform on AWS.

## Prerequisites

* Install [Terraform](https://www.terraform.io/downloads.html)
* Ensure your account has a [Terraform State S3 Backend](https://github.com/byu-oit/terraform-aws-backend-s3) deployed.

## Setup
* Create a new repo [using this template](https://github.com/byu-oit/hw-static-site/generate).

  You need your own repo so that you can push changes and have GitHub Actions deploy them.
  
  Keep your repo name relatively short. Since we're creating AWS resources based off the name, we've seen [issues with repo names longer than about 24 characters](https://github.com/byu-oit/hello-world-api/issues/22).

* Clone your new repo
```
git clone https://github.com/byu-oit/my-new-repo
```
* Check out the `dev` branch 
```
cd my-new-repo
git checkout -b dev
```
* Find and replace across the repo:
  * replace `977306314792` with your dev AWS account number
  * replace `539738229445` with your prd AWS account number
  * replace `hw-static-site` with the name of your repo
  * replace `byu-oit-terraform-dev` with the name of your `dev` AWS account
  * replace `byu_oit_terraform_dev` with the name of your `dev` AWS account (with underscores)
  * replace `byu-oit-terraform-prd` with the name of your `prd` AWS account
  * replace `byu_oit_terraform_prd` with the name of your `prd` AWS account (with underscores)
* Commit/push your changes
```
git commit -am "update template with repo specific details" 
git push
```

## Deployment

### Deploy the "one time setup" resources

```
cd terraform-iac/dev/setup/
terraform init
terraform apply
```

The output from this will give you the NS records for your new Hosted Zone. These NS records need to be entered into the DNS system of record for the parent domain.

For example, if your site's URL was `mysite-dev.byu.edu`, you would need to add the following records to QIP (as QIP is the DNS system of record for `byu.edu`):

```
mysite-dev.byu.edu NS ns-1486.awsdns-57.org
mysite-dev.byu.edu NS ns-1853.awsdns-39.co.uk
mysite-dev.byu.edu NS ns-829.awsdns-39.net
mysite-dev.byu.edu NS ns-91.awsdns-11.com
```

(You'll need to change the actual values based on the output from `terraform apply`)

As another example, if your site's URL was `mysite-dev.mydepartment.byu.edu`, and `mydepartment.byu.edu` was already controlled by a Route 53 Hosted Zone, you would manually add the NS records to the Hosted Zone for `mydepartment.byu.edu`.

In the AWS Console, see if you can find the resources from `setup.tf` (Route 53 Hosted Zone).

### Enable GitHub Actions on your repo

* Use this [order form](https://it.byu.edu/it?id=sc_cat_item&sys_id=d20809201b2d141069fbbaecdc4bcb84) to give your repo access to the secrets that will let it deploy into your AWS accounts. Fill out the form twice to give access to both your `dev` and `prd` accounts.
* In GitHub, go to the `Actions` tab for your repo (e.g. https://github.com/byu-oit/my-repo/actions)
* Click the `Enable Actions on this repo` button

If you look at `.github/workflows/deploy.yml`, you'll see that it is setup to run on pushes to the dev branch. Because you have already pushed to the dev branch, this workflow should be running now.

* In GitHub, click on the workflow run (it has the same name as the last commit message you pushed)
* Click on the `Build and deploy Webapp to S3` job
* Expand any of the steps to see what they are doing

### View the deployed application

Anytime after the `Terraform Apply` step succeeds   :
```
cd ../app/
terraform init
terraform output
```

This will output a DNS Name. Enter this in a browser. It will probably return an error. This is because your content hasn't been uploaded yet, or the CloudFront distribution hasn't been updated.

Wait for the `Invalidate CloudFront cache` step to succeed, then try again.

In the AWS Console, see if you can find the other resources from `main.tf` (S3 Bucket, CloudFront Distribution).

### Push a change to your application

Make a small change to `index.html`. Commit and push this change to the `dev` branch.

```
git commit -am "try deploying a change"
git push
```

In GitHub Actions, watch the deploy steps run (you have a new push, so you'll have to go back and select the new workflow run instance and the job again). Once the `Invalidate CloudFront cache` step succeeds, hit your application in the browser and see if your change worked. If you aren't seeing the change, you may need to invalidate your browser cache as well.

> Note: 
>
> It's always best to test your changes locally before pushing to GitHub and AWS. Testing locally will significantly increase your productivity as you won't be constantly waiting for GitHub Actions and CodeDeploy to deploy, just to discover bugs.
>
> You can either test locally inside Docker, or by pointing your browser directly at your local files.

## Learn what was built

By digging through the `.tf` files, you'll see what resources are being created. You should spend some time searching through the AWS Console for each of these resources. The goal is to start making connections between the Terraform syntax and the actual AWS resources that are created.

Several OIT created Terraform modules are used. You can look these modules up in our GitHub Organization. There you can see what resources each of these modules creates. You can look those up in the AWS Console too.

### Related Modules

* [Terraform AWS Domain Redirect](https://github.com/byu-oit/terraform-aws-domain-redirect)