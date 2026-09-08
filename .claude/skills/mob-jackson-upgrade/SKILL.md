---
name: mob-jackson-upgrade
description: Migrate Jackson library code from version 2 to version 3
disable-model-invocation: true
---

You are a Jackson v3 migration expert helping users migrate their codebase from Jackson 2.x to Jackson 3.x.

## Core Responsibilities

When invoked, you should:

1. **Analyze the current Jackson usage**:
   - Search for Jackson imports (`com.fasterxml.jackson.*`)
   - Find Jackson dependencies in `pom.xml` or `build.gradle`
   - Identify ObjectMapper instantiation and configuration patterns
   - Check for custom serializers/deserializers
   - Look for format-specific mappers (YAML, XML, CSV, etc.)
   - Find exception handling code for Jackson exceptions

2. **Consult the migration guide**: Read the comprehensive migration guide at [JACKSON_3_MIGRATION.md](references/JACKSON_3_MIGRATION.md) to understand:
   - Java 17 requirement
   - Package name changes (`com.fasterxml.jackson` → `tools.jackson`)
   - Group ID changes in dependencies
   - Class renamings and API changes
   - Builder-based configuration patterns
   - Breaking changes in default behaviors

3. **Create a migration plan**:
   - Dependency updates (group IDs, versions)
   - Import statement replacements
   - ObjectMapper instantiation changes (builder pattern)
   - Class and method renamings
   - Exception handling updates
   - Configuration changes
   - Module dependency cleanup (Java 8 modules now embedded)

4. **Execute the migration systematically**:
   - Update dependencies in build files
   - Replace import statements across codebase
   - Convert ObjectMapper configuration to builder pattern
   - Update custom serializers/deserializers
   - Replace deprecated/removed methods
   - Update exception handling code
   - Remove obsolete module dependencies

5. **Validate the migration**:
   - Verify code compiles
   - Run tests to catch behavioral changes
   - Check for runtime issues
   - Verify serialization/deserialization still works correctly

## Approach

### Phase 1: Discovery
1. Find all Java files with Jackson imports:
   ```bash
   grep -r "import com.fasterxml.jackson" --include="*.java" .
   ```
2. Identify Jackson version and dependencies in build files:
   ```bash
   grep -A 2 "jackson" pom.xml
   # or for Gradle
   grep "jackson" build.gradle
   ```
3. Find ObjectMapper instantiation and configuration:
   ```bash
   grep -r "new ObjectMapper\|ObjectMapper mapper" --include="*.java" .
   ```
4. Find custom serializers/deserializers:
   ```bash
   grep -r "extends JsonSerializer\|extends JsonDeserializer" --include="*.java" .
   ```
5. Find Jackson configuration properties in application properties files:
   ```bash
   grep -r "spring.jackson.serialization" --include="*.properties" .
   ```
6. Find Jackson configuration properties in application YAML files:
   ```bash
   grep -r "spring.jackson.serialization" --include="*.yml" .
   ```

### Phase 2: Planning
1. List all files that need import changes
2. Identify ObjectMapper configurations requiring builder conversion
3. Note custom serializers/deserializers needing updates
4. Document any usage of removed/deprecated APIs
5. Check for Java version compatibility (requires Java 17+)

### Phase 3: Execution

#### Step 1: Update Dependencies
Update `pom.xml` or `build.gradle`:

**Maven (pom.xml)**:
```xml
<!-- Add BOM for version management -->
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>tools.jackson</groupId>
            <artifactId>jackson-bom</artifactId>
            <version>3.1.0</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>

<!-- Update dependencies -->
<dependencies>
    <dependency>
        <groupId>tools.jackson.core</groupId>
        <artifactId>jackson-databind</artifactId>
    </dependency>
    <dependency>
        <groupId>tools.jackson.core</groupId>
        <artifactId>jackson-core</artifactId>
    </dependency>
    <!-- Annotations keep old group ID -->
    <dependency>
        <groupId>com.fasterxml.jackson.core</groupId>
        <artifactId>jackson-annotations</artifactId>
    </dependency>
</dependencies>
```

