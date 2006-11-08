<?xml version="1.0" encoding="ISO-8859-1"?>

<!-- $Id: xml2html.xsl 1 2006-07-12 15:37:55Z erant $

 Module  : xml2html.xsl
 Purpose : Transform the XML CCO version into HTML.
 Usage: xslproc xml2html.xsl test2.xml > main.html
 License : Copyright (c) 2006 Erick Antezana. All rights reserved.
           This program is free software; you can redistribute it and/or
           modify it under the same terms as Perl itself.
 Contact : Erick Antezana <erant@psb.ugent.be>

-->

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/">
  <html>
  <body>
    <h2>Entire list of all the terms from the Cell Cycle Ontology</h2>
    <b>Version:</b> 0.1 <br/>
    <b>Date:</b> <xsl:value-of select="./cco/header/date"/> <br/> <br/>
    
    <xsl:for-each select="cco/term">
    <xsl:sort select="id"/>
    <table border="1">
	
	<a>
	<xsl:attribute name="name">
	<xsl:value-of select="./name"/>
	</xsl:attribute>
	<!--xsl:value-of select="./name"/-->  
	</a>
	
	<a>
	<xsl:attribute name="name">
	<xsl:value-of select="./id"/>
	</xsl:attribute>
	<!--xsl:value-of select="./id"/-->  
	</a>
	
    <tr>
      <td><b>id:</b></td>
      <td colspan="3" width="100%"><xsl:value-of select="id"/></td>
    </tr>
    
    <tr>
      <td><b>name:</b></td>
      <td colspan="3"><xsl:value-of select="name"/></td>
    </tr>
    
    <xsl:if test="count(def) > 0">
    <tr>
      <td><b>definition:</b></td>
      <td colspan="3"><xsl:value-of select="def"/></td>
    </tr>
    </xsl:if>
    
    <xsl:if test="count(is_a) > 0">
    <tr>
      <td><b>is_a:</b></td>
      <td colspan="3">
        <a>
          <xsl:attribute name="href">
          <xsl:text>#</xsl:text>
	      <xsl:value-of select="is_a/@id"/>
   		  </xsl:attribute>
          <xsl:value-of select="is_a"/>
		</a>
      </td>
    </tr>
    </xsl:if>
    
    <xsl:if test="count(relationship/target) > 0">
    <tr>
      <td><b>relationship:</b></td>
      <td>
      <xsl:for-each select="relationship">
        <tr>
          <td><b>type:</b></td>
          <td><xsl:value-of select="type"/></td>
          <td><b>target:</b></td>
          <td>
            <a>
        	<xsl:attribute name="href">
        	<xsl:text>#</xsl:text>
	        <xsl:value-of select="target/@id"/>
   			</xsl:attribute>
            <xsl:value-of select="target"/>
			</a>
          </td>
        </tr>
      </xsl:for-each>
      </td>
    </tr>
    </xsl:if>
    
    <xsl:if test="count(synonym) > 0">
      <xsl:for-each select="synonym">
      <tr>
        <td><b>synonym:</b></td>
        <td><xsl:value-of select="."/></td>
        <td><b>scope:</b></td>
        <td><xsl:value-of select="@scope"/></td>
      </tr>
      </xsl:for-each>
    </xsl:if>
    
    </table>
    <br/>
	</xsl:for-each>
    
  </body>
  </html>
</xsl:template>

</xsl:stylesheet>