When a project is opened in Audit Workbench (or another Fortify product, like an IDE plugin or Software Security Center), it's always visualized within the context of an issue template.  The issue template is resolved in the following ordered locations:

(1) "filtertemplate.xml" within the fpr
(2) "defaulttemplate.xml" in this directory (Core/config/filters)
(3) "defaulttemplate.xml" in the rules directory (Core/config/rules)
(4) "projecttemplate.xml" in the rules directory (Core/config/rules)
(5) Fortify's default issue template

So if an fpr contains an issue template, that will always be used.  However, if an fpr does not contain any issue template (which is the case for most new scans), then it will look in the other locations.  Since it's at the top of the list, placing a "defaulttemplate.xml" file in this directory will ensure that it's used over issue templates in the rules directory, as well as Fortify's default issue template.

If you choose to set a default issue template on Software Security Center, that will get downloaded into the rules directory.  So creating a "defaulttemplate.xml" file in this directory will override what gets downloaded from Software Security Center.