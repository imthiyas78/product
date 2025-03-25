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
                    sh 'mvn clean install -DskipTests=true'  // Run Maven build command, skipping tests to speed up build
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
                script {
                    echo 'Deploying application...'

                    // Copy the WAR file to Tomcat's webapps directory
                    // Make sure that Jenkins has permission to write to the directory
                    sh 'cp target/product.war /usr/tomcat/cargo-tomcat/webapps/'

                    // Optionally, restart Tomcat (if required)
                    // Ensure Jenkins has necessary permissions to restart Tomcat
                    // If sudo permissions are needed, consider setting up passwordless sudo for Jenkins user.
                    sh 'sudo systemctl restart tomcat'

                    echo 'Deployment complete!'
                }
            }
        }
    }

    post {
        always {
            // Clean workspace after job is finished
            cleanWs()
        }
    }
}

