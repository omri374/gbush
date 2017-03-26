# gbush
Tracking system for a gibush

# Installing:
1. Run `mvn clean install` to build your application
2. Run the dropwizard backend from the gibush folder:
java -jar gbush-dw/target/gbush-dw-1.0-SNAPSHOT.jar server gbush-dw/config.ymlv

3. Run the angular jetty
mvn jetty:run