package de.mobile.opsx.web.config;

import java.io.IOException;

import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * CSRF / DNS-rebinding guard for the state-mutating POST endpoints.
 *
 * <p>The console has no session and no Spring Security, so there is no CSRF token.
 * Every mutation is driven by HTMX, which always sends {@code HX-Request: true}.
 * A cross-origin HTML {@code <form>} auto-submitted by a page the operator happens
 * to be visiting is a "simple" request and cannot set that custom header, so
 * requiring it rejects the classic localhost-tool CSRF vector while leaving the
 * app's own HTMX calls untouched. GET (read-only) requests are never gated.
 */
@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
public class HtmxCsrfFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
            FilterChain chain) throws ServletException, IOException {
        if ("POST".equalsIgnoreCase(request.getMethod())
                && !"true".equalsIgnoreCase(request.getHeader("HX-Request"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "cross-origin or non-HTMX POST rejected");
            return;
        }
        chain.doFilter(request, response);
    }
}
