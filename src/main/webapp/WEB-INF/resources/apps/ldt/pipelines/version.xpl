<!--

    NAME     version.xpl
    VERSION  1.7.1-SNAPSHOT
    DATE     2016-06-03

    Copyright 2012-2016

    This file is part of the Linked Data Theatre.

    The Linked Data Theatre is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    The Linked Data Theatre is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with the Linked Data Theatre.  If not, see <http://www.gnu.org/licenses/>.

-->
<!--
    DESCRIPTION
    Debug option to show version information
	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline"
		  xmlns:xforms="http://www.w3.org/2002/xforms"
          xmlns:oxf="http://www.orbeon.com/oxf/processors"
		  xmlns:sparql="http://www.w3.org/2005/sparql-results#"
		  xmlns:ev="http://www.w3.org/2001/xml-events"
		  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		  xmlns:xs="http://www.w3.org/2001/XMLSchema">

	<!-- Configuration> -->
	<p:param type="input" name="instance"/>

	<!-- Version info -->
	<p:processor name="oxf:url-generator">
		<p:input name="config">
			<config>
				<url>../version.xml</url>
				<content-type>application/xml</content-type>
			</config>
		</p:input>
		<p:output name="data" id="version"/>
	</p:processor>

	<!-- Generate original request -->
	<p:processor name="oxf:request">
		<p:input name="config">
			<config stream-type="xs:anyURI">
				<include>/request/headers/header</include>
				<include>/request/request-url</include>
				<include>/request/parameters/parameter</include>
				<include>/request/remote-user</include>
				<include>/request/request-path</include>
			</config>
		</p:input>
		<p:output name="data" id="request"/>
	</p:processor>

	<!-- Get credentials and user roles -->
	<p:processor name="oxf:request-security">
		<p:input name="config" transform="oxf:xslt" href="#instance">        
			<config xsl:version="2.0">
				<xsl:for-each select="theatre/roles/role">
					<role><xsl:value-of select="."/></role>
				</xsl:for-each>
			</config>    
		</p:input>
		<p:output name="data" id="roles"/>
	</p:processor>
	
	<!-- Create context -->
	<p:processor name="oxf:xslt">
		<p:input name="data" href="aggregate('root',#instance,#request,#roles,#version)"/>
		<p:input name="config" href="../transformations/context.xsl"/>
		<p:output name="data" id="context"/>
	</p:processor>
	
	<p:choose href="#instance">
		<!-- Only show version information in development-mode -->
		<p:when test="theatre/@env='dev'">
			<p:processor name="oxf:xml-serializer">
				<p:input name="config">
					<config>
					</config>
				</p:input>
				<p:input name="data" href="#context"/>
			</p:processor>
		</p:when>
		<p:otherwise>
			<p:processor name="oxf:http-serializer">
				<p:input name="config">
					<config>
						<cache-control><use-local-cache>false</use-local-cache></cache-control>
						<status-code>404</status-code>
					</config>
				</p:input>
				<p:input name="data">
					<document xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string" content-type="text/plain"/>
				</p:input>
			</p:processor>
		</p:otherwise>
	</p:choose>
	
</p:config>
