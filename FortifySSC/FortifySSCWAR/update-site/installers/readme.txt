Note: Replace the version listed below with your current version.

To enable Fortify Applications and Tools or Fortify Static Code Analyzer upgrades from Audit Workbench, do the following:

1) Navigate to the <tomcat_apps>/ssc/WEB-INF/internal directory, open the securityContext.xml file in a text editor, and uncomment the following line:
<!-- <security:intercept-url pattern="/update-site/**" access="PERM_ANONYMOUS"/> -->

2) Copy one or more Fortify_SCA or Fortify_Apps_and_Tools installer files to the <tomcat_apps>/ssc/update-site/installers directory.

3) Create an XML file for the product that you want to update using the following samples:

a) To enable Fortify Static Code Analyzer updates, use the following sample update-sca.xml file contents:

<installerInformation>
    <versionId>2310</versionId>
    <version>23.1.0</version>
    <platformFileList>
        <platformFile>
            <filename>Fortify_SCA_23.1.0_windows_x64.exe</filename>
            <platform>windows-x64</platform>
        </platformFile>
        <platformFile>
            <filename>Fortify_SCA_23.1.0_linux_x64.run</filename>
            <platform>linux-x64</platform>
        </platformFile>
        <platformFile>
            <filename>Fortify_SCA_23.1.0_osx_x64.app.zip</filename>
            <platform>osx</platform>
        </platformFile>
    </platformFileList>
    <downloadLocationList>
        <downloadLocation>
            <url>http://localhost:8080/update-site/installers/</url>
        </downloadLocation>
    </downloadLocationList>
</installerInformation>

b) To enable Fortify Applications and Tools updates, use the following sample update-appsandtools.xml file contents:

<installerInformation>
    <versionId>2310</versionId>
    <version>23.1.0</version>
    <platformFileList>
        <platformFile>
            <filename>Fortify_Apps_and_Tools_23.1.0_windows_x64.exe</filename>
            <platform>windows-x64</platform>
        </platformFile>
        <platformFile>
            <filename>Fortify_Apps_and_Tools_23.1.0_linux_x64.run</filename>
            <platform>linux-x64</platform>
        </platformFile>
        <platformFile>
            <filename>Fortify_Apps_and_Tools_23.1.0_osx_x64.app.zip</filename>
            <platform>osx</platform>
        </platformFile>
    </platformFileList>
    <downloadLocationList>
        <downloadLocation>
            <url>http://localhost:8080/update-site/installers/</url>
        </downloadLocation>
    </downloadLocationList>
</installerInformation>

A Fortify Audit Workbench user can then select the configuration to use by entering the full path to the configuration file in the Server URL box in the Audit Workbench Upgrade Configuration section of the Audit Workbench options dialog box. (In Audit Workbench, select Options > Options > Server Configuration.)

To check your setup, use your browser to navigate to the newly-added XML config files: http://localhost:8080/update-site/installers/update-sca.xml and http://localhost:8080/update-site/installers/update-appsandtools.xml

You can find documentation for the Installbuilder autoupdate tool at:

https://releases.bitrock.com/installbuilder/docs/installbuilder-userguide/_autoupdate_tool.html

Important Notes:

- The Software Security Center administrator must ensure that the value of the "versionId" tag matches the version included in the corresponding installer.

- To specify the versionId, use the major, minor, and patch portions of the version number with the periods removed. For example, for Fortify Static Code Analyzer patch version 23.1.1, specify 2311 as the "versionId" tag.

For more information, see the Fortify Software Security Center User Guide and the Fortify Audit Workbench User Guide.
