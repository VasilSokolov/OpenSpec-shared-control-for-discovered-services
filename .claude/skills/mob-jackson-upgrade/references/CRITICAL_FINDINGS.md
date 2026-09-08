# Critical Jackson 3 Migration Findings

Based on real-world migration experience with Spring Boot 4.0 + Jackson 3.

## Key Discoveries

### 1. Lombok Configuration (CRITICAL)

**Correct Configuration**:
```properties
lombok.addLombokGeneratedAnnotation = true
lombok.copyableAnnotations += org.springframework.beans.factory.annotation.Qualifier
lombok.jacksonized.jacksonVersion += 3
```

**WRONG Configuration** (does NOT work):
```properties
lombok.jacksonized.jackson3=true  # This key is not recognized!
```

**Why This Matters**:
- Lombok's `@Jacksonized` annotation needs to know which Jackson version to generate code for
- The correct property is `lombok.jacksonized.jacksonVersion += 3`
- Using the wrong property results in compilation warnings: "Ambiguous: Jackson2 and Jackson3 exist; define which variant(s) you want in 'lombok.config'"

### 2. JsonProcessingException Renamed to JacksonException (CRITICAL)

**Important**: `JsonProcessingException` is **renamed** to `JacksonException` in Jackson 3!

**Correct Usage**:
```java
import tools.jackson.core.JacksonException;

try {
    String json = mapper.writeValueAsString(object);
} catch (JacksonException e) {
    // Handle exception
}
```

**What Changed**:
- Package moved from `com.fasterxml.jackson.core` to `tools.jackson.core`
- Class name changed from `JsonProcessingException` to `JacksonException`
- It's now an unchecked exception (extends `RuntimeException`), but you can still catch it

**Common Mistake**:
```java
// WRONG - Old name no longer exists
import tools.jackson.core.JsonProcessingException;  
```

### 3. Spring Boot 4.0 Manages Jackson 3 Dependencies

**No Explicit Jackson Dependencies Needed**:
When using Spring Boot 4.0+, you don't need to explicitly add Jackson dependencies or BOM:

```xml
<!-- NOT NEEDED - Spring Boot 4.0 parent manages this -->
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>tools.jackson</groupId>
            <artifactId>jackson-bom</artifactId>
            <version>3.x.x</version>
        </dependency>
    </dependencies>
</dependencyManagement>
```

Spring Boot 4.0's parent POM already includes Jackson 3 BOM management.

### 4. Import Migration Pattern

**Only Non-Annotation Imports Change**:

```java
// CHANGE THESE:
import com.fasterxml.jackson.databind.ObjectMapper;     → import tools.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.JsonNode;         → import tools.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.json.JsonMapper;  → import tools.jackson.databind.json.JsonMapper;
import com.fasterxml.jackson.core.JsonProcessingException; → import tools.jackson.core.JacksonException;

// KEEP THESE UNCHANGED:
import com.fasterxml.jackson.annotation.JsonProperty;   // ✓ No change
import com.fasterxml.jackson.annotation.JsonIgnore;     // ✓ No change
import com.fasterxml.jackson.annotation.JsonTypeInfo;   // ✓ No change
import com.fasterxml.jackson.annotation.JsonSubTypes;   // ✓ No change
```

**Bulk Update Commands**:
```bash
# Update databind imports
find . -name "*.java" -type f -exec sed -i '' 's/import com\.fasterxml\.jackson\.databind\./import tools.jackson.databind./g' {} +

# Update core imports
find . -name "*.java" -type f -exec sed -i '' 's/import com\.fasterxml.jackson\.core\./import tools.jackson.core./g' {} +
```

### 5. ObjectMapper Builder Pattern

**Old Pattern (Jackson 2)**:
```java
ObjectMapper mapper = new ObjectMapper();
mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
```

**New Pattern (Jackson 3)**:
```java
import tools.jackson.databind.json.JsonMapper;

ObjectMapper mapper = JsonMapper.builder()
    .disable(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES)
    .build();
```

**Important**: When ObjectMapper is injected by Spring (auto-configured), you don't need to change anything in your code. The builder pattern is only needed for manual ObjectMapper instantiation.

## Migration Checklist (Updated)

- [ ] **Lombok Config**: Update to `lombok.jacksonized.jacksonVersion += 3`
- [ ] **Import Statements**: Replace `com.fasterxml.jackson.databind` → `tools.jackson.databind`
- [ ] **Import Statements**: Replace `com.fasterxml.jackson.core` → `tools.jackson.core`
- [ ] **Annotation Imports**: Verify they stay `com.fasterxml.jackson.annotation` (no change)
- [ ] **Exception Handling**: Update to `tools.jackson.core.JacksonException` (renamed from JsonProcessingException!)
- [ ] **Manual ObjectMapper**: Convert to `JsonMapper.builder()` pattern
- [ ] **Verify Compilation**: No "Ambiguous: Jackson2 and Jackson3 exist" warnings
- [ ] **Test**: Run full test suite

## Common Compilation Errors and Fixes

### Error: "Ambiguous: Jackson2 and Jackson3 exist"
**Cause**: Missing or incorrect lombok.config
**Fix**: Add `lombok.jacksonized.jacksonVersion += 3` to lombok.config

### Error: "Package tools.jackson.core does not contain JsonProcessingException"
**Cause**: Using old exception name from Jackson 2
**Fix**: Use `JacksonException` (NOT `JsonProcessingException`)

### Error: "Symbol not found: class JsonProcessingException"
**Cause**: Using old Jackson 2 exception name in catch block
**Fix**: Change to `JacksonException`

## Validation Commands

```bash
# Verify only annotation imports remain with old package
grep -r "import com.fasterxml.jackson" src --include="*.java" | grep -v "annotation"
# Should return 0 results

# Count Jackson 3 imports
grep -r "import tools.jackson" src --include="*.java" | wc -l
# Should show your Jackson import count

# Check lombok.config
cat lombok.config | grep "jacksonized"
# Should show: lombok.jacksonized.jacksonVersion += 3
```

## Spring Boot 4.0 Compatibility Notes

- Spring Boot 4.0 uses Jackson 3.0.x by default
- No explicit Jackson BOM needed in Spring Boot projects
- ObjectMapper is auto-configured by Spring with Jackson 3
- All Spring converters (HTTP message converters, etc.) automatically use Jackson 3
- Spring's `@RequestBody`, `@ResponseBody` work transparently with Jackson 3

## Summary

The Jackson 3 migration in a Spring Boot 4.0 project is primarily:
1. Update lombok.config with correct property
2. Bulk-replace import statements (except annotations)
3. Rename `JsonProcessingException` to `JacksonException`
4. Use builder pattern for manual ObjectMapper instances
5. No explicit dependency management needed
