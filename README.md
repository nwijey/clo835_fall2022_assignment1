[![Deploy to ECR](https://github.com/nwijey/clo835_fall2022_assignment1/actions/workflows/push_to_ecr.yml/badge.svg)](https://github.com/nwijey/clo835_fall2022_assignment1/actions/workflows/push_to_ecr.yml)

Prerequisites -
1. Github - Fork this repository 
2. Cloud9 - Clone the remote repo to local 
3. CD to terraform directory - cd terraform_code/dev/instances/ 
4. Key - Generate SSH key with name Assign1-dev in the above directory
5. Secret Keys - Update the  repository secrets: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN

Deployment - 
1. CD to terraform directory - cd terraform_code/dev/instances/ 
2. Deploy the terraform code - terraform init, terraform validate, terraform plan and terraform apply
3. Push Image to ECR - Perform a git push of the code to a remote branch and create a pull request to master. This will initiate the image build process and push the images to the ECR repository.
4. Connect to EC2 - SSH into the EC2 instance
5. Login to ECR - Generate the push commands to login to the ECR repository and run it on the EC2 instance
6. Pull images - run the docker pull commands to fetch the latest images of the app and sqldb (docker pull <ecr repository>
7. Create a custom network - docker network create  -d bridge --subnet 182.18.0.1/24 --gateway  182.18.0.1 custom-bridgenet
8. Run the sqldb container - docker run --network custom-bridgenet -d --name mysql -e MYSQL_ROOT_PASSWORD=db_pass123 <ecr repository>
9. Export the database environment variables -
export DBHOST=182.18.0.2
export DBPORT=3306
export DBUSER=root
export DATABASE=employees
export DBPWD=db_pass123
10. Run the application containers -
  Blue - docker run -d --network custom-bridgenet --name blue-app -p 8081:8080 -e DBHOST=$DBHOST -e DBPORT=$DBPORT -e DBUSER=$DBUSER -e DBPWD=$DBPWD -e APP_COLOR=blue <ecr repo>
  Pink - docker run -d --network custom-bridgenet --name pink-app -p 8082:8080 -e DBHOST=$DBHOST -e DBPORT=$DBPORT -e DBUSER=$DBUSER -e DBPWD=$DBPWD -e APP_COLOR=pink <ecr repo>
  Lime - docker run -d --network custom-bridgenet --name lime-app -p 8083:8080 -e DBHOST=$DBHOST -e DBPORT=$DBPORT -e DBUSER=$DBUSER -e DBPWD=$DBPWD -e APP_COLOR=lime <ecr repo>
 11. Connect to an app - docker exec -it blue-app /bin/sh  
 12. Install ping - apt install iputils-ping -y
 13. Ping an app - ping pink-app
