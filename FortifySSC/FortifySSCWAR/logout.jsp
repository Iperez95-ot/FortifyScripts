<%@ page errorPage="/error.jsp" %>
<%@ include file="/WEB-INF/jsp/common/taglibs.jsp"%>
<% 
    session.invalidate();
%>
<c:redirect url="/login.jsp"/>