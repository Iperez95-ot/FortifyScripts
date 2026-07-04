<%@ include file="/WEB-INF/jsp/common/taglibs.jsp"%>
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8">

    <title><c:if test="${not empty titleKey}"><fmt:message key="${titleKey}"><fmt:param><c:out value="${pageTitleParam}"/></fmt:param></fmt:message></c:if></title>

    <link rel="stylesheet" type="text/css" media="all" href="<c:url value="/styles/changepassword.css"/>"/>
    <%-- include javascripts here --%>
    <script type="text/javascript">if (top!=self) top.location.href=self.location.href;</script>
</head>
