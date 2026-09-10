package de.mobile.opsx.web.util;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class SafePathsTest {

    @Test
    void acceptsPlainSegments() {
        assertThat(SafePaths.isSafeId("control-plane-desktop-console")).isTrue();
        assertThat(SafePaths.isSafeId("foo_bar.v2")).isTrue();
    }

    @Test
    void rejectsEmptyAndDots() {
        assertThat(SafePaths.isSafeId("")).isFalse();
        assertThat(SafePaths.isSafeId(".")).isFalse();
        assertThat(SafePaths.isSafeId("..")).isFalse();
        assertThat(SafePaths.isSafeId(null)).isFalse();
    }

    @Test
    void rejectsSeparatorsAndMetacharacters() {
        assertThat(SafePaths.isSafeId("a/b")).isFalse();
        assertThat(SafePaths.isSafeId("../etc")).isFalse();
        assertThat(SafePaths.isSafeId("a b")).isFalse();
        assertThat(SafePaths.isSafeId("a;rm -rf")).isFalse();
        assertThat(SafePaths.isSafeId("a$b")).isFalse();
    }

    @Test
    void rejectsOverlongIds() {
        assertThat(SafePaths.isSafeId("a".repeat(129))).isFalse();
        assertThat(SafePaths.isSafeId("a".repeat(128))).isTrue();
    }
}
