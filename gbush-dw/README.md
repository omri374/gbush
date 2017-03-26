# gbush

How to start the gbush application
---

1. Run `mvn clean install` to build your application
1. Start application with:
java -jar gbush-dw/target/gbush-1.0-SNAPSHOT.jar server gbush-dw/config.yml
1. To check that your application is running enter url `http://localhost:8080`

Health Check
---

To see your applications health enter url `http://localhost:8081/healthcheck`
