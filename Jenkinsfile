pipeline {
    agent any

    environment {
        MAVEN_HOME = '/usr/share/maven'  // Make sure this path is correct based on your environment
        JAVA_HOME = '/usr/lib/jvm/java-17-openjdk' // Update with your Java 17 path if necessary
        TOMCAT_WEBAPPS_DIR = '/usr/tomcat/cargo-tomcat/webapps' // Update this path if needed
        TARGET_DIR = '/var/lib/jenkins/workspace/maven-war-build/target/product' // Update the target directory where WAR file is built
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
                    // Check if the WAR file is located in the correct directory
                    def warFile = "${TARGET_DIR}/product.war"  // Update path based on the location of the WAR file
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

