pipeline {
    agent any

    environment {
        MAVEN_HOME = '/usr/share/maven'  // Ensure this path is correct based on your environment
        JAVA_HOME = '/usr/lib/jvm/java-17-openjdk' // Update with your Java 17 path if necessary
        TOMCAT_WEBAPPS_DIR = '/usr/tomcat/cargo-tomcat/webapps' // The correct Tomcat directory
        WAR_FILE = '/usr/tomcat/cargo-tomcat/webapps/product.war' // The expected WAR file location
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout code from GitHub repository
                checkout scm
            }
        }

        stage('Build') {
            steps {
                script {
                    // Run Maven build to clean, compile, and package the WAR file
                    sh "'${MAVEN_HOME}/bin/mvn' clean install -DskipTests"
                }
            }
        }

        stage('Test') {
            steps {
                script {
                    // Run tests (if any)
                    sh "'${MAVEN_HOME}/bin/mvn' test"
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    echo "Checking for WAR file at ${WAR_FILE}"
                    
                    // Check if WAR file exists
                    if (fileExists(WAR_FILE)) {
                        echo "WAR file is already deployed at ${WAR_FILE}"
                        // Optionally, restart Tomcat or perform any other action
                        // Example: sh 'service tomcat restart'
                    } else {
                        error "WAR file was not found at ${WAR_FILE}. Deployment failed."
                    }
                }
            }
        }
    }

    post {
        always {
            // Clean up workspace after the build
            cleanWs()
        }

        success {
            // Add any post-build success steps here
            echo 'Build and deployment completed successfully!'
        }

        failure {
            // Handle build failure (you could send notifications, etc.)
            echo 'Build or deployment failed!'
        }
    }
}

