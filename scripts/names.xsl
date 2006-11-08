<?xml version="1.0" encoding="ISO-8859-1"?>

<!-- $Id: names.xsl 1 2006-07-12 15:37:55Z erant $

 Module  : names.xsl
 Purpose : Transform the XML CCO version into HTML.
 Usage: xslproc names.xsl test2.xml > cco-names.html
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
    <h2>Cell Cycle Ontology names list</h2>
    
    <xsl:for-each select="cco/term">
      <xsl:sort select="name"/>
      "<xsl:value-of select="name"/>", <br/>
	</xsl:for-each>
    
  </body>
  </html>
</xsl:template>

</xsl:stylesheet>