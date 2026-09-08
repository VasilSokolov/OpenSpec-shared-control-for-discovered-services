# Reactive WebFlux: Test Logging Migration

## Overview

In Spring Boot 4.0, file-based test logging (via `mobile-logback-spring-boot-starter` and a `test.log` file) is replaced with in-memory programmatic log appenders.

## What to Remove

Remove `mobile-logback-spring-boot-starter` from test dependencies:

```xml
<!-- REMOVE -->
<dependency>
    <groupId>de.mobile.spring.boot.starter</groupId>
    <artifactId>mobile-logback-spring-boot-starter</artifactId>
</dependency>
```

Also remove any `test.logdir` system property configuration.

## Before: File-Based Logging

```java
protected static BufferedReader logReader;

@BeforeEach
public void before() throws IOException {
    logReader = new BufferedReader(new FileReader(System.getProperty("test.logdir") + "/test.log"));
    // read until eof
    while (logReader.read() >= 0) {}
}

@SneakyThrows
public void assertWasLogged(String text) {
    String line = "";
    while (line != null) {
        if (line.contains(text)) {
            return;
        }
        line = logReader.readLine();
    }
    fail("log did not contain text: " + text);
}
```

## After: In-Memory TestLogAppender

Create a custom test log appender class:

```java
public class TestLogAppender extends AppenderBase<ILoggingEvent> {

    private static final List<ILoggingEvent> events = new ArrayList<>();

    @Override
    protected void append(ILoggingEvent eventObject) {
        events.add(eventObject);
    }

    public static List<ILoggingEvent> getEvents() {
        return new ArrayList<>(events);
    }

    public static void clear() {
        events.clear();
    }
}
```

Use it in your test base class:

```java
private TestLogAppender testLogAppender;

@BeforeEach
public void before() {
    testLogAppender = new TestLogAppender();
    testLogAppender.start();
    Logger rootLogger = (Logger) LoggerFactory.getLogger(Logger.ROOT_LOGGER_NAME);
    rootLogger.addAppender(testLogAppender);
    TestLogAppender.clear();
}

@AfterEach
public void after() {
    if (testLogAppender != null) {
        Logger rootLogger = (Logger) LoggerFactory.getLogger(Logger.ROOT_LOGGER_NAME);
        rootLogger.detachAppender(testLogAppender);
        testLogAppender.stop();
    }
    TestLogAppender.clear();
}

public void assertWasLogged(String text) {
    boolean found = TestLogAppender.getEvents().stream()
            .anyMatch(event -> event.getFormattedMessage().contains(text));
    if (!found) {
        fail("log did not contain text: " + text);
    }
}
```

## Benefits

- No file I/O (faster and more reliable tests)
- No `test.logdir` system property required
- No dependency on `mobile-logback-spring-boot-starter`
- Works consistently across all environments

## Troubleshooting

**Symptom**: Tests fail with `FileNotFoundException: test.log`

**Cause**: Tests rely on file-based logging which is no longer configured in Spring Boot 4.0.

**Resolution**: Implement the `TestLogAppender` pattern above and remove file-reading code from test base classes.
