<%--
  ~ Copyright 2024 Open Text
  --%>

<%
	if (response.getHeader("error-reason") == null || response.getHeader("error-reason").isEmpty()) {
%>
	<%@ include file="/WEB-INF/jsp/common/taglibs.jsp" %>
	<%@ page isErrorPage="true"%>
	<html>
	<head>
		<style type="text/css">
			body{
				font-family:Arial, Helvetica, sans-serif;
			}
			h1{font-size:26px;}
			p{margin:0 0 20px;font-size:14px;}
		</style>
	</head>
		<body>
			<c:set var="errorCode" value="${requestScope['jakarta.servlet.error.status_code']}"/>
			<p>
				<img src="<c:url value='/images/blue_fortify_logo.png'/>">
			</p>
			<c:choose>
				<c:when test="${errorCode==400}">
					<c:set var="errorTitle"><fmt:message key='error.400.title'/></c:set>
					<c:set var="errorMessage"><fmt:message key='error.400.message'/></c:set>
				</c:when>
				<c:when test="${errorCode==401}">
					<c:set var="errorTitle"><fmt:message key='error.401.title'/></c:set>
					<c:set var="errorMessage"><fmt:message key='error.401.message'/></c:set>
				</c:when>
				<c:when test="${errorCode==403}">
					<c:set var="errorTitle"><fmt:message key='error.403.title'/></c:set>
					<c:set var="errorMessage"><fmt:message key='error.403.message'/></c:set>
				</c:when>
				<c:when test="${errorCode==404}">
					<c:set var="errorTitle"><fmt:message key='error.404.title'/></c:set>
					<c:set var="errorMessage"><fmt:message key='error.404.message'/></c:set>
				</c:when>
				<c:when test="${errorCode==500}">
					<c:set var="errorTitle"><fmt:message key='error.500.title'/></c:set>
					<c:set var="errorMessage"><fmt:message key='error.500.message'/></c:set>
				</c:when>
				<c:otherwise>
					<c:set var="errorTitle"><fmt:message key='error.unexpected.generic'/></c:set>
					<c:set var="errorMessage"><fmt:message key='error.unexpected'><fmt:param value="${errorCode}"/></fmt:message></c:set>
				</c:otherwise>
			</c:choose>
			<h1><c:out value="${errorTitle}"/></h1>
			<hr>
			<p><c:out value="${errorMessage}"/></p>
		</body>
	</html>
<%
	} else {
		out.print(response.getHeader("error-reason"));
	}
%>
