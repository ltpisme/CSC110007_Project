pipeline {
    agent any
    
    environment {
        REVISION = "1.0-SNAPSHOT"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                sh 'ls -F'
            }
        }

        stage('Build & Install') {
            steps {
                echo "Installing dependencies with revision ${REVISION}..."
                sh "mvn clean install -DskipTests -Drevision=${REVISION} -U"
            }
        }

        stage('Test Rating Service') {
            steps {
                echo 'Testing rating service...'
                sh "mvn test -pl rating -am -Drevision=${REVISION}"
            }
        }

        stage('Coverage Check') {
            steps {
                script {
                    echo 'Generating Jacoco Report...'
                    sh "mvn jacoco:report -pl rating -Drevision=${REVISION}"
                    
                    def coverageStr = sh(
                        script: "cat rating/target/site/jacoco/index.html | grep -o 'Total[^%]*%' | grep -oE '[0-9]+%' | tr -d '%' | head -n 1",
                        returnStdout: true
                    ).trim()

                    if (coverageStr == null || coverageStr == "") {
                        error "Không thể trích xuất chỉ số Coverage. Hãy kiểm tra file report."
                    }

                    int coverage = coverageStr.toInteger()
                    echo "Độ phủ code hiện tại là: ${coverage}%"

                    if (coverage < 70) {
                        error "FAILED: Độ phủ code (${coverage}%) dưới mức yêu cầu 70%!"
                    } else {
                        echo "SUCCESS: Độ phủ code đạt yêu cầu."
                    }
                }
            }
        }
    }

    post {
        always {
            junit testResults: '**/target/surefire-reports/*.xml', allowEmptyResults: true
        }
        success {
            echo "Pipeline hoàn thành xuất sắc với Coverage >= 70%."
        }
    }
}