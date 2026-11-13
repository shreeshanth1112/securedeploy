pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        timeout(time: 30, unit: 'MINUTES')
    }

    environment {
        PATH = "${env.HOME}/.local/bin:${env.PATH}"
        IMAGE_NAME = 'localhost/securedeploy'
        TRIVY_NO_PROGRESS = 'true'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    env.GIT_SHORT = sh(returnStdout: true, script: 'git rev-parse --short=7 HEAD').trim()
                }
                echo "Building commit ${env.GIT_SHORT}"
            }
        }

        stage('Install dependencies') {
            steps {
                sh '''
                    python3 -m venv .venv-ci
                    .venv-ci/bin/pip install --quiet -r requirements-dev.txt
                '''
            }
        }

        stage('Unit tests') {
            steps {
                sh '.venv-ci/bin/pytest -v'
            }
        }

        stage('Bandit scan') {
            steps {
                sh '.venv-ci/bin/bandit -r app run.py'
            }
        }

        stage('Dependency audit') {
            steps {
                sh '.venv-ci/bin/pip-audit -r requirements.txt'
            }
        }

        stage('Secret scan') {
            steps {
                sh 'gitleaks git --redact -v .'
            }
        }

        stage('Build image') {
            steps {
                sh 'podman build -t "$IMAGE_NAME:$GIT_SHORT" .'
            }
        }

        stage('Trivy scan') {
            steps {
                sh '''
                    rm -f trivy-image.tar
                    podman save -o trivy-image.tar "$IMAGE_NAME:$GIT_SHORT"
                    trivy image --input trivy-image.tar --scanners vuln -o trivy-report.txt
                    trivy image --input trivy-image.tar --scanners vuln --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1
                '''
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'trivy-report.txt', allowEmptyArchive: true
            sh 'rm -f trivy-image.tar'
        }
        success {
            echo "Pipeline passed for ${env.GIT_SHORT}"
        }
        failure {
            echo 'Pipeline failed - read the first red stage.'
        }
    }
}
