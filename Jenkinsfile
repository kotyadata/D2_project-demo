pipeline {
    agent any
    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        TF_VERSION = '1.9.8'
        TF_HOME = '/usr/local/bin'
        PATH = "$TF_HOME:$PATH"
    }
    stages {
        stage('Checkout Code') {
            steps {
                echo 'Cloning repository...'
                git branch: 'main', url: 'https://github.com/kotyadata/D2_project-demo/new/main'
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve tfplan'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                echo "Building Docker image for webapp..."
                docker build -t webapp:latest .
                '''
            }
        }

        stage('Run Docker Container') {
            steps {
                sh '''
                echo "Stopping old container if running..."
                docker stop webapp || true
                docker rm webapp || true

                echo "Starting new container..."
                docker run -d --name webapp -p 3000:3000 webapp:latest
                '''
            }
        }
    }

    post {
        always {
            echo 'Cleaning up workspace...'
            cleanWs()
        }
    }
}
