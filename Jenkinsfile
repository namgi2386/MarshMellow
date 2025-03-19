pipeline {
    agent any
    environment {
        // Docker Hub 사용자명과 이미지명 (실제 값으로 수정)
        IMAGE_NAME = "yunjaeeun12/gbh-cert"
        // Docker Hub와 GitLab의 Jenkins Credentials ID
        DOCKERHUB_CREDENTIALS = 'dockerhub-credentials-id'
        GITLAB_CREDENTIALS = 'gitlab-credentials-id'
    }
    stages {
        stage('Checkout') {
            steps {
                // GitLab 레포지토리에서 소스코드 체크아웃 (인증 필요)
                git branch: 'master', url: 'https://lab.ssafy.com/s12-fintech-finance-sub1/S12P21C108.git', credentialsId: "${env.GITLAB_CREDENTIALS}"
            }
        }
        stage('Prepare Application Config') {
            steps {
                withCredentials([string(credentialsId: 'cert-config', variable: 'APP_CONFIG')]) {
                    script {
                        // 필요한 폴더 생성
                        sh 'mkdir -p gbh_cert/src/main/resources'
                        // Jenkins Credential에 저장된 내용을 application.yml 파일로 작성
                        writeFile file: 'gbh_cert/src/main/resources/application.yml', text: "${APP_CONFIG}"
                    }
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
                    sh "docker run -d --name gbh_cert -p 9000:9000 ${IMAGE_NAME}:${env.BUILD_NUMBER}"
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
