pipeline {
    agent any

    environment {
        PROJECT_NAME = "Two-Tier-CI-CD-Jenkins--Demo"
    }

    stages {

        stage('Checkout Code') {
            steps {
                echo "Cloning repository..."
                checkout scm
            }
        }

        stage('Pre-Deployment Check') {
            steps {
                echo "Verifying scripts..."
                sh 'chmod +x scripts/*.sh'
                sh 'ls -l scripts'
            }
        }

        stage('Prepare Environment') {
            steps {
                echo "Preparing environment configuration..."
                sh '''
                if [ ! -f .env ]; then
                  echo "[INFO] .env not found, creating from .env.example"
                  cp .env.example .env
                else
                  echo "[INFO] .env already exists"
                fi
                '''
            }
        }

        stage('Shutdown Existing Application') {
            steps {
                echo "Stopping existing containers (if running)..."
                sh './scripts/shutdown.sh || true'
            }
        }

        stage('Deploy Application') {
            steps {
                echo "Starting application..."
                sh './scripts/start.sh'
            }
        }
    }

    post {
        success {
            echo "Deployment completed successfully"
        }
        failure {
            echo "Deployment failed"
        }
    }
}