**Remove these (now embedded in jackson-databind)**:
- `jackson-datatype-jdk8`
- `jackson-datatype-jsr310`
- `jackson-module-parameter-names`

#### Step 2: Update Import Statements
Replace all imports (except annotations):
```java
// Before
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.core.JsonParser;

// After
import tools.jackson.databind.ObjectMapper;
import tools.jackson.core.JsonParser;

// Annotations stay the same
import com.fasterxml.jackson.annotation.JsonProperty; // No change
```

Use find-and-replace or sed for bulk updates:
```bash
find . -name "*.java" -type f -exec sed -i '' 's/import com\.fasterxml\.jackson\.databind/import tools.jackson.databind/g' {} +
find . -name "*.java" -type f -exec sed -i '' 's/import com\.fasterxml\.jackson\.core/import tools.jackson.core/g' {} +
```

#### Step 3: Convert ObjectMapper to Builder Pattern
```java
// Before
ObjectMapper mapper = new ObjectMapper();
mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
mapper.setSerializationInclusion(JsonInclude.Include.NON_NULL);
mapper.enable(SerializationFeature.INDENT_OUTPUT);

// After
ObjectMapper mapper = JsonMapper.builder()
    .disable(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES)
    .changeDefaultPropertyInclusion(incl -> 
        incl.withValueInclusion(JsonInclude.Include.NON_NULL))
    .enable(SerializationFeature.INDENT_OUTPUT)
    .build();
```

#### Step 4: Update Format-Specific Mappers
```java
// Before
ObjectMapper yamlMapper = new ObjectMapper(new YAMLFactory());

// After
YAMLMapper yamlMapper = new YAMLMapper();
// or with configuration
YAMLMapper yamlMapper = YAMLMapper.builder()
    .enable(YAMLGenerator.Feature.MINIMIZE_QUOTES)
    .build();
```

#### Step 5: Update Class Names
Replace renamed classes throughout codebase:
- `JsonSerializer` → `ValueSerializer`
- `JsonDeserializer` → `ValueDeserializer`
- `JsonSerializable` → `JacksonSerializable`
- `Module` → `JacksonModule`
- `TextNode` → `StringNode`

#### Step 6: Update Method Calls
Replace deprecated/renamed methods:
- `getText()` → `getString()`
- `getCurrentName()` → `currentName()`
- `writeObject()` → `writePOJO()`
- `getCodec()` → `objectReadContext()` / `objectWriteContext()`

#### Step 7: Update Exception Handling
All Jackson exceptions are now unchecked (RuntimeException):
```java
// Before
try {
    return objectMapper.readValue(json, MyClass.class);
} catch (JsonProcessingException e) {
    // handle
}

// After - can still catch, but no throws declaration needed
try {
    return objectMapper.readValue(json, MyClass.class);
} catch (JacksonException e) {  // Note: JacksonException, not JsonProcessingException
    // handle
}
```

### Phase 4: Validation
Run these commands to validate:

```bash
# Verify no old imports remain
grep -r "import com.fasterxml.jackson" --include="*.java" . | grep -v "annotation"

# Compile the code
mvn clean compile
# or
gradle clean build

# Run tests
mvn test
# or
gradle test

# Check for specific patterns that might indicate issues
grep -r "new ObjectMapper()" --include="*.java" .
grep -r "JsonSerializer<" --include="*.java" .
grep -r "JsonDeserializer<" --include="*.java" .
```

## Critical Decision Points

### Java Version Check
Jackson 3 requires Java 17+. Verify before starting:
```bash
cat .java-version
# or check pom.xml
grep -A 1 "<java.version>" pom.xml
```

If Java version is below 17, the migration must include a Java upgrade.

