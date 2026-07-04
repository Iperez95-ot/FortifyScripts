<%@ page errorPage="/error.jsp" %>
<%@ page import="com.fortify.manager.service.SystemConfigurationService" %>
<%@ page import="com.fortify.manager.spring.ApplicationContextProvider" %>
<%@ page import="com.fortify.manager.util.SystemConfigurationConstants" %>
<%@ page import="com.fortify.pub.issueparsing.NameValuePair" %>
<%@ page import="com.fortify.ssc.utils.Sanitizer" %>
<%@ page import="com.fortify.util.StringUtil" %>
<%@ page import="com.google.common.net.UrlEscapers" %>
<%@ page import="com.fortify.manager.web.security.auth.LocalLoginNotAllowedException" %>
<%@ page import="org.springframework.security.authentication.BadCredentialsException" %>
<%@ page import="org.springframework.security.authentication.DisabledException" %>
<%@ page import="org.springframework.security.authentication.LockedException" %>
<%@ page import="org.springframework.security.web.WebAttributes" %>
<%@ page import="java.util.List" %>
<%@ page import="org.apache.commons.text.StringEscapeUtils" %>
<%
    //remove cache for this page:
    response.addHeader("Pragma", "no-cache");
    response.addHeader("Cache-Control", "no-cache");

    response.addHeader("Cache-Control", "no-store");
    response.addHeader("Cache-Control", "must-revalidate");
    // expires on some date in the past
    response.addHeader("Expires", "Mon, 8 Aug 2006 10:00:00 GMT");

    // These exceptions are thrown by Spring Security
    boolean showErrorMessage = false;
    String messageKey = "error.loginFailure";
    Object exceptionObj = session.getAttribute(WebAttributes.AUTHENTICATION_EXCEPTION);
    if (exceptionObj == null) {
        exceptionObj = request.getAttribute(WebAttributes.ACCESS_DENIED_403);
    }
    // quick fix for bug #40809
    session.removeAttribute(WebAttributes.AUTHENTICATION_EXCEPTION);
    String messageCssClass = "danger";
    final String LOGIN_ERROR_HEADER = "Login-Error";
    if (exceptionObj != null) {
        showErrorMessage = true;
        if (exceptionObj instanceof BadCredentialsException) {
            messageKey = "error.loginFailure";
            response.addHeader(LOGIN_ERROR_HEADER, "loginFailure");
        } else if (exceptionObj instanceof LocalLoginNotAllowedException) {
            // TODO: use a more specific error
            messageKey = "error.loginFailure";
            response.addHeader(LOGIN_ERROR_HEADER, "loginFailure");
        } else if (exceptionObj instanceof DisabledException) {
            messageKey = "error.userSuspended";
            response.addHeader(LOGIN_ERROR_HEADER, "userSuspended");
        } else if (exceptionObj instanceof LockedException) {
            messageKey = "error.userFrozen";
            response.addHeader(LOGIN_ERROR_HEADER, "loginFailure");
        } else if (exceptionObj instanceof org.springframework.security.access.AccessDeniedException) {
            messageKey = "error.accessDenied";
            response.addHeader(LOGIN_ERROR_HEADER, "accessDenied");
        } else {
            // default error
            messageKey = "error.loginFailure";
            response.addHeader(LOGIN_ERROR_HEADER, "loginFailure");
        }
    } else {
        String passwordReset = request.getParameter("passwordReset");
        if (passwordReset != null && "true".equals(passwordReset)) {
            showErrorMessage = true;
            messageKey = "password.reset";
            messageCssClass = "success";
            response.addHeader(LOGIN_ERROR_HEADER, "reset");
        }
    }
    boolean isEmailEnabled = false;
    List configurations = ApplicationContextProvider.getBean(SystemConfigurationService.class).getSystemConfiguration();
    for (int i = 0; i < configurations.size(); i++) {
        NameValuePair pair = (NameValuePair)configurations.get(i);
        if (pair.getName().equals(SystemConfigurationConstants.IS_EMAIL_ENABLED)) {
            if (pair.getValue() != null && pair.getValue().equals("TRUE")) {
                isEmailEnabled = true;
            }
        }
    }
    String hostUrl = ApplicationContextProvider.getContext().getEnvironment().getRequiredProperty("host.url");

    String return_to = Sanitizer.sanitizeInternalReturnTo(request.getParameter("return_to"), hostUrl);
    if (StringUtil.isEmpty(return_to)) {
        return_to = Sanitizer.sanitizeInternalReturnTo(request.getHeader("referer"), hostUrl);
        if (!StringUtil.isEmpty(return_to)) {
            return_to = UrlEscapers.urlFragmentEscaper().escape(return_to);
        } else {
            return_to = "";
        }
    }
%>
<%@ include file="/html/login/login.html"%>
