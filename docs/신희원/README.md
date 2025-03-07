# 신희원 학습일지
## 03-04 깃랩 MM 연동
1. default branch(develop 변동시 MM 알림)
2. 테스트 용으로 docs push 후 MR 요청 해볼게요.

- MR 및 취소

![alt text](mrTest.png)
- MM 반응

![alt text](MMTest.png)

- 내일 할 일
    1. 깃랩 지라 연동
    2. 아이디어 기획획

## 03-05 싸피 금융망 API 학습
#### 싸피 금융망 사용 이유
1. 실제 은행사 API는 사용 비용이 있다.
2. 실제 은행의 데이터를 사용하면 개발 중 사용자 정보 유출 위험이 있다.
3. 복잡한 인증 절차를 걸치지 않고 실제 은행 서비스를 이용할 수 있다.(ID만 필요)
#### 싸피 금융망 적용 방식
- 금융앱에서 금융서비스를 사용하기 위해 금융인증서 발급 -> 우리 서비스에서 SSAFY 로그인을 통해 받은 userKey로 대체
- 싸피 금융망에서 얻은 마이데이터(자산), 우리 서비스의 회원 정보(직종, 예산, 나이) 데이터를 JOIN 후 예산 분배

#### 문제점
아직 SSAFY 금융망이 열리지 않아 실제 동작과정을 알 수 없다.

## 03-06 본인 인증 시스템 학습
### 휴대폰 본인 인증
#### 장점(식별성)
- 로그인 및 회원가입 과정에서 사용자의 신원을 명확히 함
- 사용자가 여러 개의 계정을 만드는 것을 방지, 서비스의 품질 향상
#### 단점
- 비용 : SMS를 통한 인증 과정은 비용이 발생. 특히, 서비스가 성장함에 따라 인증 요청이 늘어나면, 이 비용도 함께 증가

#### 해결책
실제로 구현하기<br>
https://obtuse.kr/dev/free-phone-verification/

## 03-07 SWAGGER
### 학습 계기
컨설턴트님의 강의를 통해 프로젝트에 적용하고자 학습함.
### 구현 과정
1. build.gradle 의존성 추가
2. 접속 url: localhost:8080/swagger-ui/index.html
3. SwaggerConfig 생성(JWT버전)
   ```java
   @Configuration
    public class SwaggerConfig {
    @Bean
    public OpenAPI openAPI() {
        String jwt = "JWT";
        SecurityRequirement securityRequirement = new SecurityRequirement().addList(jwt);
        Components components = new Components().addSecuritySchemes(jwt, new SecurityScheme()
                .name(jwt)
                .type(SecurityScheme.Type.HTTP)
                .scheme("bearer")
                .bearerFormat("JWT")
        );
        return new OpenAPI()
                .components(new Components())
                .info(apiInfo())
                .addSecurityItem(securityRequirement)
                .components(components);
    }
    private Info apiInfo() {
        return new Info()
                .title("API Test") // API의 제목
                .description("Let's practice Swagger UI") // API에 대한 설명
                .version("1.0.0"); // API의 버전
        }
    }
   ```
4. 관련 출처 <br>
https://velog.io/@gmlstjq123/SpringBoot-%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B8%EC%97%90-Swagger-UI-%EC%A0%81%EC%9A%A9%ED%95%98%EA%B8%B0

### 향후 계획
SWAGGER API를 통해 백엔드 및 프론트엔드의 테스트를 위한 매개체로 사용.   