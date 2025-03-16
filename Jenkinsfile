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
        stage('Build Spring Boot App') {
            steps {
                dir('spring-boot-app') {
                    // Gradle Wrapper를 사용하여 빌드 (테스트는 필요 시 옵션 수정)
                    sh './gradlew clean build -x test'
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                dir('spring-boot-app') {
                    // Dockerfile을 이용해 Docker 이미지를 생성, 빌드 번호를 태그로 활용
                    sh "docker build -t ${IMAGE_NAME}:${env.BUILD_NUMBER} ."
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                // Docker Hub Credentials를 사용해 로그인 후 이미지 push
                withCredentials([usernamePassword(credentialsId: env.DOCKERHUB_CREDENTIALS,
                                                  passwordVariable: 'DOCKERHUB_PASS',
                                                  usernameVariable: 'DOCKERHUB_USER')]) {
                    sh "echo $DOCKERHUB_PASS | docker login -u $DOCKERHUB_USER --password-stdin"
                    sh "docker push ${IMAGE_NAME}:${env.BUILD_NUMBER}"
                }
            }
        }
        stage('Deploy') {
            steps {
                // Docker Hub에서 해당 이미지 pull
                sh "docker pull ${IMAGE_NAME}:${env.BUILD_NUMBER}"
                // 기존 실행 중인 컨테이너 정리 (있을 경우)
                sh "docker stop spring-boot-app || true && docker rm spring-boot-app || true"
                // 새 컨테이너 실행 (포트 8080 사용 예)
                sh "docker run -d --name spring-boot-app -p 9000:9000 ${IMAGE_NAME}:${env.BUILD_NUMBER}"
            }
        }
    }
    post {
        failure {
            echo 'CI/CD 파이프라인 실행 중 문제가 발생했습니다.'
        }
    }
}
