FROM openjdk:21-slim

RUN apt-get update && \
    apt-get install -y python3.9 python3.9-distutils python3.9-venv curl && \
    curl -sS https://bootstrap.pypa.io/get-pip.py | python3.9 && \
    ln -sf /usr/bin/python3.9 /usr/bin/python && \
    rm -rf /var/lib/apt/lists/*

ARG JAR_FILE=build/libs/*.jar
COPY ${JAR_FILE} app.jar

ENTRYPOINT ["java", "-jar", "/app.jar"]
