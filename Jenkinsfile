pipeline {
    agent any

    environment {
        MAVEN_HOME = '/usr/share/maven'  // Ensure this path is correct based on your environment
        JAVA_HOME = '/usr/lib/jvm/java-17-openjdk' // Update with your Java 17 path if necessary
        TOMCAT_WEBAPPS_DIR = '/usr/tomcat/cargo-tomcat/webapps' // The correct Tomcat directory
        TARGET_DIR = '/var/lib/jenkins/workspace/maven-war-build/target/product' // Directory where WAR file is expected
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
                    // Correct WAR file path in Tomcat's webapps directory
                    def warFile = '/usr/tomcat/cargo-tomcat/webapps/product.war'  // Correct path based on build logs
                    echo "Checking for WAR file at ${warFile}"

                    // Ensure the WAR file exists before deploying
                    if (fileExists(warFile)) {
                        echo "Deploying WAR file to Tomcat"
                        // Copy the WAR file to Tomcat's webapps directory
                        sh "cp ${warFile} ${TOMCAT_WEBAPPS_DIR}/"
                    } else {
                        error "WAR file was not found at ${warFile}! Build failed."
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

