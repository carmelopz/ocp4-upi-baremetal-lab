<?xml version="1.0" ?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dnsmasq="http://libvirt.org/schemas/network/dnsmasq/1.0">

     <!-- Identity template -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Override for target element -->
    <xsl:template match="network">
        <!-- Copy the element -->
        <xsl:copy>
            <!-- And everything inside it -->
            <xsl:apply-templates select="@* | node()"/>
            <!-- Additional dnsmasq options -->
            <dnsmasq:options>
                <dnsmasq:option value="address=/${ocp_wildcard_domain}/${ocp_ingress_lb}"/>
            </dnsmasq:options>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>