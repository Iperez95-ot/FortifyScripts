<!DOCTYPE html>
<html>
<%@ include file="/WEB-INF/jsp/common/taglibs.jsp"%>
<c:set var="titleKey" value="label.product"/>
<%@ include file="/WEB-INF/jsp/common/head.jsp" %>
<%@ page import="com.fortify.manager.service.message.MessageResolver" %>
<%@ page import="com.fortify.manager.spring.ApplicationContextProvider" %>
<%@ page import="com.fortify.server.messaging.ServerMessageCodes" %>
<%@ page import="com.fortify.util.StringUtil" %>
<%@ page import="com.fortify.manager.security.auth.PasswordStrengthChecker" %>
<%@ page errorPage="/error.jsp" %>
<%@ include file="/WEB-INF/jsp/common/taglibs.jsp" %>
<%--
/***********************************************************************
 * Copyright 2014-2023 Open Text
 ************************************************************************/
--%>
<%
	String contextPath = request.getContextPath();
%>

<%
	int minPasswordScore = ApplicationContextProvider.getBean(PasswordStrengthChecker.class).getMinStrengthScore();
	request.setAttribute("minPasswordScore", minPasswordScore);
	String errorCode = request.getParameter("detailedError");
	final String errorMessageContextVarName = "errorMessage";
    pageContext.setAttribute(errorMessageContextVarName, "");
    final String notFoundMessage = "";
	if (errorCode != null) {
		String formatedMessage = ApplicationContextProvider.getBean(MessageResolver.class).getMessageOrDefault(errorCode, notFoundMessage, null);
        if (!errorCode.equals(formatedMessage) && !notFoundMessage.equals(formatedMessage)) {
            pageContext.setAttribute(errorMessageContextVarName, formatedMessage);
        }
	}
    String noMatchMessage = ApplicationContextProvider.getBean(MessageResolver.class).getMessage(ServerMessageCodes.ERROR_CONFIRM_PWD_NOT_MATCH_STRING);
    String[] strengthDesc = {"Poor", "Weak", "Medium", "Strong", "Very strong"};

%>
<link rel="shortcut icon" type="image/xml+svg" href="<%= contextPath %>/html/design-tokens/assets/graphics/favicon-fortify.svg" />
<script type="text/javascript" src="scripts/jquery/jquery.min.js"></script>
<script type="text/javascript" src="scripts/passwordStrength/passwordStrength.js"></script>
<link rel="stylesheet" media="all" href="<%= contextPath %>/html/design-tokens/css/tokens.all.css"></link>
<link rel="stylesheet" media="all" href="<%= contextPath %>/html/design-tokens/css/tokens.theme-dark.css"></link>
<link rel="stylesheet" media="all" href="scripts/passwordStrength/passwordStrength.css"></link>

<c:set var="titleKey" value="title.changePassword"/>

<body>
<div class="login-form-item">
	<div class="modal modal-login center-block">
		<h3><fmt:message key="title.changePassword"/></h3>
		<form autocomplete="off" class="form-flat" id="changePassword" method="post" action='<c:url value='j_spring_security_check'/>'>
			<input type="hidden" name="referredBy" value="<%=  StringUtil.sanitizeHtml(request.getParameter("referredBy"))%>"/>
			<div class="form-group empty-value">
				<input type="password" name="oldPassword" id="oldPassword" size="25" required autofocus placeholder="<fmt:message key='label.user.password.old'/>"/>
			</div>
			<div class="form-group empty-value">
				<input type="password" name="j_password" id="newpwd1" size="25" onkeyup="passwordCheck(this.value, actionUrl, minPasswordScore);" required placeholder="<fmt:message key='label.user.password.new'/>"/>
			</div>
			<div class="form-group empty-value confirm-password">
				<input type="password" name="confirmPassword" id="confirmPassword" size="25" required placeholder="<fmt:message key='label.user.password.confirm.new'/>"/>
				<c:if test="${param.detailedError != null}">
					<div class="alert alert-error">
						<c:out value="${errorMessage}" escapeXml="true"/>
					</div>
				</c:if>
			</div>
			<div class="control-group change-password-title">
				<label class="control-label" for="passwordStrengthGray"><fmt:message key='label.user.password.strength'/></label>
			</div>
			<div id="controlsStrength" class="controls strength">
				<div id="passwordStrengthColor" class="strength0">
					<div id="passwordDescription"></div>
				</div>
				<div id="passwordStrengthGray" class="gray0"></div>
			</div>
			<div id="passwordMinStrength" class="minStrength0">
				<i class="arrow-up"></i>
			</div>
			<div class="alert alert-info">
				<fmt:message key='instructions.must.change.password'><fmt:param value="<%= strengthDesc[minPasswordScore] %>"/></fmt:message>
			</div>
		</form>
		<div class="modal-footer">
			<button type="submit" class="btn btn-flat btn-primary" name="save" id="save" value="<fmt:message key='label.save'/>"
			       onclick="submitAuthForm();"><fmt:message key='label.save'/></button>
			<button type="button" id="cancelChangePassword" class="btn btn-flat btn-secondary" value="<fmt:message key="label.cancel"/>" onclick="cancel()">
				<fmt:message key="label.cancel"/></button>
		</div>
	</div>
