<?xml version="1.0" encoding="ISO-8859-1"?>

<!-- $Id: names.xsl 1847 2008-01-08 12:38:58Z easr $

 Module  : names.xsl
 Purpose : Get the term names from CCO (in XML) into HTML
 Usage: xsltproc names.xsl cco.xml > cco-names.html
 License : Copyright (c) 2006-2011 by Erick Antezana. All rights reserved.
           This program is free software; you can redistribute it and/or
           modify it under the same terms as Perl itself.
 Contact : Erick Antezana <erick.antezana -@- gmail.com>

-->

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/">
  <html>
  <body>
    <h2>Cell Cycle Ontology term names list</h2>
    
    <xsl:for-each select="cco/term">
      <xsl:sort select="name"/>
      "<xsl:value-of select="name"/>", <br/>
	</xsl:for-each>
    
  </body>
  </html>
</xsl:template>

</xsl:stylesheet>