pipeline {
    agent any

    environment {
        MAVEN_HOME = '/usr/share/maven'  // Ensure this path is correct based on your environment
        JAVA_HOME = '/usr/lib/jvm/java-17-openjdk'
        WAR_TARGET_DIR = 'target'  // Default Maven output directory
        WAR_DEST_DIR = '/home/ec2-user/war'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                script {
                    sh "'${MAVEN_HOME}/bin/mvn' clean install -DskipTests"
                }
            }
        }

        stage('Test') {
            steps {
                script {
                    sh "'${MAVEN_HOME}/bin/mvn' test"
                }
            }
        }

        stage('Copy WAR') {
            steps {
                script {
                    // Create destination directory if it doesn't exist
                    sh "mkdir -p ${WAR_DEST_DIR}"

                    // Find and copy WAR file
                    def warFile = sh(script: "ls ${WAR_TARGET_DIR}/*.war", returnStdout: true).trim()
                    sh "cp ${warFile} ${WAR_DEST_DIR}/"
                    echo "WAR file copied to ${WAR_DEST_DIR}"
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }

        success {
            echo 'Build completed successfully and WAR file stored!'
        }

        failure {
            echo 'Build failed!'
        }
    }
}

