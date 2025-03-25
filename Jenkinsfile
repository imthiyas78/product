pipeline {
    agent any

    environment {
        MAVEN_HOME = '/usr/share/maven'  // Path to Maven installation
        JAVA_HOME = '/usr/lib/jvm/java-17-openjdk'  // Path to OpenJDK 17
        PATH = "${JAVA_HOME}/bin:${MAVEN_HOME}/bin:${env.PATH}"  // Update PATH with JAVA_HOME and MAVEN_HOME
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/imthiyas78/product.git', branch: 'master'
            }
        }

        stage('Build') {
            steps {
                script {
                    sh 'mvn clean install'  // Run Maven build command
                }
            }
        }

        stage('Test') {
            steps {
                script {
                    sh 'mvn test'  // Run Maven tests
                }
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying application...'
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}

