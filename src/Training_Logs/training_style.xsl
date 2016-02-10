<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/">
  <html>
  <body>
    <p><b><xsl:value-of select="name(/*)"/></b></p>
    <table border="1">
      <tr bgcolor="#0099ff">
        <th style="text-align:left">Input</th>
        <th style="text-align:left">Output</th>
        <th style="text-align:left">Expected Output</th>
      </tr>
      <xsl:for-each select="//Pass">
      <tr>
        <td><xsl:value-of select="Input"/></td>
        <td><xsl:value-of select="Net_Output"/></td>
        <td><xsl:value-of select="Exp_Output"/></td>
      </tr>
      </xsl:for-each>
    </table>
  </body>
  </html>
</xsl:template>
</xsl:stylesheet>