</div>

<script type="text/javascript" src="${pageContext.request.contextPath}/html/login/static-dark-mode.js"></script>
<script type="text/javascript">
    var actionUrl = '<%= contextPath %>/api/v1/localUsers/action/checkPasswordStrength';
    var minPasswordScore = <%= minPasswordScore %>;
    var minStrengthTickerScore = minPasswordScore + 1;
    document.getElementById("passwordMinStrength").className = " minStrength" + minStrengthTickerScore;
    function parseQuery ( query ) {
        var Params = new Object ();
        if ( ! query ) return Params; // return empty object
        var Pairs = query.split(/[;&]/);
        for ( var i = 0; i < Pairs.length; i++ ) {
            var KeyVal = Pairs[i].split('=');
            if (!KeyVal || KeyVal.length != 2 ) continue;
            var key = unescape( KeyVal[0] );
            var val = unescape( KeyVal[1] );
            val = val.replace(/\+/g, ' ');
            Params[key] = val;
        }
        return Params;
    }
    var noMatchMessage = "<div id=\"clientSideMessage\" class=\"alert alert-error\"><%= noMatchMessage %></div>";
	function cancel() {
		var logoutUrl = '<%= contextPath %>/logout.html';
		var referredBy = parseQuery(window.location.search.substring(1)).referredBy;
		if (referredBy && referredBy.length > 0) {
			if (referredBy.charAt(0) !== '/') {
				referredBy = '/' + referredBy;
			}
			window.location = '<%= contextPath %>/html/ssc'+referredBy;
		} else {
			window.location = logoutUrl;
		}
	}

	function handleChange() {
        var isOldEmpty = document.getElementById('oldPassword').value === "";
		var isNewEmpty = document.getElementById('newpwd1').value === "";
        var isConfirmEmpty = document.getElementById('confirmPassword').value === "";
        var confirmMatches = $('#confirmPassword').val() === $('#newpwd1').val();
        if(isOldEmpty && confirmMatches && !isNewEmpty){
            $('#oldPassword').addClass('input-error');
        }else{
            $('#oldPassword').removeClass('input-error');
        }
        if(!isConfirmEmpty && !confirmMatches){
            $('#confirmPassword').addClass('input-error');
            if(!confirmMatches && $('#clientSideMessage').length === 0){
                $('.confirm-password').append(noMatchMessage);
            }
        }else {
            $('#confirmPassword').removeClass('input-error');
            if(confirmMatches){
                $('#clientSideMessage').remove();
            }
        }
        if(isNewEmpty){
            document.getElementById("passwordDescription").innerHTML = '';
            document.getElementById("passwordStrengthColor").className = "strength0";
            document.getElementById("passwordStrengthGray").className = "gray0";
		}
        var disabled = isConfirmEmpty || isNewEmpty || isOldEmpty || isLowerThanMinPasswordScore || !confirmMatches;
		document.getElementById('save').disabled = disabled;
		return disabled;
	}

	function handlePress(evt)
	{
		var valid = !handleChange();
		if(evt.keyCode == 13 )
		{
			if (valid) {
				submitAuthForm();
			} else {
				evt.preventDefault();
			}
		}
	}

	function submitAuthForm() {
		if (!handleChange()) {
			document.getElementById('changePassword').submit();
		}
	}
	document.getElementById('oldPassword').addEventListener('keyup', handlePress);
	document.getElementById('newpwd1').addEventListener('keyup', handlePress);
	document.getElementById('confirmPassword').addEventListener('keyup', handlePress);
	document.addEventListener('keydown', handlePress);
	handleChange();
	document.getElementById('oldPassword').focus();
</script>

</body>
</html>
