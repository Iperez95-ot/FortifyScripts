<%@ page trimDirectiveWhitespaces="true" %>
<%@ page language="java" pageEncoding="UTF-8"%>
<%@ page import="com.fortify.manager.security.auth.AfterLoginEnvironmentInitializer"%>
<%@ page import="com.fortify.manager.spring.ApplicationContextProvider"%>
<%

    AfterLoginEnvironmentInitializer alei = ApplicationContextProvider.getBean(AfterLoginEnvironmentInitializer.class);
    if (!alei.initWebInspectEnvironment(request, response)) {
      response.sendRedirect("index.jsp");
    }
%>
