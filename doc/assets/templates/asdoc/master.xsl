<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="xml"
  doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
  doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
  omit-xml-declaration="yes"
  encoding="UTF-8"
  indent="yes" />

<xsl:template match="/">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
	<title>Title</title>
	<style type="text/css">@import url(../_css/styles.css);</style>
	<script src="../_js/prototype.js" type="text/javascript" charset="utf-8"></script>
</head>
<body>
	<div id="toc">
		<iframe src="package-list.html" name="toc_frame"></iframe>
	</div>
	<div id="header">
		<a href="#" id="logo"><img src="../_img/logo.gif" /></a>
		<ul id="mainNavigation">
			<li><a href="../abstract/introduction.html">Abstract</a></li>
			<li><a href="../css/background.html">CSS Documentation</a></li>
			<li><a href="../asdoc/index.html">Source Documentation</a></li>
			<li><a href="../cookbook/doing_stuff.html">Cookbook</a></li>
		</ul>
	</div>
	<div id="content">
		<xsl:apply-templates/>
	</div>
</body>
</html>

</xsl:template>

</xsl:stylesheet>