### Format-Specific Mapper Detection
Identify which format mappers are in use:
- **JSON**: Use `JsonMapper` (standard)
- **YAML**: Use `YAMLMapper` from `jackson-dataformat-yaml`
- **XML**: Use `XmlMapper` from `jackson-dataformat-xml`
- **CSV**: Use `CsvMapper` from `jackson-dataformat-csv`
- **Others**: Check for Avro, CBOR, Ion, Smile, Properties formats

### Custom Serializers/Deserializers
These require special attention:
```java
// Before
public class MySerializer extends JsonSerializer<MyClass> {
    @Override
    public void serialize(MyClass value, JsonGenerator gen, SerializerProvider serializers) {
        // ...
    }
}

// After
public class MySerializer extends ValueSerializer<MyClass> {
    @Override
    public void serialize(MyClass value, JsonGenerator gen, SerializationContext ctxt) {
        // Note: SerializerProvider → SerializationContext
        // ...
    }
}
```

### Module Registration
```java
// Before
ObjectMapper mapper = new ObjectMapper();
mapper.registerModule(new MyModule());

// After
ObjectMapper mapper = JsonMapper.builder()
    .addModule(new MyJacksonModule())  // Note: Module → JacksonModule
    .build();
```

## Common Migration Patterns

### Pattern 1: Simple ObjectMapper with Configuration
**Before**:
```java
ObjectMapper mapper = new ObjectMapper();
mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
mapper.configure(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS, false);
```

**After**:
```java
ObjectMapper mapper = JsonMapper.builder()
    .disable(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES)
    .disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS)
    .build();
```

### Pattern 2: ObjectMapper with Date Formatting
**Before**:
```java
ObjectMapper mapper = new ObjectMapper();
mapper.setDateFormat(new SimpleDateFormat("yyyy-MM-dd"));
mapper.setTimeZone(TimeZone.getTimeZone("UTC"));
```

**After**:
```java
ObjectMapper mapper = JsonMapper.builder()
    .defaultDateFormat(new SimpleDateFormat("yyyy-MM-dd"))
    .defaultTimeZone(TimeZone.getTimeZone("UTC"))
    .build();
```

### Pattern 3: ObjectMapper with Custom Modules
**Before**:
```java
ObjectMapper mapper = new ObjectMapper();
mapper.registerModule(new JavaTimeModule());
mapper.registerModule(new MyCustomModule());
```

**After**:
```java
// Note: JavaTimeModule no longer needed (built-in)
ObjectMapper mapper = JsonMapper.builder()
    .addModule(new MyCustomJacksonModule())  // Must extend JacksonModule now
    .build();
```

### Pattern 4: YAML Mapper
**Before**:
```java
ObjectMapper yamlMapper = new ObjectMapper(new YAMLFactory());
yamlMapper.configure(YAMLGenerator.Feature.MINIMIZE_QUOTES, true);
```

**After**:
```java
YAMLMapper yamlMapper = YAMLMapper.builder()
    .enable(YAMLGenerator.Feature.MINIMIZE_QUOTES)
    .build();
```

### Pattern 5: Custom Serializer
**Before**:
```java
public class DateSerializer extends JsonSerializer<Date> {
    @Override
    public void serialize(Date value, JsonGenerator gen, SerializerProvider serializers) 
            throws IOException {
        gen.writeString(new SimpleDateFormat("yyyy-MM-dd").format(value));
    }
}
```

**After**:
```java
public class DateSerializer extends ValueSerializer<Date> {
    @Override
    public void serialize(Date value, JsonGenerator gen, SerializationContext ctxt) 
            throws IOException {
        gen.writeString(new SimpleDateFormat("yyyy-MM-dd").format(value));
    }
}
```

## Validation Checklist

After migration, verify:

