"# centene" 
sumDev
Runtime Log results are under the /trigger

AWS Interview Project
The criteria is as follows:
- Build out the data pipeline presented in the diagram below in a personal AWS account.
o An free-tier option would suffice.
- It must be deployed out via Terraform IaC
- The Terraform and python code should be committed to a public GIT repo
o GitHub or comparable.
- Links to the GIT repo should be sent over before the afore mentioned date along with
screenshots of the AWS console with the deployed resources present and deployed.
o Some type of correlation that what was written in the Terraform code is what was
deployed to the console and not just created by hand up there.

- We will be looking for a few details in this implementation where the candidate will have the
opportunity to represent best practices of a Senior Data Engineer. We won’t got into the exact
details on what we are looking for so we don’t give it away but it should be fairly
straightforward in the context of “best practices” of an AWS project.
- In the coming panel interview, we will ask the candidate to do a technical walk through with the
team of the code they wrote and answer some questions we may have about their decisions.
Regarding the project to be build/deployed:
- Two different S3 buckets
o Source bucket - Where a file will be uploaded that you will read (triggerFile.txt).
o Destination bucket - Where you write the output file.
- A CloudWatch Event to monitor the source S3 bucket and trigger the Lambda function when a
file(object) is uploaded to it.
- A Lambda function that contains Python code that does the following:
o Read the contents of the dropped off file (object) in the source bucket:
 Header row
 Pipe delimited series of numbers
o Calculate the sum of all the numbers in the file&#39;s second row
o Create a new file in the destination bucket that writes the original file contents plus a
new row containing the sum.

- Essentially once deployed out, if you drop the file “triggerFile.txt” in the initial source bucket,
soon after it should show up in the destination bucket with the transformations done by the
Lambda function.
- Create a test file called “triggerFile.txt” with the following content to run against your project:
sbx|dev|tst|prd|srd
7101|3501|0862|4284|7437
