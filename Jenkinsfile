pipeline {
    agent any
    // GitLab Webhook 트리거 설정 추가
    triggers {
        // push 이벤트가 발생하면 빌드를 시작합니다.
        gitlab(
            triggerOnPush: true, 
            branshFilterType: 'NameRegex',
            branchFilterValue: '^master$')
    }
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
                // 'cert_config_file'이라는 ID로 파일 Credential을 등록해두었음을 전제로 함.
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
                        // Dockerfile은 gbh_cert 디렉토리 내에 있으므로 현재 디렉토리(.)를 빌드 컨텍스트로 사용
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
