<%@ page errorPage="/error.jsp" %>
<%@ page import="com.fortify.manager.spring.ApplicationContextProvider" %>
<%@ page import="com.fortify.ssc.config.AppConfProvider" %>
<%@ page import="jakarta.servlet.ServletContext" %>
<%--
  ~ Copyright 2024 Open Text
  --%>

<%
    ServletContext sc = request.getSession().getServletContext();
    AppConfProvider appConfProvider = ApplicationContextProvider.getBean(AppConfProvider.class);
    if (appConfProvider.isAppConfigured()) {
        response.sendRedirect(sc.getContextPath() + "/html/ssc/index.jsp");
    }
%>
<%@ include file="/html/login/maintenance.html"%>
