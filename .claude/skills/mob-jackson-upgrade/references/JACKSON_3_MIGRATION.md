# Jackson 2 to Jackson 3 Migration Guide

Source: https://github.com/FasterXML/jackson/blob/main/jackson3/MIGRATING_TO_JACKSON_3.md

## Critical Requirements

**Java Version**: Jackson 3.x requires Java 17 minimum (up from Java 8 in 2.x).

**Target Version**: Jackson 3.0 is transitional; "Jackson 3.1 is your recommended target for long-term stability."

## Package and Dependency Changes

### Group ID Migration
Replace `com.fasterxml.jackson` with `tools.jackson` in Maven/Gradle dependencies.

**Exception**: `jackson-annotations` retains the original `com.fasterxml.jackson.annotation` group and package.

### Import Statement Updates
Change all imports from `com.fasterxml.jackson.*` to `tools.jackson.*`, except annotations.

**Example**:
```java
// Before
import com.fasterxml.jackson.databind.ObjectMapper;

// After
import tools.jackson.databind.ObjectMapper;
```

### Build Configuration
Use `jackson-bom` for version management to simplify dependency handling:

```xml
<dependency>
  <groupId>tools.jackson</groupId>
  <artifactId>jackson-bom</artifactId>
  <version>3.0.0</version>
</dependency>
```

## Major API Changes

### ObjectMapper and JsonFactory Immutability
Both are now immutable; configuration requires builders:

```java
// Before
ObjectMapper mapper = new ObjectMapper();
mapper.enable(SerializationFeature.INDENT_OUTPUT);

// After
JsonMapper mapper = JsonMapper.builder()
    .enable(SerializationFeature.INDENT_OUTPUT)
    .build();
```

### Format-Specific Mappers Mandatory
Generic factory pattern no longer permitted:

```java
// Before - NOT allowed in 3.x
new ObjectMapper(new YAMLFactory());

// After - Required
new YAMLMapper();
// or
new YAMLMapper(YAMLFactory.builder().build());
```

### Exception Hierarchy Changes
All Jackson exceptions now extend `RuntimeException` (unchecked):

- `JsonProcessingException` → `JacksonException`
- `JsonMappingException` → `DatabindException`
- `JsonParseException` → `StreamReadException`
- `JsonEOFException` → `UnexpectedEndOfInputException`

No `throws` declarations needed for Jackson operations.

## Key Class and Method Renamings

### Core Classes (jackson-core)
- `JsonFactory` → `TokenStreamFactory` (API) with implementation in `tools.jackson.core.json`
- `JsonStreamContext` → `TokenStreamContext`
- `JsonLocation` → `TokenStreamLocation`

### Data Binding Classes (jackson-databind)
- `JsonSerializer` → `ValueSerializer`
- `JsonDeserializer` → `ValueDeserializer`
- `JsonSerializable` → `JacksonSerializable`
- `Module` → `JacksonModule`
- `TextNode` → `StringNode`
- `SerializerProvider` → `SerializationContext`

### Feature Enums (Streaming APIs)
Consolidated and renamed per format:

- `JsonParser.Feature` → `StreamReadFeature` + `JsonReadFeature`
- `JsonGenerator.Feature` → `StreamWriteFeature` + `JsonWriteFeature`
- Similar splits for Avro, CBOR, CSV, Ion, Smile, XML, YAML

### Method Changes
**JsonParser/JsonGenerator**:
- `getCodec()` → `objectReadContext()` / `objectWriteContext()`
- `getText()` → `getString()`
- `getCurrentName()` → `currentName()`
- `writeObject()` → `writePOJO()`
- `FIELD_NAME` token → `PROPERTY_NAME`

## Configuration Changes

### New Default Behaviors (Breaking)

**DeserializationFeature.FAIL_ON_TRAILING_TOKENS**: Enabled by default (performance overhead). Disable if needed:

```java
JsonMapper mapper = JsonMapper.builder()
    .disable(DeserializationFeature.FAIL_ON_TRAILING_TOKENS)
    .build();
```

**SerializationFeature.WRITE_DATES_AS_TIMESTAMPS**: Disabled by default (previously enabled).

**EnumFeature changes**:
- `READ_ENUMS_USING_TO_STRING` now defaults to `true`
- `WRITE_ENUMS_USING_TO_STRING` now defaults to `true`

**MapperFeature removals**:
- `AUTO_DETECT_CREATORS` and related variants removed
- `SORT_PROPERTIES_ALPHABETICALLY` now enabled by default
- `USE_GETTERS_AS_SETTERS` disabled
- `ALLOW_FINAL_FIELDS_AS_MUTATORS` disabled

### Builder-Based Configuration Examples

**Date/Time configuration**:
```java
ObjectMapper mapper = JsonMapper.builder()
    .defaultDateFormat(new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ"))
    .defaultTimeZone(TimeZone.getDefault())
    .build();
```

**Serialization inclusion**:
```java
ObjectMapper mapper = JsonMapper.builder()
    .changeDefaultPropertyInclusion(incl -> 
        incl.withValueInclusion(JsonInclude.Include.NON_NULL))
    .build();
```

**Visibility configuration**:
```java
ObjectMapper mapper = JsonMapper.builder()
    .changeDefaultVisibility(vc ->
        vc.withFieldVisibility(JsonAutoDetect.Visibility.NONE))
    .build();
```

**Type information handling**:
```java
var typeValidator = BasicPolymorphicTypeValidator.builder()
    .allowIfSubType("my.package.base.name.")
    .build();

ObjectMapper mapper = JsonMapper.builder()
    .activateDefaultTypingAsProperty(typeValidator, 
        DefaultTyping.NON_CONCRETE_AND_ARRAYS, "@class")
    .build();
```

### Default Views (Jackson 3.1+)
```java
ObjectMapper mapper = JsonMapper.builder()
    .defaultSerializationView(Views.Public.class)
    .defaultDeserializationView(Views.Public.class)
    .build();
```

## Feature Removals

### Deprecated in 2.20, Removed in 3.0
- Format auto-detection functionality (DataFormatDetector classes)
- `ObjectMapper.canDeserialize()` / `canSerialize()`
- `ObjectMapper.copy()`—use `rebuild().build()` instead
- `MappingJsonFactory` class
- `ObjectCodec` interface (replaced by `ObjectReadContext` and `ObjectWriteContext`)

### Module Changes
- "Java 8 modules" now embedded in `jackson-databind`: remove separate `jackson-datatype-jdk8`, `jackson-datatype-jsr310`, `jackson-module-parameter-names` dependencies
- `jackson-module-jsonSchema` deprecated; no 3.x version available

## Performance Considerations

### Buffer Recycling
Jackson 3.x defaults to deque-based `RecyclerPool`. For 2.x-compatible performance, explicitly configure:

```java
JsonFactory factory = JsonFactory.builder()
    .recyclerPool(JsonRecyclerPools.threadLocalPool())
    .build();

JsonMapper mapper = JsonMapper.builder(factory).build();
```

## Migration Tools

OpenRewrite provides an automated migration recipe at: `org.openrewrite.java.jackson.upgradejackson_2_3`

## Additional Resources

- Full release notes: Jackson 3.0 Release Notes on GitHub
- JSTEP documents detail strategic decisions: jackson-future-ideas wiki
- Spring Framework Jackson 3 support available in recent versions
