# AWS-HELE
A temporary repo for example web-app.



# Task Description 

We'd like you to create a solution using Terraform that sets up a simple web app on Amazon EC2. The web app itself doesn't matter: Node, and PHP, it doesn't matter as long as it exposes a web interface. 
Make sure the site is load balanced using an ELB and connects to an RDS instance that's not publicly reachable. 

Please use EFS for shared storage between the two nodes. Add at least a CloudWatch alarm that triggers when the total number of requests exceeds X. 

## Bonus Points 

The following is optional and will get you bonus points: 

·       setup autoscaling 

·       do the above in ECS 
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

What I have done:

1. Created AWS Account
2. Created IAM user
3. Connected AWS with VSCode via AWS Toolkit extention
4. Wrote as much Terraform code as I could.

Expectation - Should have a web app that is exposed to the web, using ELB load balancer, connected with RDS data base, which is not public. To has auto scaling and CloudWatch alarm which trigers when total number of request exceeds X.

Results - I have created all the mentioned resources via Terraform. Created a simple BASH script/app in order to expose it to the internet. Succesfuly created Auto Scaling.

Problems - Could not expose the app. 
