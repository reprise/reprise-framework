<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:include href="asdoc-util.xsl"/>

<xsl:template match="/">
	<xsl:copy-of select="$docType" />
	<html>
		<head>
			<title>Package List - <xsl:value-of select="$title-base"/></title>
			<base id="base_target" target="_top"/>
			<script language="javascript" src="../_js/mootools-1.2-core.js" type="text/javascript" />
			<script language="javascript" src="../_js/asdoc.js" type="text/javascript" />
			<style type="text/css">@import url(../_css/asdoc_toc.css);</style>
		</head>
		<body class="classFrameContent">
			<h3>Packages</h3>
			<ul class="packageList">
				<xsl:for-each select="asdoc/packages/asPackage[classes/asClass or methods/method or fields/field]">
					<xsl:sort select="@name"/>
					
					<xsl:variable name="isTopLevel">
						<xsl:call-template name="isTopLevel">
							<xsl:with-param name="packageName" select="@name"/>
						</xsl:call-template>
					</xsl:variable>
					<xsl:variable name="itemId" select="generate-id(@name)"/>
					<li id="{$itemId}">
						<xsl:if test="$isTopLevel='false'">
							<xsl:variable name="packagePath" select="translate(@name,'.','/')"/>
							<a href="#" onclick="toggleClassList('{$itemId}'); return false;" class="expandButton"></a>
							<span class="packageName"><xsl:value-of select="@name"/></span>
						</xsl:if>

						<ul class="classList">						
							<xsl:for-each select="classes/asClass">
								<xsl:sort select="@name"/>
								<xsl:variable name="classPath" select="translate(@packageName,'.','/')"/>
								<li>
									<xsl:choose>
										<xsl:when test="position() mod 2">
											<xsl:attribute name="class">even</xsl:attribute>
										</xsl:when>
										<xsl:otherwise>
											<xsl:attribute name="class">odd</xsl:attribute>
										</xsl:otherwise>
									</xsl:choose>
									<a href="{$classPath}/{@name}.html">
										<xsl:value-of select="@name"/>
									</a>
								</li>
							</xsl:for-each>
						</ul>
					</li>
				</xsl:for-each>
			</ul>
			<script type="text/javascript">
				<xsl:comment>
					<xsl:text>
						window.addEvent('domready', restorePackageTree);
					</xsl:text>
				</xsl:comment>
			</script>
		</body>
	</html>
</xsl:template>
	
</xsl:stylesheet>