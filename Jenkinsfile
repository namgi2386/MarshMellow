import com.dabsquared.gitlabjenkins.trigger.filter.BranchFilterType

pipeline {
    agent any
    triggers {
        gitlab(
            triggerOnPush: true,
            branchFilterType: BranchFilterType.NameExact,
            branchFilterName: 'master',
            triggerOnMergeRequest: false
        )
    }
    environment {
        IMAGE_NAME = "yunjaeeun12/gbh-cert"
        DOCKERHUB_CREDENTIALS = 'dockerhub-credentials-id'
        GITLAB_CREDENTIALS = 'gitlab-credentials-id'
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://lab.ssafy.com/s12-fintech-finance-sub1/S12P21C108.git', credentialsId: "${env.GITLAB_CREDENTIALS}"
            }
        }
        stage('Prepare Application Config') {
            steps {
                withCredentials([file(credentialsId: 'cert_config_file', variable: 'APP_CONFIG_FILE')]) {
                    sh 'mkdir -p gbh_cert/src/main/resources'
                    sh 'cp $APP_CONFIG_FILE gbh_cert/src/main/resources/application.yml'
                }
            }
        }
        stage('Build Spring Boot App') {
            steps {
                dir('gbh_cert') {
                    sh 'chmod +x gradlew'
                    sh './gradlew clean build -x test'
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                dir('gbh_cert') {
                    withEnv(["PATH=/usr/local/bin:$PATH"]) {
                        sh "docker build -t ${IMAGE_NAME}:${env.BUILD_NUMBER} ."
                    }
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: env.DOCKERHUB_CREDENTIALS,
                                                    passwordVariable: 'DOCKERHUB_PASS',
                                                    usernameVariable: 'DOCKERHUB_USER')]) {
                    withEnv(["PATH=/usr/local/bin:$PATH"]) {
                        sh """
                            echo "$DOCKERHUB_PASS" | docker login -u "$DOCKERHUB_USER" --password-stdin
                            docker push ${IMAGE_NAME}:${env.BUILD_NUMBER}
                        """
                    }
                }
            }
        }
        stage('Deploy') {
            steps {
                withEnv(["PATH=/usr/local/bin:$PATH"]) {
                    sh "docker pull ${IMAGE_NAME}:${env.BUILD_NUMBER}"
                    sh "docker stop gbh_cert || true && docker rm gbh_cert || true"
                    sh "docker run -d --name gbh_cert -p 9001:9001 ${IMAGE_NAME}:${env.BUILD_NUMBER}"
                }
            }
        }
    }
    post {
        failure {
            echo 'CI/CD 파이프라인 실행 중 문제가 발생했습니다.'
        }
    }
}
