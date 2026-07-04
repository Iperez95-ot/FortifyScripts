<%@ page import="com.fortify.manager.BLL.services.ProjectVersionService" %>
<%@ page import="com.fortify.manager.exception.FMDALException" %>
<%@ page import="com.fortify.manager.exception.FMSecurityException" %>
<%@ page import="com.fortify.manager.spring.ApplicationContextProvider" %>
<%@ page import="com.fortify.manager.util.RequestParameterConstants" %>
<%@ page import="com.fortify.server.messaging.ServerMessageCodes" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="org.apache.commons.logging.Log" %>
<%@ page import="org.apache.commons.logging.LogFactory" %>
<%! final private static Log LOG = LogFactory.getLog("com.fortify.manager.jsp.flex.index"); %>
<%
    /*
     * Backward compatibility layer for deep links to removed Flex UI.
     */
    final String projectName = request.getParameter(RequestParameterConstants.PROJECT_NAME_PARAM);
    final String projectVersionName = request.getParameter(RequestParameterConstants.PROJECT_VERSION_NAME_PARAM);
    final String issue = request.getParameter(RequestParameterConstants.ISSUE_PARAM);
    final String engineType = request.getParameter(RequestParameterConstants.ENGINE_TYPE_PARAM);

    // Legacy flex issue and version deep links will redirect to related html deep link.
    // Other flex links will redirect to SSC homepage.
    if (StringUtils.isNotBlank(projectName) && StringUtils.isNotBlank(projectVersionName)) {
        final ProjectVersionService projectVersionService = ApplicationContextProvider.getBean(ProjectVersionService.class);
        final String redirectUri;
        try {
            if (StringUtils.isNotBlank(issue)) {
                // issue deep link
                redirectUri = projectVersionService.generateIssueDeepLink(projectName, projectVersionName, issue, engineType);
            } else {
                // assume if we have projectName and projectVersionName but no issue, then it is a project version link
                redirectUri = projectVersionService.generateProjectVersionDeepLinkForHTML(projectName, projectVersionName);
            }
        } catch (final FMSecurityException e) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        } catch (final FMDALException e) {
            switch (e.getErrorCode()) {
                case ServerMessageCodes.ERROR_APP_NOT_EXIST:
                case ServerMessageCodes.ERROR_ISSUE_DOES_NOT_EXIST:
                    break;
                default:
                    LOG.error("Failed to translate flex deep link", e);
                    break;
            }
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        } catch (final Exception e) {
            LOG.error("Failed to translate flex deep link", e);
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        response.sendRedirect(redirectUri);
    } else {
        // request not recognized
        response.sendError(HttpServletResponse.SC_NOT_FOUND);
    }
%>
