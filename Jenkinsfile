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
                    // Run Maven build
                    sh "'${MAVEN_HOME}/bin/mvn' clean install"

                    // Debugging step: List files in the target directory
                    sh 'ls -l target/'
                }
            }
        }

        stage('Test') {
            steps {
                script {
                    // Run Maven tests
                    sh 'mvn test'
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    echo 'Deploying application...'
                    
                    // Check if the WAR file exists
                    def warFile = 'target/product.war'
                    if (fileExists(warFile)) {
                        // If the WAR file exists, deploy it
                        sh "cp ${warFile} /usr/tomcat/cargo-tomcat/webapps/"
                        echo 'Deployment complete!'
                    } else {
                        // If WAR file is not found, stop the pipeline and notify the error
                        error "WAR file not found: ${warFile}"
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()  // Clean workspace after the pipeline execution
        }
    }
}