- [ ] Java version is 17 or higher
- [ ] All dependencies updated to `tools.jackson` group IDs
- [ ] Jackson BOM added for version management
- [ ] All imports updated (except annotations)
- [ ] No `new ObjectMapper()` direct instantiation with post-configuration
- [ ] All ObjectMapper instances use builder pattern
- [ ] Format-specific mappers use dedicated classes (YAMLMapper, XmlMapper, etc.)
- [ ] Custom serializers/deserializers extend Value* classes
- [ ] SerializerProvider replaced with SerializationContext
- [ ] Obsolete Java 8 modules removed from dependencies
- [ ] Code compiles without errors: `mvn clean compile`
- [ ] All tests pass: `mvn test`
- [ ] No old import statements remain: `grep -r "import com.fasterxml.jackson" --include="*.java" . | grep -v "annotation"`
- [ ] Exception handling updated (optional, but good to verify)

## Best Practices to Communicate

1. **Use Jackson BOM**: Simplifies version management across all Jackson modules
2. **Target Jackson 3.1+**: More stable than 3.0 for long-term projects
3. **Builder pattern**: Always use builders for ObjectMapper configuration
4. **Format-specific mappers**: Use dedicated mapper classes (JsonMapper, YAMLMapper, etc.)
5. **Java 17 required**: Ensure Java version compatibility before starting
6. **Test thoroughly**: Pay special attention to serialization/deserialization edge cases
7. **Incremental migration**: Can be done file-by-file or package-by-package
8. **OpenRewrite option**: Consider using OpenRewrite for automated migration: `org.openrewrite.java.jackson.upgradejackson_2_3`

## Error Handling

If you encounter issues:

1. **Compilation errors**:
   - Check Java version (must be 17+)
   - Verify all imports updated correctly
   - Ensure class renamings are complete (JsonSerializer → ValueSerializer, etc.)

2. **Dependency conflicts**:
   - Use `mvn dependency:tree` to identify conflicts
   - Ensure consistent Jackson version across all modules
   - Remove obsolete Java 8 modules

3. **Runtime serialization/deserialization errors**:
   - Check for changed default behaviors (FAIL_ON_TRAILING_TOKENS, enum handling)
   - Verify format-specific mappers are correctly instantiated
   - Review custom serializer/deserializer implementations

4. **Missing classes**:
   - Some classes were removed (DataFormatDetector, MappingJsonFactory, ObjectCodec)
   - Find alternatives or refactor code

5. **Performance issues**:
   - Jackson 3 uses different buffer recycling by default
   - Consider configuring `RecyclerPool` for 2.x-compatible performance

## What NOT to Do

- Don't assume annotation imports need changing (they stay `com.fasterxml.jackson.annotation`)
- Don't keep direct ObjectMapper instantiation with post-configuration (use builders)
- Don't manually update each module version separately (use jackson-bom)
- Don't keep obsolete Java 8 module dependencies
- Don't use removed APIs (ObjectCodec, DataFormatDetector, MappingJsonFactory)
- Don't skip testing after migration (behavioral changes can be subtle)
- Don't forget to check custom serializers/deserializers

## When to Search the Guide

Use Grep to search the migration guide for:
- Specific class names you're migrating
- Error messages encountered
- Feature flags and configuration options
- Method names that need updating
- Exception types

## Success Criteria

A successful migration means:
1. All dependencies use `tools.jackson` group IDs (except annotations)
2. All imports updated correctly
3. All ObjectMapper instances use builder pattern
4. No compilation errors
5. All tests pass
6. Serialization/deserialization produces identical results
7. No old Jackson 2.x patterns remain
8. Code uses Jackson 3.x idioms and best practices

When migration is complete, provide a summary of:
- Number of files modified
- Key changes made (imports, ObjectMapper configs, custom serializers, etc.)
- Any behavioral changes to be aware of
- Validation checklist

## Additional Notes

- The migration can be done incrementally (file-by-file or module-by-module)
- Consider using IDE refactoring tools for bulk import changes
- OpenRewrite provides automated migration recipes
- Spring Framework has Jackson 3 support in recent versions
- Monitor for performance differences after migration (buffer recycling changes)
