pipeline {
    agent any

    environment {
        MAVEN_HOME = '/usr/share/maven'  // Path to Maven installation
        PATH = "${MAVEN_HOME}/bin:${env.PATH}"  // Add Maven to PATH
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout code from GitHub repository
                git url: 'https://github.com/imthiyas78/product.git', branch: 'master'  // Ensure the correct branch name
            }
        }

        stage('Build') {
            steps {
                // Run Maven build command
                script {
                    sh 'mvn clean install'  // This will compile and package your project
                }
            }
        }

        stage('Test') {
            steps {
                // Run Maven tests
                script {
                    sh 'mvn test'  // Run tests defined in the project
                }
            }
        }

        stage('Deploy') {
            steps {
                // Example deployment step
                echo 'Deploying application...'
                // Add your deployment logic here, for example:
                // sh './deploy.sh'  // If you have a script for deployment
            }
        }
    }

    post {
        always {
            // Cleanup workspace after build (this will run regardless of success or failure)
            cleanWs()
        }
    }
}

