<?xml version="1.0" encoding="utf-8"?>


<!--
/**
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements. See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
-->


<!--
* ====================================================================
* wsdl-viewer.xsl
* Version: 3.1.01
*
* URL: http://tomi.vanek.sk/xml/wsdl-viewer.xsl
*
* Author: tomi vanek
* Inspiration: Uche Ogbui - WSDL processing with XSLT
* 		http://www-106.ibm.com/developerworks/library/ws-trans/index.html
* ====================================================================
-->


<!--
* ====================================================================
* Description:
* 		wsdl-viewer.xsl is a lightweight XSLT 1.0 transformation with minimal
* 		usage of any hacks that extend the possibilities of the transformation
* 		over the XSLT 1.0 constraints but eventually would harm the engine independance.
*
* 		The transformation has to run even in the browser offered XSLT engines
* 		(tested in IE 6 and Firefox) and in ANT "batch" processing.
* ====================================================================
* How to add the HTML look to a WSDL:
* 		<?xml version="1.0" encoding="utf-8"?>
* 		<?xml-stylesheet type="text/xsl" href="wsdl-viewer.xsl"?>
* 		<wsdl:definitions ...>
* 		    ... Here is the service declaration
* 		</wsdl:definitions>
*
* 		The web-browsers (in Windows) are not able by default automatically recognize
* 		the ".wsdl" file type (suffix). For the type recognition the WSDL file has
* 		to be renamed by adding the suffix ".xml" - i.e. "myservice.wsdl.xml".
* ====================================================================
* Constraints:
* 	1. Processing of imported files
* 		1.1 Only 1 imported WSDL and 1 imported XSD is processed
* 			(well, maybe with a smarter recursive strategy this restriction could be overcome)
* 		1.2 No recursive including is supported (i.e. includes in included XSD are ignored)
* 	2. Namespace support
* 		2.1 Namespaces are not taken in account by processing (references with NS)
* 	3. Source code
* 		3.1 Only the source code allready processed by the XML parser is rendered - implications:
* 			== no access to the XML head line (<?xml version="1.0" encoding="utf-8"?>)
* 			== "expanded" CDATA blocks (parser processes the CDATA,
* 				XSLT does not have access to the original code)
* 			== no control over the code page
* 			== processing of special characters
* 			== namespace nodes are not rendered (just the namespace aliases)
* ====================================================================
* Possible improvements:
* 	* Functional requirements
* 		+ SOAP 1.2 binding (http://schemas.xmlsoap.org/wsdl/soap12/WSDL11SOAP12.pdf)
* 		+ WSDL 2.0 (http://www.w3.org/TR/2006/CR-wsdl20-primer-20060327/)
* 		+ Recognition of WSDL patterns (interface, binding, service instance, ...)
* 		- Creating an xsd-viewer.xsl for XML-Schema file viewing
* 			(extracting the functionality from wsdl-viewer into separate XSLT)
* 		- Check the full support of the WSDL and XSD going through the standards
* 		- Real-world WSDL testing
* 		- XSLT 2.0 (http://www-128.ibm.com/developerworks/library/x-xslt20pt5.html) ???
* 		? Adding more derived information
* 			* to be defined, what non-trivial information can we read out from the WSDL
* 	* XSLT
* 		+ Modularization
* 			- Is it meaningful?
* 			- Maybe more distribution alternatives (modular, fat monolithic, thin performance monolithic)?
* 			- Distribution build automatization
* 		+ Dynamic page: JavaSript
* 		+ Performance
* 		- Better code comments / documentation
* 		- SOAP client form - for testing the web service (AJAX based)
* 		- New XSD parser - clean-up the algorithm
* 		- Complete (recursive, multiple) include support
* 		? Namespace-aware version (no string processing hacks ;-)
* 			* I think, because of the goal to support as many engines as possible,
* 				this requirement is unrealistic. Maybe when XSLT 2.0 will be supported
* 				in a huge majority of platforms, we can rethink this point....
* 				(problems with different functionality of namespace-uri XPath function by different engines)
* 	* Development architecture
* 		- Setup of the development infrastructure
* 		- Unit testing
* 		? Collaboration platform
* 	* Documentation, web
* 		- Better user guide
* 		? Forum, Wiki
* ====================================================================
-->


<!--
* ====================================================================
* History:
* 	2005-04-15 - Initial implementation
* 	2005-09-12 - Removed xsl:key to be able to use the James Clark's XT engine on W3C web-site
* 	2006-10-06 - Removed the Oliver Becker's method of conditional selection
* 				of a value in a single expression (in Xalan/XSLTC this hack does not work!)
* 	2005-10-07 - Duplicated operations
* 	2006-12-08 - Import element support
* 	2006-12-14 - Displays all fault elements (not just the first one)
* 	2006-12-28 - W3C replaced silently the James Clark's XT engine with Michael Kay's closed-source Saxon!
* 				wsdl-viewer.xsl will no longer support XT engine
* 	2007-02-28 - Stack-overflow bug (if the XSD element @name and @type are identic)
* 	2007-03-08 - 3.0.00 - New parsing, new layout
* 	2007-03-28 - 3.0.01 - Fix: New anti-recursion defense (no error message by recursion
* 						because of dirty solution of namespace processing)
* 						- Added: variables at the top to turn on/off certain details
* 	2007-03-29 - 3.0.02 - Layout clean-up for IE
* 	2007-03-29 - 3.0.03 - Fix: Anti-recursion algorithm
* 	2007-03-30 - 3.0.04 - Added: source code rendering of imported WSDL and XSD
* 	2007-04-15 - 3.0.05 - Fix: Recursive calls in element type rendering
* 						- Fix: Rendering of messages (did not render the message types of complex types)
* 						- Fix: Links in src. by arrays
* 						- Fix: $binding-info
* 	2007-04-15 - 3.0.06 - Added: Extended rendering control ENABLE-xxx parameters
* 						- Changed: Anti-recursion algorithm has recursion-depth parameter
* 	2007-07-19 - 3.0.07 - Fix: Rendering of array type in detail
* 	2007-08-01 - 3.0.08 - Fix: xsl:template name="render-type"
* 						  Fix: typo - "Impotred WSDL" should be "Impotred WSDL"
* 	2007-08-16 - 3.0.09 - Fix: xsl:template name="render-type" - anti recursion
* 	2007-12-05 - 3.1.00 - Modularized
* 	2007-12-23 - 3.1.01 - Terminating message by WS without interface or service definition was removed
* 						  (seems to be a correct state)
* 	2008-08-20 - 3.1.02 - Woden-214: Anti-recursion bypassed in xsd:choice element
* ====================================================================
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:ws="http://schemas.xmlsoap.org/wsdl/" xmlns:ws2="http://www.w3.org/ns/wsdl" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/" xmlns:local="http://tomi.vanek.sk/xml/wsdl-viewer" version="1.0" exclude-result-prefixes="ws ws2 xsd soap local">

<xsl:output method="xml" version="1.0" encoding="utf-8" indent="no" omit-xml-declaration="no" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"/>

<xsl:strip-space elements="*"/>

<xsl:param name="wsdl-viewer.version">3.1.01</xsl:param>



<!--
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    Begin of included transformation: wsdl-viewer-global.xsl
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-->
<xsl:param name="ENABLE-SERVICE-PARAGRAPH" select="true()"/>
<xsl:param name="ENABLE-OPERATIONS-PARAGRAPH" select="true()"/>
<xsl:param name="ENABLE-SRC-CODE-PARAGRAPH" select="true()"/>
<xsl:param name="ENABLE-ABOUT-PARAGRAPH" select="true()"/>
<xsl:param name="ENABLE-OPERATIONS-TYPE" select="true()"/>
<xsl:param name="ENABLE-LINK" select="true()"/>
<xsl:param name="ENABLE-INOUTFAULT" select="true()"/>
<xsl:param name="ENABLE-STYLEOPTYPEPATH" select="true()"/>
<xsl:param name="ENABLE-DESCRIPTION" select="true()"/>
<xsl:param name="ENABLE-PORTTYPE-NAME" select="true()"/>
<xsl:param name="ENABLE-ANTIRECURSION-PROTECTION" select="true()"/>
<xsl:param name="ANTIRECURSION-DEPTH">3</xsl:param>
<xsl:variable name="GENERATED-BY">Generated by wsdl-viewer.xsl</xsl:variable>
<xsl:variable name="PORT-TYPE-TEXT">Port type</xsl:variable>
<xsl:variable name="IFACE-TEXT">Interface</xsl:variable>
<xsl:variable name="SOURCE-CODE-TEXT">Source code</xsl:variable>
<xsl:variable name="RECURSIVE"> ... is recursive</xsl:variable>
<xsl:variable name="SRC-PREFIX">src.</xsl:variable>
<xsl:variable name="SRC-FILE-PREFIX">src.file.</xsl:variable>
<xsl:variable name="OPERATIONS-PREFIX">op.</xsl:variable>
<xsl:variable name="PORT-PREFIX">port-</xsl:variable>
<xsl:variable name="IFACE-PREFIX">iface.</xsl:variable>
<xsl:variable name="PORT-CONTENT-PREFIX">port-cnt-</xsl:variable>
<xsl:variable name="PORT-TITLE-PREFIX">port-title-</xsl:variable>
<xsl:variable name="ANCHOR-PREFIX">a.</xsl:variable>
<xsl:variable name="global.wsdl-name" select="/*/*[(local-name() = 'import' or local-name() = 'include') and @location][1]/@location"/>
<xsl:variable name="consolidated-wsdl" select="/* | document($global.wsdl-name)/*"/>
<xsl:variable name="global.xsd-name" select="($consolidated-wsdl/*[local-name() = 'types']//xsd:import[@schemaLocation] | $consolidated-wsdl/*[local-name() = 'types']//xsd:include[@schemaLocation])[1]/@schemaLocation"/>
<xsl:variable name="consolidated-xsd" select="(document($global.xsd-name)/xsd:schema/xsd:*|/*/*[local-name() = 'types']/xsd:schema/xsd:*)[local-name() = 'complexType' or local-name() = 'element' or local-name() = 'simpleType']"/>
<xsl:variable name="global.service-name" select="concat($consolidated-wsdl/ws:service/@name, $consolidated-wsdl/ws2:service/@name)"/>
<xsl:variable name="global.binding-name" select="concat($consolidated-wsdl/ws:binding/@name, $consolidated-wsdl/ws2:binding/@name)"/>
<xsl:variable name="html-title">
	<xsl:apply-templates select="/*" mode="html-title.render"/>
</xsl:variable>

<!--
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    End of included transformation: wsdl-viewer-global.xsl
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-->



<!--
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    Begin of included transformation: wsdl-viewer-css.xsl
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-->
<xsl:variable name="css">

/**
	wsdl-viewer.css
*/

/**
=========================================
	Body
=========================================
*/
html {
	background-color: teal;
}

body {
	margin: 0;
	padding: 0;
	height: 100%;
	height: auto;
	color: black;
	background-color: teal;
	font: normal 80%/120% 'Open Sans', sans-serif;
}

#services {
    width: 450px;
    background-color: white;
    border: 1px solid navy;
    overflow: auto;
    position: fixed;
    font-family: 'Open Sans';
    color: #262626;
    top: 101px;
    bottom: 0px;
}

.porttitle {
    margin: 5px 10px 5px 10px;
    padding: 5px;
    font-size: 14pt;
    letter-spacing: 1px;
    cursor: pointer;

}

.porttitle .portbold { font-weight: bold; }

.portcontent {
	margin: 2px 0 2px 20px;
	width: 100%;
}
.portcontent .label {
    text-align: left;
}

.ports {
    margin: 20px 0 10px 10px;
    font-size: 16pt;
    letter-spacing: 1px;
    width: 30%;
    align: left;
    padding-bottom: 10px;
    border-bottom: 1px solid #262626;
    color: #262626;
    
}

.padder {
    padding: 7px;
    margin: 0;
}

/**
=========================================
	Fixed box with links
=========================================
*/
#outer_links { 
	position: fixed;
	left: 0px;
	top: 0px;
	margin: 3px;
	padding: 1px;
	z-index: 200; 
	width: 180px;
	height: auto;
	background-color: gainsboro;
	padding-top: 2px;
	border: 1px solid navy;
}

* html #outer_links /* Override above rule for IE */ 
{ 
	position: absolute; 
	width: 188px;
	top: expression(offsetParent.scrollTop + 0); 
} 

#links {
	margin: 1px;
	padding: 3px;
	background-color: white;
	height: 350px;
	overflow: auto;
	border: 1px solid navy;
}

#links ul {
	left: -999em;
	list-style: none;
	margin: 0;
	padding: 0;
	z-index: 100;
}

#links li {
	margin: 0;
	padding: 2px 4px;
	width: auto;
	z-index: 100;
}

#links ul li {
	margin: 0;
	padding: 2px 4px;
	width: auto;
	z-index: 100;
}

#links a {
	display: block;
	padding: 0 2px;
	color: blue;
	width: auto;
	border: 1px solid white;
	text-decoration: none;
	white-space: nowrap;
}

#links a:hover {
	color: white;
	background-color: gray;
	border: 1px solid gray;
} 


/**
=========================================
	Content
=========================================
*/
#header {
    font-family: 'Open Sans';
    padding: 0;
	color: black;
	background-image: url(data:image/png;charset=utf-8;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAIAAAADnC86AAAAvElEQVRYhcXWuw6DMBQDUNOJkYn//72ytBts6YKEQIHkPux6t468eXh/VngzT6O7+/qLunw3JxxU4VscVz1wimqGs1QbnKga4Fy1F05Xu2CG2oZJagPmqU8wVb2F2WodFqgVWKNeYZl6gpXqAYvVHdarAIZSil5F5HNF1HkanXBQhW9xXPXAKaoZzlJtcKJqgHPVXjhd7YIZahsmqQ2Ypz7BVPUWZqt1WKBWYI16hWXqCVaqByxWd1ivAvgB8Ed7G+ZZfiYAAAAASUVORK5CYII=);
	background-size: 8px auto;
	background-color: white;
	background-repeat: repeat;
	border: 1px solid #262626;
	height: 100px;
	position: fixed;
    left: 0px;
    right: 0px;
}

#header #headertitle {
    float: left;
    font-size: 23pt;
    letter-spacing: 2px;
    height: 100%;
    padding-top: 65px;
    padding-left: 10px;
    vertical-align: bottom;
}

#header #namespace {
    height: 100%;
    font-size: 12pt;
    float: right;
    margin-right: 1em;
    text-align: right;
    padding-top: 70px;
}

#content {
	padding: 101px 20px 0 470px;
	background-color: white;
}

#content .anchor {
    display: block;
    height: 105px;
    margin-top: -105px;
    visibility: hidden;
}

#operations_title {
    font-family: 'Open Sans';
    width: 97%;
    padding-bottom: 10px;
    margin-top: 20px;
    margin-bottom: 20px;
    margin-left: 20px;
    font-size: 16pt;
    color: #262626;
    border-bottom: 1px solid #262626;
}

.operation_title {
    font-family: 'Open Sans';
    font-size: 12pt;
    margin-bottom: 10px;
    margin-top: 10px;
    padding-bottom: 10px;
}

.messageparts {
    list-style: disc; 
}

#footer {
	clear: both;
	margin: 0;
	padding: .5em 2em;
	color: gray;
	background-color: gainsboro;
	font-size: 80%;
	border-top: 1px dotted gray;
	text-align: right
}

.single_column {
	padding: 10px 10px 10px 10px;
	/*margin: 0px 33% 0px 0px; */
	margin: 3px 0;
}

#flexi_column {
	padding: 10px 10px 10px 10px;
	/*margin: 0px 33% 0px 0px; */
	margin: 0px 212px 0px 0px;
}

#fix_column {
	float: right;
	padding: 10px 10px 10px 10px;
	margin: 0px;
	width: 205px;
	/*width: 30%; */
	voice-family: "\"}\"";
	voice-family:inherit;
	/* width: 30%; */
	width: 205px;
}
html&gt;body #rightColumn {
	width: 205px; /* ie5win fudge ends */
} /* Opera5.02 shows a 2px gap between. N6.01Win sometimes does.
	Depends on amount of fill and window size and wind direction. */

/**
=========================================
	Label / value
=========================================
*/

.page {
	margin: 0 20px 0 0;
	padding: 10px 0 20px 0;
}

.value, .label {
	margin: 0;
	padding: 0;
}

.label {
    float: left;
	width: 145px;
	text-align: right;
	font-weight: bold;
	padding-bottom: .5em;
	margin-right: 0;
	color: darkblue;
}

.label a {
    margin-left: 0;
    float: left;
}


.description_label {
    margin: 20px 0 10px 10px;
    padding-bottom: 10px;
    border-bottom: 1px solid;
    width: 30%;
	font-size: 16pt;
	letter-spacing: 1px;
	color: #262626;
}

.description_value {
    margin-left: 10px;
    padding-bottom: .5em;    
    padding-top: 5px;
    padding-bottom: 2em;
    font-size: 11pt;
    line-height: 14pt;
}

.operations_label {
    font-weight: bold;
    letter-spacing: 1px;
    text-align: left;
    color: darkblue;
}


.value {
	margin-left: 147px;
	color: darkblue;
	padding-bottom: .5em;
	word-wrap: break-word;
}

.operations_list {
    color: darkblue;
}

strong, strong a {
	color: darkblue;
	font-weight: bold;
	letter-spacing: 1px;
	margin-left: 2px;
}


/**
=========================================
	Links
=========================================
*/

a.local:link,
a.local:visited {
	color: blue; 
	margin-left: 0;
	border-bottom: 1px dotted blue;
	text-decoration: none;
	font-style: italic;
}

a.local:hover {
	background-color: gainsboro; 
	color: darkblue;
	padding-bottom: 1px;
	border-bottom: 1px solid darkblue;
}

a.target:link,
a.target:visited,
a.target:hover
{
	text-decoration: none;
	background-color: transparent;
	border-bottom-type: none;
}

/**
=========================================
	Box, Shadow
=========================================
*/

.box {
	padding: 14px;
	margin-bottom: 26px;
	margin-top: 6px;
	line-height: 1.5em;
	color: black;
	background-color: #e9eff7;
	border: 1px dotted gray;
}

.shadow {
	background: silver;
	position: relative;
	top: 5px;
	left: 4px;
}

.shadow div {
	position: relative;
	top: -5px;
	left: -4px;
}

/**
=========================================
	Floatcontainer
=========================================
*/

.spacer
{
	display: block;
	height: 0;
	font-size: 0;
	line-height: 0;
	margin: 0;
	padding: 0;
	border-style: none;
	clear: both; 
	visibility:hidden;
}

.floatcontainer:after {
	content: ".";
	display: block;
	height: 0;
	font-size:0; 
	clear: both;
	visibility:hidden;
}
.floatcontainer{
	display: inline-table;
} /* Mark Hadley's fix for IE Mac */ /* Hides from IE Mac \*/ * 
html .floatcontainer {
	height: 1%;
}
.floatcontainer{
	display:block;
} /* End Hack 
*/ 

/**
=========================================
	Source code
=========================================
*/

.xml-element, .xml-proc, .xml-comment {
	margin: 2px 0;
	padding: 2px 0 2px 0;
}

.xml-element {
	word-spacing: 3px;
	color: #cf3030;
	font-weight: bold;
	font-style:normal;
	border-left: 1px dotted silver;
}

.xml-element div {
	margin: 2px 0 2px 20px;
}

.xml-att {
	color: blue;
	font-weight: bold;
}

.xml-att-val {
	color: blue;
	font-weight: normal;
}

.xml-proc {
	color: darkred;
	font-weight: normal;
//	font-style: italic;
}

.xml-comment {
	color: green;
	font-weight: normal;
//	font-style: italic;
}

.xml-text {
	color: green;
	font-weight: normal;
	font-style: normal;
}


/**
=========================================
	Heading
=========================================
*/
h1, h2, h3 {
	margin: 10px 10px 2px;
	font-family: 'Open Sans', Georgia, Times New Roman, Times, Serif;
	font-weight: normal;
	}

h1 {
	font-weight: bold;
	letter-spacing: 3px;
	font-size: 220%;
	line-height: 100%;
}

h2 {
	font-weight: bold;
	font-size: 175%;
	line-height: 200%;
}

h3 {
	font-size: 150%;
	line-height: 150%;
//	font-style: italic;
}

/**
=========================================
	Content formatting
=========================================
*/
.port {
	margin-bottom: 10px;
	padding-bottom: 10px;
	border-bottom: 1px dashed gray;
}

.operation {
	margin-bottom: 20px;
	padding-bottom: 10px;
	border-bottom: 1px dashed gray;
}


/* --------------------------------------------------------
	Printing
*/

/*
@media print
{
	#outer_links, #outer_nav { 
		display: none;
	}
*/

	#outer_box {
		padding: 3px;
	}
/* END print media definition
}
*/

/**
=========================================
	Fonts
=========================================
*/

@font-face {
    font-family: 'Open Sans';
    font-style: normal;
    font-weight: 300;
    src: local('Open Sans Light'), local('OpenSans-Light'), url(http://themes.googleusercontent.com/static/fonts/opensans/v6/DXI1ORHCpsQm3Vp6mXoaTYnF5uFdDttMLvmWuJdhhgs.ttf) format('truetype');
}

@font-face {
    font-family: 'Open Sans';
    font-style: bold;
    font-weight: 600;
    src: local('Open Sans Semibold'), local('OpenSans-Semibold'), url(http://themes.googleusercontent.com/static/fonts/opensans/v6/MTP_ySUJH_bn48VBG8sNSonF5uFdDttMLvmWuJdhhgs.ttf) format('truetype');
}
 
@font-face {
    font-family: 'Open Sans';
    font-style: italic;
    font-weight: 300;
    src: local('Open Sans Light Italic'), local('OpenSansLight-Italic'), url(http://themes.googleusercontent.com/static/fonts/opensans/v6/PRmiXeptR36kaC0GEAetxrfB31yxOzP-czbf6AAKCVo.ttf) format('truetype');
} 


</xsl:variable>

<!--
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    End of included transformation: wsdl-viewer-css.xsl
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-->



<!--
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    Begin of included transformation: wsdl-viewer-js.xsl
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-->
<xsl:variable name="js">

function collapse(element) {
    element.attr('class', 'collapsed');
    element.children('path').attr('d', "M0,16V0l8,8L0,16z");
}

function expand(element) {
    element.attr('class', 'expanded');
    element.children('path').attr('d', "M0,8h16l-8,8L0,8z");
    
}

$(document).ready(function() {
    $(".porttitle").click(function() {
        var portid = "#port-" + $(this).attr('id').match(/(\w+)$/gm);
        var svg = $(this).children('svg').first();
        console.log(svg);
        if (svg.is(".expanded")) {
            collapse(svg);
        } else {
            expand(svg);
        }
        $(this).next(".portcontent").slideToggle(100);
        $(portid).slideToggle(100);
    });
});

</xsl:variable>

<!--
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    End of included transformation: wsdl-viewer-js.xsl
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-->



<!--
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    Begin of included transformation: wsdl-viewer-util.xsl
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-->
<xsl:template match="@*" mode="qname.normalized">
	<xsl:variable name="local" select="substring-after(., ':')"/>
	<xsl:choose>
		<xsl:when test="$local">
<xsl:value-of select="$local"/>
</xsl:when>
		<xsl:otherwise>
<xsl:value-of select="."/>
</xsl:otherwise>
	</xsl:choose>
</xsl:template>
<xsl:template match="ws:definitions | ws2:description" mode="html-title.render">
	<xsl:choose>
		<xsl:when test="$global.service-name">
<xsl:value-of select="concat('Web Service: ', $global.service-name)"/>
</xsl:when>
		<xsl:when test="$global.binding-name">
<xsl:value-of select="concat('WS Binding: ', $global.binding-name)"/>
</xsl:when>
		<xsl:when test="ws2:interface/@name">
<xsl:value-of select="concat('WS Interface: ', ws2:interface/@name)"/>
</xsl:when>
		<xsl:otherwise>Web Service Fragment</xsl:otherwise>
<!--		<xsl:otherwise><xsl:message terminate="yes">Syntax error in element <xsl:call-template name="src.syntax-error.path"/></xsl:message>
		</xsl:otherwise>
-->
	</xsl:choose>
</xsl:template>
<xsl:template name="src.syntax-error">
	<xsl:message terminate="yes">Syntax error by WSDL source rendering in element <xsl:call-template name="src.syntax-error.path"/>
</xsl:message>
</xsl:template>
<xsl:template name="src.syntax-error.path">
	<xsl:for-each select="parent::*">
<xsl:call-template name="src.syntax-error.path"/>
</xsl:for-each>
	<xsl:value-of select="concat('/', name(), '[', position(), ']')"/>
</xsl:template>
<xsl:template match="*[local-name(.) = 'documentation']" mode="documentation.render">
	<xsl:if test="$ENABLE-DESCRIPTION and string-length(.) &gt; 0">
		<div class="description_label">Description:</div>
		<div class="description_value">
<xsl:value-of select="." disable-output-escaping="yes"/>
</div>
	</xsl:if>
</xsl:template>
<xsl:template name="render.source-code-link">
	<xsl:if test="$ENABLE-SRC-CODE-PARAGRAPH and $ENABLE-LINK">
		<a class="local" href="{concat('#', $SRC-PREFIX, generate-id(.))}">
<xsl:value-of select="$SOURCE-CODE-TEXT"/>
</a>
	</xsl:if>
</xsl:template>
<xsl:template name="about.detail">
<xsl:param name="version"/>
<div>
	This page has been generated by <big>wsdl-viewer.xsl</big>, version <xsl:value-of select="$version"/>
<br/>
	Author: <a href="http://tomi.vanek.sk/">tomi vanek</a>
<br/>
	Download at <a href="http://tomi.vanek.sk/xml/wsdl-viewer.xsl">http://tomi.vanek.sk/xml/wsdl-viewer.xsl</a>.<br/>
	<br/>
	The transformation was inspired by the article<br/>
	Uche Ogbuji: <a href="http://www-106.ibm.com/developerworks/library/ws-trans/index.html">WSDL processing with XSLT</a>
<br/>
</div>
</xsl:template>
<xsl:template name="processor-info.render">
<xsl:text>
</xsl:text>
<xsl:text>This document was generated by </xsl:text>
<a href="{system-property('xsl:vendor-url')}">
<xsl:value-of select="system-property('xsl:vendor')"/>
</a>
<xsl:text> XSLT engine.
</xsl:text>

<xsl:text>The engine processed the WSDL in XSLT </xsl:text>
<xsl:value-of select="format-number(system-property('xsl:version'), '#.0')"/>
<xsl:text> compliant mode.
</xsl:text>

</xsl:template>

<!--
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    End of included transformation: wsdl-viewer-util.xsl
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-->



<!--
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    Begin of included transformation: wsdl-viewer-service.xsl
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-->
<xsl:template match="ws:service|ws2:service" mode="service-start">
    <xsl:apply-templates select="*[local-name(.) = 'documentation']" mode="documentation.render"/>
    <xsl:if test="ws:port">
<div class="ports">Ports:</div>
</xsl:if>
    <xsl:if test="ws2:endpoint">
<div class="ports">Interfaces:</div>
</xsl:if>
	<xsl:apply-templates select="ws:port|ws2:endpoint" mode="service"/>
</xsl:template>
<xsl:template match="ws2:endpoint" mode="service">
	<xsl:variable name="binding-name">
		<xsl:apply-templates select="@binding" mode="qname.normalized"/>
	</xsl:variable>
	<xsl:variable name="binding" select="$consolidated-wsdl/ws2:binding[@name = $binding-name]"/>

	<xsl:variable name="binding-type" select="$binding/@type"/>
	<xsl:variable name="binding-protocol" select="$binding/@*[local-name() = 'protocol']"/>
	<xsl:variable name="protocol">
		<xsl:choose>
			<xsl:when test="starts-with($binding-type, 'http://schemas.xmlsoap.org/wsdl/soap')">SOAP 1.1</xsl:when>
			<xsl:when test="starts-with($binding-type, 'http://www.w3.org/2005/08/wsdl/soap')">SOAP 1.2</xsl:when>
			<xsl:when test="starts-with($binding-type, 'http://www.w3.org/2007/06/wsdl/soap')">SOAP 1.2</xsl:when>
			<xsl:when test="starts-with($binding-type, 'http://www.w3.org/ns/wsdl/soap')">SOAP</xsl:when>
			<xsl:when test="starts-with($binding-type, 'http://schemas.xmlsoap.org/wsdl/mime')">MIME</xsl:when>
			<xsl:when test="starts-with($binding-type, 'http://schemas.xmlsoap.org/wsdl/http')">HTTP</xsl:when>
			<xsl:otherwise>Unknown</xsl:otherwise>
		</xsl:choose>

		<!-- TODO: Add all bindings to transport protocols -->
		<xsl:choose>
			<xsl:when test="starts-with($binding-protocol, 'http://www.w3.org/2003/05/soap/bindings/HTTP')"> over HTTP</xsl:when>
			<xsl:otherwise/>
		</xsl:choose>
	</xsl:variable>
	<div class="portcontent">
        <div class="label">Location:</div>
        <div class="value">
<xsl:value-of select="@address"/>
</div>

        <div class="label">Protocol:</div>
        <div class="value">
<xsl:value-of select="$protocol"/>
</div>
    </div>
	<xsl:apply-templates select="$binding" mode="service"/>

	<xsl:variable name="iface-name">
		<xsl:apply-templates select="../@interface" mode="qname.normalized"/>
	</xsl:variable>
	<xsl:apply-templates select="$consolidated-wsdl/ws2:interface[@name = $iface-name]" mode="service"/>

</xsl:template>
<xsl:template match="ws2:interface" mode="service">

	<div class="porttitle">Interface: <span class="portbold">
<xsl:value-of select="@name"/>
</span>
</div>
	<xsl:variable name="base-iface-name">
		<xsl:apply-templates select="@extends" mode="qname.normalized"/>
	</xsl:variable>
    <div class="portcontent">
        <xsl:if test="$ENABLE-LINK">
            <div class="label">Source Code: </div>
            <div class="value">
<xsl:call-template name="render.source-code-link"/>
</div>
        </xsl:if>
        <xsl:if test="$base-iface-name and $base-iface-name != ''">
	        <div class="label">Extends: </div>
	        <div class="value">
<xsl:value-of select="$base-iface-name"/>
</div>
        </xsl:if>

        <xsl:variable name="base-iface" select="$consolidated-wsdl/ws2:interface[@name = $base-iface-name]"/>
	    <div class="label">Operations:</div>
	    <div class="value">
<br/>
</div>
        <div class="operations_list">
<xsl:text>   </xsl:text>
		    <ol style="line-height: 180%;">
			    <xsl:apply-templates select="$base-iface/ws2:operation | ws2:operation" mode="service">
				    <xsl:sort select="@name"/>
			    </xsl:apply-templates>
		    </ol>
	    </div>
    </div>
</xsl:template>
<xsl:template match="ws:port" mode="service">

<xsl:variable name="collapsed-img">

&lt;svg class="collapsed" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"
	 width="16px" height="16px" viewBox="0 0 16 16" enable-background="new 0 0 16 16" xml:space="preserve"&gt;
&lt;path fill-rule="evenodd" clip-rule="evenodd" fill="#6ECFF5" d="M0,16V0l8,8L0,16z"/&gt;
&lt;/svg&gt;

</xsl:variable>

<xsl:variable name="expanded-img">

&lt;svg class="expanded" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"
	 width="16px" height="16px" viewBox="0 0 16 16" enable-background="new 0 0 16 16" xml:space="preserve"&gt;
&lt;path fill-rule="evenodd" clip-rule="evenodd" fill="#6ECFF5" d="M0,8h16l-8,8L0,8z"/&gt;
&lt;/svg&gt;

</xsl:variable>

	<xsl:variable name="binding-name">
		<xsl:apply-templates select="@binding" mode="qname.normalized"/>
	</xsl:variable>
	<xsl:variable name="binding" select="$consolidated-wsdl/ws:binding[@name = $binding-name]"/>

	<xsl:variable name="binding-uri" select="namespace-uri( $binding/*[local-name() = 'binding'] )"/>
	<xsl:variable name="protocol">
		<xsl:choose>
			<xsl:when test="starts-with($binding-uri, 'http://schemas.xmlsoap.org/wsdl/soap')">SOAP</xsl:when>
			<xsl:when test="starts-with($binding-uri, 'http://schemas.xmlsoap.org/wsdl/mime')">MIME</xsl:when>
			<xsl:when test="starts-with($binding-uri, 'http://schemas.xmlsoap.org/wsdl/http')">HTTP</xsl:when>
			<xsl:otherwise>unknown</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="port-type-name">
		<xsl:apply-templates select="$binding/@type" mode="qname.normalized"/>
	</xsl:variable>
	<xsl:variable name="port-type" select="$consolidated-wsdl/ws:portType[@name = $port-type-name]"/>
    <div class="porttitle" id="{concat($PORT-TITLE-PREFIX, generate-id($port-type))}">
    <xsl:if test="position() != 1">
<xsl:value-of select="$collapsed-img" disable-output-escaping="yes"/>
</xsl:if>
    <xsl:if test="position() = 1">
<xsl:value-of select="$expanded-img" disable-output-escaping="yes"/>
</xsl:if>
    Port: <span class="portbold">
<xsl:value-of select="@name"/>
</span>
</div>
    <div class="portcontent" id="{concat($PORT-CONTENT-PREFIX, generate-id($port-type))}">

        <xsl:if test="position() != 1">
<xsl:attribute name="style">display: none;</xsl:attribute>
</xsl:if>

        <xsl:if test="$ENABLE-LINK">
        <div class="label">Source code:</div>
        <div class="value">
<xsl:call-template name="render.source-code-link"/>
</div>
        </xsl:if>
	    <div class="label">Location:</div>
	    <div class="value">
<xsl:value-of select="*[local-name() = 'address']/@location"/>
</div>

	    <div class="label">Protocol:</div>
	    <div class="value">
<xsl:value-of select="$protocol"/>
</div>

	    <xsl:apply-templates select="$binding" mode="service"/>

	    <div class="label">Operations:</div>
	    <div class="value">
<br/>
</div>
	    <div class="operations_list">
<xsl:text>    </xsl:text>
		    <ol style="line-height: 180%;">
			    <xsl:apply-templates select="$consolidated-wsdl/ws:portType[@name = $port-type-name]/ws:operation" mode="service">
				    <xsl:sort select="@name"/>
			    </xsl:apply-templates>
		    </ol>
	    </div>
    </div>
</xsl:template>
<xsl:template match="ws:operation|ws2:operation" mode="service">
	<li>
<big>
<xsl:value-of select="@name"/>
</big>
<xsl:if test="$ENABLE-LINK">
		<xsl:if test="$ENABLE-OPERATIONS-PARAGRAPH">
<span class="padder"/>
<a class="local" href="{concat('#', $OPERATIONS-PREFIX, generate-id(.))}">Detail</a>
</xsl:if>
<span class="padder"/>
<xsl:call-template name="render.source-code-link"/>
</xsl:if>
	</li>
</xsl:template>
<xsl:template match="ws:binding|ws2:binding" mode="service">
	<xsl:variable name="real-binding" select="*[local-name() = 'binding']|self::ws2:*"/>

	<xsl:if test="$real-binding/@style">
		<div class="label">Default style:</div>
		<div class="value">
<xsl:value-of select="$real-binding/@style"/>
</div>
	</xsl:if>


	<xsl:if test="$real-binding/@transport|$real-binding/*[local-name() = 'protocol']">
		<xsl:variable name="protocol" select="concat($real-binding/@transport, $real-binding/*[local-name() = 'protocol'])"/>
		<div class="label">Transport protocol:</div>
		<div class="value">
			<xsl:choose>
				<xsl:when test="$protocol = 'http://schemas.xmlsoap.org/soap/http'">SOAP over HTTP</xsl:when>
				<xsl:otherwise>
<xsl:value-of select="$protocol"/>
</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:if>

	<xsl:if test="$real-binding/@verb">
		<div class="label">Default method:</div>
		<div class="value">
<xsl:value-of select="$real-binding/@verb"/>
</div>
	</xsl:if>
</xsl:template>

<!--
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    End of included transformation: wsdl-viewer-service.xsl
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-->



<!--
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    Begin of included transformation: wsdl-viewer-operations.xsl
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-->
<xsl:template match="ws2:interface" mode="operations">
	<xsl:if test="$ENABLE-PORTTYPE-NAME">
	<h3>
	    <span class="anchor" id="{concat($IFACE-PREFIX, generate-id(.))}"/>
		<xsl:value-of select="$IFACE-TEXT"/>
<xsl:text> </xsl:text>
		<b>
<xsl:value-of select="@name"/>
</b>
<span class="padder"/>
<xsl:call-template name="render.source-code-link"/>
	</h3>
	</xsl:if>

	<ol>
		<xsl:apply-templates select="ws2:operation" mode="operations">
			<xsl:sort select="@name"/>
		</xsl:apply-templates>
	</ol>
</xsl:template>
<xsl:template match="ws2:operation" mode="operations">
	<xsl:variable name="binding-info" select="$consolidated-wsdl/ws2:binding[@interface = current()/../@name or substring-after(@interface, ':') = current()/../@name]/ws2:operation[@ref = current()/@name or substring-after(@ref, ':') = current()/@name]"/>
<li>
<xsl:if test="position() != last()">
<xsl:attribute name="class">operation</xsl:attribute>
</xsl:if>
<span class="anchor" name="{concat($OPERATIONS-PREFIX, generate-id(.))}"/>

    <div class="operation_title">
<xsl:value-of select="@name"/>
</div>
	<div class="value">
<xsl:call-template name="render.source-code-link"/>
</div>
	<xsl:apply-templates select="ws2:documentation" mode="documentation.render"/>

	<xsl:if test="$ENABLE-STYLEOPTYPEPATH">
		<!-- TODO: add the operation attributes - according the WSDL 2.0 spec. -->
	</xsl:if>
	<xsl:apply-templates select="ws2:input|ws2:output|../ws2:fault[@name = ws2:infault/@ref or @name = ws2:outfault/@ref]" mode="operations.message">
		<xsl:with-param name="binding-data" select="$binding-info"/>
	</xsl:apply-templates>
</li>
</xsl:template>
<xsl:template match="ws2:input|ws2:output|ws2:fault" mode="operations.message">
	<xsl:param name="binding-data"/>
	<xsl:if test="$ENABLE-INOUTFAULT">
		<div class="label">
<xsl:value-of select="concat(translate(substring(local-name(.), 1, 1), 'abcdefghijklmnoprstuvwxyz', 'ABCDEFGHIJKLMNOPRSTUVWXYZ'), substring(local-name(.), 2), ':')"/>
</div>

		<div class="value">
			<xsl:variable name="type-name">
				<xsl:apply-templates select="@element" mode="qname.normalized"/>
			</xsl:variable>
	
			<xsl:call-template name="render-type">
				<xsl:with-param name="type-local-name" select="$type-name"/>
			</xsl:call-template>

			<xsl:call-template name="render.source-code-link"/>

			<xsl:variable name="type-tree" select="$consolidated-xsd[@name = $type-name and not(xsd:simpleType)][1]"/>
			<xsl:apply-templates select="$type-tree" mode="operations.message.part"/>
		</div>
	</xsl:if>
</xsl:template>
<xsl:template match="ws:portType" mode="operations">
<div>
<!--<xsl:if test="position() != last()">-->
    <xsl:attribute name="class">port</xsl:attribute>
    <xsl:attribute name="id">
<xsl:value-of select="concat($PORT-PREFIX, generate-id(.))"/>
</xsl:attribute>
    <xsl:if test="position() != last()">
<xsl:attribute name="style">display: none;</xsl:attribute>
</xsl:if>
<!--</xsl:if>-->
<xsl:if test="$ENABLE-PORTTYPE-NAME">
<span class="anchor" id="{concat($ANCHOR-PREFIX, generate-id(.))}"/>
<h3>
	<xsl:value-of select="$PORT-TYPE-TEXT"/>
	<xsl:text>: </xsl:text>
<b> <xsl:value-of select="@name"/> </b>
	<span class="padder"/>
<xsl:call-template name="render.source-code-link"/>
</h3>
</xsl:if>
<ol>
<xsl:apply-templates select="ws:operation" mode="operations">
	<xsl:sort select="@name"/>
</xsl:apply-templates>
</ol>
</div>
</xsl:template>
<xsl:template match="ws:operation" mode="operations">
	<xsl:variable name="binding-info" select="$consolidated-wsdl/ws:binding[@type = current()/../@name or substring-after(@type, ':') = current()/../@name]/ws:operation[@name = current()/@name]"/>
<li>
<xsl:if test="position() != last()">
<xsl:attribute name="class">operation</xsl:attribute>
</xsl:if>
<span class="anchor" id="{concat($OPERATIONS-PREFIX, generate-id(.))}"/>
<div class="operation_title">
<xsl:value-of select="@name"/>
</div>
	<div class="value">
<xsl:text>
</xsl:text>
<xsl:call-template name="render.source-code-link"/>
</div>

	<xsl:if test="$ENABLE-DESCRIPTION and string-length(ws:documentation) &gt; 0">
		<div class="label">Description:</div>
		<div class="value">
<xsl:value-of select="ws:documentation" disable-output-escaping="yes"/>
</div>
	</xsl:if>

	<xsl:if test="$ENABLE-STYLEOPTYPEPATH">
		<xsl:variable name="binding-operation" select="$binding-info/*[local-name() = 'operation']"/>
		<xsl:if test="$binding-operation/@style">
			<div class="label">Style:</div>
			<div class="value">
<xsl:value-of select="$binding-operation/@style"/>
</div>
		</xsl:if>
	
		<div class="label">Operation type:</div>
		<div class="value">
		<xsl:choose>
			<xsl:when test="$binding-info/ws:input[not(../ws:output)]">One-way. The endpoint receives a message.</xsl:when>
			<xsl:when test="$binding-info/ws:input[following-sibling::ws:output]">Request-response. The endpoint receives a message, and sends a correlated message.</xsl:when>
			<xsl:when test="$binding-info/ws:input[preceding-sibling::ws:output]">Solicit-response. The endpoint sends a message, and receives a correlated message.</xsl:when>
			<xsl:when test="$binding-info/ws:output[not(../ws:input)]">Notification. The endpoint sends a message.</xsl:when>
			<xsl:otherwise>unknown</xsl:otherwise>
		</xsl:choose>
		</div>
	
		<xsl:if test="string-length($binding-operation/@soapAction) &gt; 0">
			<div class="label">SOAP action:</div>
			<div class="value">
<xsl:value-of select="$binding-operation/@soapAction"/>
</div>
		</xsl:if>
	
		<xsl:if test="$binding-operation/@location">
			<div class="label">HTTP path:</div>
			<div class="value">
<xsl:value-of select="$binding-operation/@location"/>
</div>
		</xsl:if>
	</xsl:if>
	<xsl:apply-templates select="ws:input|ws:output|ws:fault" mode="operations.message">
		<xsl:with-param name="binding-data" select="$binding-info"/>
	</xsl:apply-templates>
</li>
</xsl:template>
<xsl:template match="ws:input|ws:output|ws:fault" mode="operations.message">
	<xsl:param name="binding-data"/>
	<xsl:if test="$ENABLE-INOUTFAULT">
		<div class="label">
<xsl:value-of select="concat(translate(substring(local-name(.), 1, 1), 'abcdefghijklmnoprstuvwxyz', 'ABCDEFGHIJKLMNOPRSTUVWXYZ'), substring(local-name(.), 2), ':')"/>
</div>
	
		<xsl:variable name="msg-local-name" select="substring-after(@message, ':')"/>
		<xsl:variable name="msg-name">
			<xsl:choose>
				<xsl:when test="$msg-local-name">
<xsl:value-of select="$msg-local-name"/>
</xsl:when>
				<xsl:otherwise>
<xsl:value-of select="@message"/>
</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
	
		<xsl:variable name="msg" select="$consolidated-wsdl/ws:message[@name = $msg-name]"/>
		<xsl:choose>
			<xsl:when test="$msg">
				<xsl:apply-templates select="$msg" mode="operations.message">
					<xsl:with-param name="binding-data" select="$binding-data/ws:*[local-name(.) = local-name(current())]/*"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
<div class="value">none</div>
</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
</xsl:template>
<xsl:template match="ws:message" mode="operations.message">
	<xsl:param name="binding-data"/>
	<div class="value">
		<xsl:value-of select="@name"/>
		<xsl:if test="$binding-data">
			<xsl:text> (</xsl:text>
			<xsl:value-of select="name($binding-data)"/>
			<xsl:variable name="use" select="$binding-data/@use"/>
			<xsl:if test="$use">
<xsl:text>, use = </xsl:text>
<xsl:value-of select="$use"/>
</xsl:if>
			<xsl:variable name="part" select="$binding-data/@part"/>
			<xsl:if test="$part">
<xsl:text>, part = </xsl:text>
<xsl:value-of select="$part"/>
</xsl:if>
			<xsl:text>)</xsl:text>
		</xsl:if>
		<span class="padder"/>
<xsl:call-template name="render.source-code-link"/>
	</div>

	<xsl:apply-templates select="ws:part" mode="operations.message"/>
</xsl:template>
<xsl:template match="ws:part" mode="operations.message">
	<div class="value box">
		<xsl:choose>
			<xsl:when test="string-length(@name) &gt; 0">
				<b>
<xsl:value-of select="@name"/>
</b>

				<xsl:variable name="elem-or-type">
					<xsl:choose>
						<xsl:when test="@type">
<xsl:value-of select="@type"/>
</xsl:when>
						<xsl:otherwise>
<xsl:value-of select="@element"/>
</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:variable name="type-local-name" select="substring-after($elem-or-type, ':')"/>
				<xsl:variable name="type-name">
					<xsl:choose>
						<xsl:when test="$type-local-name">
<xsl:value-of select="$type-local-name"/>
</xsl:when>
						<xsl:when test="$elem-or-type">
<xsl:value-of select="$elem-or-type"/>
</xsl:when>
						<xsl:otherwise>unknown</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:call-template name="render-type">
					<xsl:with-param name="type-local-name" select="$type-name"/>
				</xsl:call-template>

				<xsl:variable name="part-type" select="$consolidated-xsd[@name = $type-name and not(xsd:simpleType)][1]"/>
				<xsl:apply-templates select="$part-type" mode="operations.message.part"/>

			</xsl:when>
			<xsl:otherwise>none</xsl:otherwise>
		</xsl:choose>
	</div>
</xsl:template>

<!--
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    End of included transformation: wsdl-viewer-operations.xsl
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-->



<!--
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    Begin of included transformation: wsdl-viewer-xsd-tree.xsl
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-->
<xsl:template match="xsd:simpleType" mode="operations.message.part"/>
<xsl:template name="recursion.should.continue">
	<xsl:param name="anti.recursion"/>
	<xsl:param name="recursion.label"/>
	<xsl:param name="recursion.count">1</xsl:param>
	<xsl:variable name="has.recursion" select="contains($anti.recursion, $recursion.label)"/>
	<xsl:variable name="anti.recursion.fragment" select="substring-after($anti.recursion, $recursion.label)"/>
	<xsl:choose>
		<xsl:when test="$recursion.count &gt; $ANTIRECURSION-DEPTH"/>

		<xsl:when test="not($ENABLE-ANTIRECURSION-PROTECTION) or string-length($anti.recursion) = 0 or not($has.recursion)">
			<xsl:text>1</xsl:text>
		</xsl:when>

		<xsl:otherwise>
			<xsl:call-template name="recursion.should.continue">
				<xsl:with-param name="anti.recursion" select="$anti.recursion.fragment"/>
				<xsl:with-param name="recursion.label" select="$recursion.label"/>
				<xsl:with-param name="recursion.count" select="$recursion.count + 1"/>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>
<xsl:template match="xsd:complexType" mode="operations.message.part">
	<xsl:param name="anti.recursion"/>

	<xsl:variable name="recursion.label" select="concat('[', @name, ']')"/>
	<xsl:variable name="recursion.test">
		<xsl:call-template name="recursion.should.continue">
			<xsl:with-param name="anti.recursion" select="$anti.recursion"/>
			<xsl:with-param name="recursion.label" select="$recursion.label"/>
		</xsl:call-template>
	</xsl:variable>

	<xsl:choose>
		<xsl:when test="string-length($recursion.test) != 0">
			<xsl:apply-templates select="*" mode="operations.message.part">
				<xsl:with-param name="anti.recursion" select="concat($anti.recursion, $recursion.label)"/>
			</xsl:apply-templates>
		</xsl:when>
		<xsl:otherwise>
			<small style="color:blue">
				<xsl:value-of select="$RECURSIVE"/>
			</small>
		</xsl:otherwise>
	</xsl:choose>

</xsl:template>
<xsl:template match="xsd:complexContent" mode="operations.message.part">
	<xsl:param name="anti.recursion"/>

	<xsl:apply-templates select="*" mode="operations.message.part">
		<xsl:with-param name="anti.recursion" select="$anti.recursion"/>
	</xsl:apply-templates>
</xsl:template>
<xsl:template match="xsd:complexType[descendant::xsd:attribute[ not(@*[local-name() = 'arrayType']) ]]" mode="operations.message.part">
	<xsl:param name="anti.recursion"/>
	<xsl:variable name="recursion.label" select="concat('[', @name, ']')"/>
	<xsl:variable name="recursion.test">
		<xsl:call-template name="recursion.should.continue">
			<xsl:with-param name="anti.recursion" select="$anti.recursion"/>
			<xsl:with-param name="recursion.label" select="$recursion.label"/>
		</xsl:call-template>
	</xsl:variable>

	<xsl:choose>
		<xsl:when test="string-length($recursion.test) != 0">
			<ul type="circle">
				<xsl:apply-templates select="*" mode="operations.message.part">
					<xsl:with-param name="anti.recursion" select="concat($anti.recursion, $recursion.label)"/>
				</xsl:apply-templates>
			</ul>
		</xsl:when>
		<xsl:otherwise>
			<small style="color:blue">
				<xsl:value-of select="$RECURSIVE"/>
			</small>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>
<xsl:template match="xsd:restriction | xsd:extension" mode="operations.message.part">
	<xsl:param name="anti.recursion"/>
	<xsl:variable name="type-local-name" select="substring-after(@base, ':')"/>
	<xsl:variable name="type-name">
		<xsl:choose>
			<xsl:when test="$type-local-name">
<xsl:value-of select="$type-local-name"/>
</xsl:when>
			<xsl:when test="@base">
<xsl:value-of select="@base"/>
</xsl:when>
			<xsl:otherwise>unknown type</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="base-type" select="$consolidated-xsd[@name = $type-name][1]"/>
	<!-- xsl:if test="not($type/@abstract)">
		<xsl:apply-templates select="$type"/>
	</xsl:if -->
	<xsl:if test="$base-type != 'Array'">
		<xsl:apply-templates select="$base-type" mode="operations.message.part">
			<xsl:with-param name="anti.recursion" select="$anti.recursion"/>
		</xsl:apply-templates>
	</xsl:if>
	<xsl:apply-templates select="*" mode="operations.message.part">
		<xsl:with-param name="anti.recursion" select="$anti.recursion"/>
	</xsl:apply-templates>
</xsl:template>
<xsl:template match="xsd:union" mode="operations.message.part">
	<xsl:call-template name="process-union">
		<xsl:with-param name="set" select="@memberTypes"/>
	</xsl:call-template>
</xsl:template>
<xsl:template name="process-union">
	<xsl:param name="set"/>
	<xsl:if test="$set">
		<xsl:variable name="item" select="substring-before($set, ' ')"/>
		<xsl:variable name="the-rest" select="substring-after($set, ' ')"/>

		<xsl:variable name="type-local-name" select="substring-after($item, ':')"/>
		<xsl:variable name="type-name">
			<xsl:choose>
				<xsl:when test="$type-local-name">
<xsl:value-of select="$type-local-name"/>
</xsl:when>
				<xsl:otherwise>
<xsl:value-of select="$item"/>
</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:call-template name="render-type">
			<xsl:with-param name="type-local-name" select="$type-name"/>
		</xsl:call-template>

		<xsl:call-template name="process-union">
			<xsl:with-param name="set" select="$the-rest"/>
		</xsl:call-template>
	</xsl:if>
</xsl:template>
<xsl:template match="xsd:sequence" mode="operations.message.part">
	<xsl:param name="anti.recursion"/>
	<ul class="messageparts">
		<xsl:apply-templates select="*" mode="operations.message.part">
			<xsl:with-param name="anti.recursion" select="$anti.recursion"/>
		</xsl:apply-templates>
	</ul>
</xsl:template>
<xsl:template match="xsd:all|xsd:any|xsd:choice" mode="operations.message.part">
	<xsl:param name="anti.recursion"/>
	<xsl:variable name="list-type">
		<xsl:choose>
			<xsl:when test="self::xsd:all">disc</xsl:when>
			<xsl:when test="self::xsd:any">circle</xsl:when>
			<xsl:otherwise>square</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:element name="ul">
		<xsl:attribute name="style">
			<xsl:value-of select="concat('list-style-type:', $list-type)"/>
		</xsl:attribute>
		<xsl:apply-templates select="*" mode="operations.message.part">
			<xsl:with-param name="anti.recursion" select="$anti.recursion"/>
		</xsl:apply-templates>
	</xsl:element>
</xsl:template>
<xsl:template match="xsd:element[parent::xsd:schema]" mode="operations.message.part">
	<xsl:param name="anti.recursion"/>
	<xsl:variable name="recursion.label" select="concat('[', @name, ']')"/>
	<xsl:variable name="recursion.test">
		<xsl:call-template name="recursion.should.continue">
			<xsl:with-param name="anti.recursion" select="$anti.recursion"/>
			<xsl:with-param name="recursion.label" select="$recursion.label"/>
		</xsl:call-template>
	</xsl:variable>

	<xsl:choose>
		<xsl:when test="string-length($recursion.test) != 0">
			<xsl:variable name="type-name">
<xsl:call-template name="xsd.element-type"/>
</xsl:variable>
			<xsl:variable name="elem-type" select="$consolidated-xsd[generate-id() != generate-id(current()) and $type-name and @name=$type-name and contains(local-name(), 'Type')][1]"/>
	
			<xsl:if test="$type-name != @name">
				<xsl:apply-templates select="$elem-type" mode="operations.message.part">
					<xsl:with-param name="anti.recursion" select="concat($anti.recursion, $recursion.label)"/>
				</xsl:apply-templates>
	
				<xsl:if test="not($elem-type)">
					<xsl:call-template name="render-type">
						<xsl:with-param name="type-local-name" select="$type-name"/>
					</xsl:call-template>
				</xsl:if>
		
				<xsl:apply-templates select="*" mode="operations.message.part">
					<xsl:with-param name="anti.recursion" select="concat($anti.recursion, $recursion.label)"/>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:when>
		<xsl:otherwise>
			<small style="color:blue">
				<xsl:value-of select="$RECURSIVE"/>
			</small>
		</xsl:otherwise>
	</xsl:choose>

</xsl:template>
<xsl:template match="xsd:element | xsd:attribute" mode="operations.message.part">
	<xsl:param name="anti.recursion"/>
<!--
	<xsl:variable name="recursion.label" select="concat('[', @name, ']')"/>
-->
	<li>
		<xsl:variable name="local-ref" select="concat(@name, substring-after(@ref, ':'))"/>
		<xsl:variable name="elem-name">
			<xsl:choose>
				<xsl:when test="@name">
<xsl:value-of select="@name"/>
</xsl:when>
				<xsl:when test="$local-ref">
<xsl:value-of select="$local-ref"/>
</xsl:when>
				<xsl:when test="@ref">
<xsl:value-of select="@ref"/>
</xsl:when>
				<xsl:otherwise>anonymous</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="$elem-name"/>

		<xsl:variable name="type-name">
<xsl:call-template name="xsd.element-type"/>
</xsl:variable>

		<xsl:call-template name="render-type">
			<xsl:with-param name="type-local-name" select="$type-name"/>
		</xsl:call-template>

		<xsl:variable name="elem-type" select="$consolidated-xsd[@name = $type-name and contains(local-name(), 'Type')][1]"/>
		<xsl:apply-templates select="$elem-type | *" mode="operations.message.part">
			<xsl:with-param name="anti.recursion" select="$anti.recursion"/>
		</xsl:apply-templates>
	</li>
</xsl:template>
<xsl:template match="xsd:attribute[ @*[local-name() = 'arrayType'] ]" mode="operations.message.part">
	<xsl:param name="anti.recursion"/>
	<xsl:variable name="array-local-name" select="substring-after(@*[local-name() = 'arrayType'], ':')"/>
	<xsl:variable name="type-local-name" select="substring-before($array-local-name, '[')"/>
	<xsl:variable name="array-type" select="$consolidated-xsd[@name = $type-local-name][1]"/>

	<xsl:variable name="recursion.label" select="concat('[', $type-local-name, ']')"/>
	<xsl:variable name="recursion.test">
		<xsl:call-template name="recursion.should.continue">
			<xsl:with-param name="anti.recursion" select="$anti.recursion"/>
			<xsl:with-param name="recursion.label" select="$recursion.label"/>
		</xsl:call-template>
	</xsl:variable>

	<xsl:choose>
		<xsl:when test="string-length($recursion.test) != 0">
			<xsl:apply-templates select="$array-type" mode="operations.message.part">
				<xsl:with-param name="anti.recursion" select="concat($anti.recursion, $recursion.label)"/>
			</xsl:apply-templates>
		</xsl:when>
		<xsl:otherwise>
			<small style="color:blue">
				<xsl:value-of select="$RECURSIVE"/>
			</small>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>
<xsl:template name="xsd.element-type">
	<xsl:variable name="ref-or-type">
		<xsl:choose>
			<xsl:when test="@type">
<xsl:value-of select="@type"/>
</xsl:when>
			<xsl:otherwise>
<xsl:value-of select="@ref"/>
</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="type-local-name" select="substring-after($ref-or-type, ':')"/>
	<xsl:variable name="type-name">
		<xsl:choose>
			<xsl:when test="$type-local-name">
<xsl:value-of select="$type-local-name"/>
</xsl:when>
			<xsl:when test="$ref-or-type">
<xsl:value-of select="$ref-or-type"/>
</xsl:when>
			<xsl:otherwise>undefined</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:value-of select="$type-name"/>
</xsl:template>
<xsl:template match="xsd:documentation" mode="operations.message.part">
	<div style="color:green">
<xsl:value-of select="." disable-output-escaping="yes"/>
</div>
</xsl:template>
<xsl:template name="render-type">
	<xsl:param name="anti.recursion"/>
	<xsl:param name="type-local-name"/>

	<xsl:if test="$ENABLE-OPERATIONS-TYPE">
		<xsl:variable name="properties">
			<xsl:if test="self::xsd:element | self::xsd:attribute[parent::xsd:complexType]">
				<xsl:variable name="min">
<xsl:if test="@minOccurs = '0'">optional</xsl:if>
</xsl:variable>
				<xsl:variable name="max">
<xsl:if test="@maxOccurs = 'unbounded'">unbounded</xsl:if>
</xsl:variable>
				<xsl:variable name="nillable">
<xsl:if test="@nillable">nillable</xsl:if>
</xsl:variable>
	
				<xsl:if test="(string-length($min) + string-length($max) + string-length($nillable) + string-length(@use)) &gt; 0">
					<xsl:text> - </xsl:text>
					<xsl:value-of select="$min"/>
					<xsl:if test="string-length($min) and string-length($max)">
<xsl:text>, </xsl:text>
</xsl:if>
					<xsl:value-of select="$max"/>
					<xsl:if test="(string-length($min) + string-length($max)) &gt; 0 and string-length($nillable)">
<xsl:text>, </xsl:text>
</xsl:if>
					<xsl:value-of select="$nillable"/>
					<xsl:if test="(string-length($min) + string-length($max) + string-length($nillable)) &gt; 0 and string-length(@use)">
<xsl:text>, </xsl:text>
</xsl:if>
					<xsl:value-of select="@use"/>
					<xsl:text>; </xsl:text>
				</xsl:if>
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="recursion.label" select="concat('[', $type-local-name, ']')"/>
		<xsl:variable name="recursion.test">
			<xsl:call-template name="recursion.should.continue">
				<xsl:with-param name="anti.recursion" select="$anti.recursion"/>
				<xsl:with-param name="recursion.label" select="$recursion.label"/>
				<xsl:with-param name="recursion.count" select="$ANTIRECURSION-DEPTH"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:if test="string-length($recursion.test) != 0">
			<small style="color:blue">
				<xsl:value-of select="$properties"/>
				<xsl:variable name="elem-type" select="$consolidated-xsd[@name = $type-local-name and (not(contains(local-name(current()), 'element')) or contains(local-name(), 'Type'))][1]"/>
				<xsl:if test="string-length($type-local-name) &gt; 0">
					<xsl:call-template name="render-type.write-name">
						<xsl:with-param name="type-local-name" select="$type-local-name"/>
					</xsl:call-template>
				</xsl:if>

				<xsl:choose>
					<xsl:when test="$elem-type">

						<xsl:apply-templates select="$elem-type" mode="render-type">
							<xsl:with-param name="anti.recursion" select="concat($anti.recursion, $recursion.label)"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>

						<xsl:apply-templates select="*" mode="render-type">
							<xsl:with-param name="anti.recursion" select="concat($anti.recursion, $recursion.label)"/>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</small>
		</xsl:if>
	</xsl:if>
</xsl:template>
<xsl:template name="render-type.write-name">
	<xsl:param name="type-local-name"/>
	<xsl:text> type </xsl:text>
	<big>
		<xsl:choose>
			<xsl:when test="$type-local-name">
<xsl:value-of select="$type-local-name"/>
</xsl:when>
			<xsl:otherwise>undefined</xsl:otherwise>
		</xsl:choose>
	</big>
</xsl:template>
<xsl:template match="*" mode="render-type"/>
<xsl:template match="xsd:element | xsd:complexType | xsd:simpleType | xsd:complexContent" mode="render-type">
	<xsl:param name="anti.recursion"/>
	<xsl:apply-templates select="*" mode="render-type">
		<xsl:with-param name="anti.recursion" select="$anti.recursion"/>
	</xsl:apply-templates>
</xsl:template>
<xsl:template match="xsd:restriction[ parent::xsd:simpleType ]" mode="render-type">
	<xsl:param name="anti.recursion"/>
	<xsl:variable name="type-local-name" select="substring-after(@base, ':')"/>
	<xsl:variable name="type-name">
		<xsl:choose>
			<xsl:when test="$type-local-name">
<xsl:value-of select="$type-local-name"/>
</xsl:when>
			<xsl:when test="@base">
<xsl:value-of select="@base"/>
</xsl:when>
			<xsl:otherwise>undefined</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:text> - </xsl:text>
	<xsl:call-template name="render-type.write-name">
		<xsl:with-param name="type-local-name" select="$type-local-name"/>
	</xsl:call-template>
	<xsl:text> with </xsl:text>
	<xsl:value-of select="local-name()"/>
	<xsl:apply-templates select="*" mode="render-type">
		<xsl:with-param name="anti.recursion" select="$anti.recursion"/>
	</xsl:apply-templates>
</xsl:template>
<xsl:template match="xsd:simpleType/xsd:restriction/xsd:*[not(self::xsd:enumeration)]" mode="render-type">
	<xsl:text> </xsl:text>
	<xsl:value-of select="local-name()"/>
	<xsl:text>(</xsl:text>
	<xsl:value-of select="@value"/>
	<xsl:text>)</xsl:text>
</xsl:template>
<xsl:template match="xsd:restriction | xsd:extension" mode="render-type">
	<xsl:param name="anti.recursion"/>
	<xsl:variable name="type-local-name" select="substring-after(@base, ':')"/>
	<xsl:variable name="type-name">
		<xsl:choose>
			<xsl:when test="$type-local-name">
<xsl:value-of select="$type-local-name"/>
</xsl:when>
			<xsl:when test="@base">
<xsl:value-of select="@base"/>
</xsl:when>
			<xsl:otherwise>undefined</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="base-type" select="$consolidated-xsd[@name = $type-name][1]"/>
	<xsl:variable name="abstract">
<xsl:if test="$base-type/@abstract">abstract </xsl:if>
</xsl:variable>

	<xsl:if test="not($type-name = 'Array')">
		<xsl:value-of select="concat(' - ', local-name(), ' of ', $abstract)"/>
		<xsl:call-template name="render-type.write-name">
			<xsl:with-param name="type-local-name" select="$type-name"/>
		</xsl:call-template>
	</xsl:if>

	<xsl:apply-templates select="$base-type | *" mode="render-type">
		<xsl:with-param name="anti.recursion" select="$anti.recursion"/>
	</xsl:apply-templates>
</xsl:template>
<xsl:template match="xsd:attribute[ @*[local-name() = 'arrayType'] ]" mode="render-type">
	<xsl:param name="anti.recursion"/>
	<xsl:variable name="array-local-name" select="substring-after(@*[local-name() = 'arrayType'], ':')"/>
	<xsl:variable name="type-local-name" select="substring-before($array-local-name, '[')"/>
	<xsl:variable name="array-type" select="$consolidated-xsd[@name = $type-local-name][1]"/>

	<xsl:text> - array of </xsl:text>
	<xsl:call-template name="render-type.write-name">
		<xsl:with-param name="type-local-name" select="$type-local-name"/>
	</xsl:call-template>

	<xsl:apply-templates select="$array-type" mode="render-type">
		<xsl:with-param name="anti.recursion" select="$anti.recursion"/>
	</xsl:apply-templates>
</xsl:template>
<xsl:template match="xsd:enumeration" mode="render-type"/>
<xsl:template match="xsd:enumeration[not(preceding-sibling::xsd:enumeration)]" mode="render-type">
	<xsl:text> - enum { </xsl:text>
	<xsl:apply-templates select="self::* | following-sibling::xsd:enumeration" mode="render-type.enum"/>
	<xsl:text> }</xsl:text>
</xsl:template>
<xsl:template match="xsd:enumeration" mode="render-type.enum">
	<xsl:if test="preceding-sibling::xsd:enumeration">
		<xsl:text>, </xsl:text>
	</xsl:if>
	<xsl:text disable-output-escaping="yes">'</xsl:text>
	<xsl:value-of select="@value"/>
	<xsl:text disable-output-escaping="yes">'</xsl:text>
</xsl:template>

<!--
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    End of included transformation: wsdl-viewer-xsd-tree.xsl
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-->



<!--
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    Begin of included transformation: wsdl-viewer-src.xsl
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-->
<xsl:template match="@*" mode="src.import">
	<xsl:param name="src.import.stack"/>
	<xsl:variable name="recursion.label" select="concat('[', string(.), ']')"/>
	<xsl:variable name="recursion.check" select="concat($src.import.stack, $recursion.label)"/>

	<xsl:choose>
		<xsl:when test="contains($src.import.stack, $recursion.label)">
			<h2 style="red">
<xsl:value-of select="concat('Cyclic include / import: ', $recursion.check)"/>
</h2>
		</xsl:when>
		<xsl:otherwise>
		    <span class="anchor" id="{concat($SRC-FILE-PREFIX, generate-id(..))}"/>
			<h2>
			<xsl:choose>
				<xsl:when test="parent::xsd:include">Included </xsl:when>
				<xsl:otherwise>Imported </xsl:otherwise>
			</xsl:choose>

			<xsl:choose>
				<xsl:when test="name() = 'location'">WSDL </xsl:when>
				<xsl:otherwise>Schema </xsl:otherwise>
			</xsl:choose>
			<xsl:value-of select="."/>
</h2>

			<div class="box">
				<xsl:apply-templates select="document(string(.))" mode="src"/>
			</div>

			<xsl:apply-templates select="document(string(.))/*/*[local-name() = 'import'][@location]/@location" mode="src.import">
				<xsl:with-param name="src.import.stack" select="$recursion.check"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="document(string(.))//xsd:import[@schemaLocation]/@schemaLocation" mode="src.import">
				<xsl:with-param name="src.import.stack" select="$recursion.check"/>
			</xsl:apply-templates>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>
<xsl:template match="*" mode="src">
	<span class="anchor" id="{concat($SRC-PREFIX, generate-id(.))}"/>
	<div class="xml-element">
		<xsl:apply-templates select="." mode="src.link"/>
		<xsl:apply-templates select="." mode="src.start-tag"/>
		<xsl:apply-templates select="*|comment()|processing-instruction()|text()[string-length(normalize-space(.)) &gt; 0]" mode="src"/>
		<xsl:apply-templates select="." mode="src.end-tag"/>
	</div>
</xsl:template>
<xsl:template match="*" mode="src.start-tag">
	<xsl:call-template name="src.elem">
		<xsl:with-param name="src.elem.end-slash"> /</xsl:with-param>
	</xsl:call-template>
</xsl:template>
<xsl:template match="*[*|comment()|processing-instruction()|text()[string-length(normalize-space(.)) &gt; 0]]" mode="src.start-tag">
	<xsl:call-template name="src.elem"/>
</xsl:template>
<xsl:template match="*" mode="src.end-tag"/>
<xsl:template match="*[*|comment()|processing-instruction()|text()[string-length(normalize-space(.)) &gt; 0]]" mode="src.end-tag">
	<xsl:call-template name="src.elem">
		<xsl:with-param name="src.elem.start-slash">/</xsl:with-param>
	</xsl:call-template>
</xsl:template>
<xsl:template match="*" mode="src.link-attribute">
<xsl:if test="$ENABLE-LINK">
	<xsl:attribute name="href">
<xsl:value-of select="concat('#', $SRC-PREFIX, generate-id(.))"/>
</xsl:attribute>
</xsl:if>
</xsl:template>
<xsl:template match="*[local-name() = 'import' or local-name() = 'include'][@location or @schemaLocation]" mode="src.link">
<xsl:if test="$ENABLE-LINK">
	<xsl:attribute name="href">
<xsl:value-of select="concat('#', $SRC-FILE-PREFIX, generate-id(.))"/>
</xsl:attribute>
</xsl:if>
</xsl:template>
<xsl:template match="*" mode="src.link"/>
<xsl:template match="ws2:service|ws2:binding" mode="src.link">
	<xsl:variable name="iface-name">
		<xsl:apply-templates select="@interface" mode="qname.normalized"/>
	</xsl:variable>
	<xsl:apply-templates select="$consolidated-wsdl/ws2:interface[@name = $iface-name]" mode="src.link-attribute"/>
</xsl:template>
<xsl:template match="ws2:endpoint" mode="src.link">
	<xsl:variable name="binding-name">
		<xsl:apply-templates select="@binding" mode="qname.normalized"/>
	</xsl:variable>
	<xsl:apply-templates select="$consolidated-wsdl/ws2:binding[@name = $binding-name]" mode="src.link-attribute"/>
</xsl:template>
<xsl:template match="ws2:binding/ws2:operation" mode="src.link">
	<xsl:variable name="operation-name">
		<xsl:apply-templates select="@ref" mode="qname.normalized"/>
	</xsl:variable>
	<xsl:apply-templates select="$consolidated-wsdl/ws2:interface/ws2:operation[@name = $operation-name]" mode="src.link-attribute"/>
</xsl:template>
<xsl:template match="ws2:binding/ws2:fault|ws2:interface/ws2:operation/ws2:infault|ws2:interface/ws2:operation/ws2:outfault" mode="src.link">
	<xsl:variable name="operation-name">
		<xsl:apply-templates select="@ref" mode="qname.normalized"/>
	</xsl:variable>
	<xsl:apply-templates select="$consolidated-wsdl/ws2:interface/ws2:fault[@name = $operation-name]" mode="src.link-attribute"/>
</xsl:template>
<xsl:template match="ws2:interface/ws2:operation/ws2:input|ws2:interface/ws2:operation/ws2:output|ws2:interface/ws2:fault" mode="src.link">
	<xsl:variable name="elem-name">
		<xsl:apply-templates select="@element" mode="qname.normalized"/>
	</xsl:variable>
	<xsl:apply-templates select="$consolidated-xsd[@name = $elem-name]" mode="src.link-attribute"/>
</xsl:template>
<xsl:template match="ws:operation/ws:input[@message] | ws:operation/ws:output[@message] | ws:operation/ws:fault[@message] | soap:header[ancestor::ws:operation and @message]" mode="src.link">
	<xsl:apply-templates select="$consolidated-wsdl/ws:message[@name = substring-after( current()/@message, ':' )]" mode="src.link-attribute"/>
</xsl:template>
<xsl:template match="ws:operation/ws:input[@message] | ws:operation/ws:output[@message] | ws:operation/ws:fault[@message] | soap:header[ancestor::ws:operation and @message]" mode="src.link">
	<xsl:apply-templates select="$consolidated-wsdl/ws:message[@name = substring-after( current()/@message, ':' )]" mode="src.link-attribute"/>
</xsl:template>
<xsl:template match="ws:message/ws:part[@element or @type]" mode="src.link">
	<xsl:variable name="elem-local-name" select="substring-after(@element, ':')"/>
	<xsl:variable name="type-local-name" select="substring-after(@type, ':')"/>
	<xsl:variable name="elem-name">
		<xsl:choose>
			<xsl:when test="$elem-local-name">
<xsl:value-of select="$elem-local-name"/>
</xsl:when>
			<xsl:when test="$type-local-name">
<xsl:value-of select="$type-local-name"/>
</xsl:when>
			<xsl:when test="@element">
<xsl:value-of select="@element"/>
</xsl:when>
			<xsl:when test="@type">
<xsl:value-of select="@type"/>
</xsl:when>
			<xsl:otherwise>
<xsl:call-template name="src.syntax-error"/>
</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:apply-templates select="$consolidated-xsd[@name = $elem-name]" mode="src.link-attribute"/>
</xsl:template>
<xsl:template match="ws:service/ws:port[@binding]" mode="src.link">
	<xsl:variable name="binding-name">
		<xsl:apply-templates select="@binding" mode="qname.normalized"/>
	</xsl:variable>
	<xsl:apply-templates select="$consolidated-wsdl/ws:binding[@name = $binding-name]" mode="src.link-attribute"/>
</xsl:template>
<xsl:template match="ws:operation[@name and parent::ws:binding/@type]" mode="src.link">
	<xsl:variable name="type-name">
		<xsl:apply-templates select="../@type" mode="qname.normalized"/>
	</xsl:variable>
	<xsl:apply-templates select="$consolidated-wsdl/ws:portType[@name = $type-name]/ws:operation[@name = current()/@name]" mode="src.link-attribute"/>
</xsl:template>
<xsl:template match="xsd:element[@ref or @type]" mode="src.link">
	<xsl:variable name="ref-or-type">
		<xsl:choose>
			<xsl:when test="@type">
<xsl:value-of select="@type"/>
</xsl:when>
			<xsl:otherwise>
<xsl:value-of select="@ref"/>
</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="type-local-name" select="substring-after($ref-or-type, ':')"/>
	<xsl:variable name="xsd-name">
		<xsl:choose>
			<xsl:when test="$type-local-name">
<xsl:value-of select="$type-local-name"/>
</xsl:when>
			<xsl:when test="$ref-or-type">
<xsl:value-of select="$ref-or-type"/>
</xsl:when>
			<xsl:otherwise/>
		</xsl:choose>
	</xsl:variable>

	<xsl:if test="$xsd-name">
		<xsl:variable name="msg" select="$consolidated-xsd[@name = $xsd-name and contains(local-name(), 'Type')][1]"/>
		<xsl:apply-templates select="$msg" mode="src.link-attribute"/>
	</xsl:if>
</xsl:template>
<xsl:template match="xsd:attribute[contains(@ref, 'arrayType')]" mode="src.link">
	<xsl:variable name="att-array-type" select="substring-before(@*[local-name() = 'arrayType'], '[]')"/>
	<xsl:variable name="xsd-local-name" select="substring-after($att-array-type, ':')"/>
	<xsl:variable name="xsd-name">
		<xsl:choose>
			<xsl:when test="$xsd-local-name">
<xsl:value-of select="$xsd-local-name"/>
</xsl:when>
			<xsl:otherwise>
<xsl:value-of select="$att-array-type"/>
</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:if test="$xsd-name">
		<xsl:variable name="msg" select="$consolidated-xsd[@name = $xsd-name][1]"/>
		<xsl:apply-templates select="$msg" mode="src.link-attribute"/>
	</xsl:if>
</xsl:template>
<xsl:template match="xsd:extension | xsd:restriction" mode="src.link">
	<xsl:variable name="xsd-local-name" select="substring-after(@base, ':')"/>
	<xsl:variable name="xsd-name">
		<xsl:choose>
			<xsl:when test="$xsd-local-name">
<xsl:value-of select="$xsd-local-name"/>
</xsl:when>
			<xsl:otherwise>
<xsl:value-of select="@type"/>
</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="msg" select="$consolidated-xsd[@name = $xsd-name][1]"/>
	<xsl:apply-templates select="$msg" mode="src.link-attribute"/>
</xsl:template>
<xsl:template name="src.elem">
	<xsl:param name="src.elem.start-slash"/>
	<xsl:param name="src.elem.end-slash"/>

	<xsl:value-of select="concat('&lt;', $src.elem.start-slash, name(.))" disable-output-escaping="no"/>
	<xsl:if test="not($src.elem.start-slash)">
<xsl:apply-templates select="@*" mode="src"/>
<xsl:apply-templates select="." mode="src.namespace"/>
</xsl:if>
	<xsl:value-of select="concat($src.elem.end-slash, '&gt;')" disable-output-escaping="no"/>
</xsl:template>
<xsl:template match="@*" mode="src">
	<xsl:text> </xsl:text>
	<span class="xml-att">
		<xsl:value-of select="concat(name(), '=')"/>
		<span class="xml-att-val">
			<xsl:value-of select="concat('&quot;', ., '&quot;')" disable-output-escaping="yes"/>
		</span>
	</span>
</xsl:template>
<xsl:template match="*" mode="src.namespace">
	<xsl:variable name="supports-namespace-axis" select="count(/*/namespace::*) &gt; 0"/>
	<xsl:variable name="current" select="current()"/>

	<xsl:choose>
		<xsl:when test="count(/*/namespace::*) &gt; 0">
				<!--
					When the namespace axis is present (e.g. Internet Explorer), we can simulate
					the namespace declarations by comparing the namespaces in scope on this element
					with those in scope on the parent element.  Any difference must have been the
					result of a namespace declaration.  Note that this doesn't reflect the actual
					source - it will strip out redundant namespace declarations.
				-->
			<xsl:for-each select="namespace::*[. != 'http://www.w3.org/XML/1998/namespace']"> 
				<xsl:if test="not($current/parent::*[namespace::*[. = current()]])">
					<div class="xml-att">
						<xsl:text> xmlns</xsl:text>
						<xsl:if test="string-length(name())">:</xsl:if>
						<xsl:value-of select="concat(name(), '=')"/>
						<span class="xml-att-val">
							<xsl:value-of select="concat('&quot;', ., '&quot;')" disable-output-escaping="yes"/>
						</span>
					</div>
				</xsl:if>
			</xsl:for-each>
		</xsl:when>
		<xsl:otherwise>
			<!-- 
				When the namespace axis isn't supported (e.g. Mozilla), we can simulate
				appropriate declarations from namespace elements.
				This currently doesn't check for namespaces on attributes.
				In the general case we can't reliably detect the use of QNames in content, but
				in the case of schema, we know which content could contain a QName and look
				there too.  This mechanism is rather unpleasant though, since it records
				namespaces where they are used rather than showing where they are declared 
				(on some parent element) in the source.  Yukk!
			-->
			<xsl:if test="namespace-uri(.) != namespace-uri(parent::*) or not(parent::*)">
				<span class="xml-att">
					<xsl:text> xmlns</xsl:text>
					<xsl:if test="substring-before(name(),':') != ''">:</xsl:if>
					<xsl:value-of select="substring-before(name(),':')"/>
					<xsl:text>=</xsl:text>
					<span class="xml-att-val">
						<xsl:value-of select="concat('&quot;', namespace-uri(.), '&quot;')" disable-output-escaping="yes"/>
					</span>
				</span>
			</xsl:if>
		</xsl:otherwise>
	</xsl:choose>

</xsl:template>
<xsl:template match="text()" mode="src">
	<span class="xml-text">
<xsl:value-of select="." disable-output-escaping="no"/>
</span>
</xsl:template>
<xsl:template match="comment()" mode="src">
<div class="xml-comment">
	<xsl:text disable-output-escaping="no">&lt;!-- </xsl:text>
	<xsl:value-of select="." disable-output-escaping="no"/>
	<xsl:text disable-output-escaping="no"> --&gt;
</xsl:text>
</div>
</xsl:template>
<xsl:template match="processing-instruction()" mode="src">
<div class="xml-proc">
	<xsl:text disable-output-escaping="no">&lt;?</xsl:text>
	<xsl:copy-of select="name(.)"/>
	<xsl:value-of select="concat(' ', .)" disable-output-escaping="yes"/>
	<xsl:text disable-output-escaping="no"> ?&gt;
</xsl:text>
</div>
</xsl:template>

<!--
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    End of included transformation: wsdl-viewer-src.xsl
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-->



<!--
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    Begin of included transformation: wsdl-viewer-jquery-min.xsl
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-->
<xsl:variable name="jquery">

/*! jQuery v1.8.2 jquery.com | jquery.org/license */
(function(a,b){function G(a){var b=F[a]={};return p.each(a.split(s),function(a,c){b[c]=!0}),b}function J(a,c,d){if(d===b&amp;&amp;a.nodeType===1){var e="data-"+c.replace(I,"-$1").toLowerCase();d=a.getAttribute(e);if(typeof d=="string"){try{d=d==="true"?!0:d==="false"?!1:d==="null"?null:+d+""===d?+d:H.test(d)?p.parseJSON(d):d}catch(f){}p.data(a,c,d)}else d=b}return d}function K(a){var b;for(b in a){if(b==="data"&amp;&amp;p.isEmptyObject(a[b]))continue;if(b!=="toJSON")return!1}return!0}function ba(){return!1}function bb(){return!0}function bh(a){return!a||!a.parentNode||a.parentNode.nodeType===11}function bi(a,b){do a=a[b];while(a&amp;&amp;a.nodeType!==1);return a}function bj(a,b,c){b=b||0;if(p.isFunction(b))return p.grep(a,function(a,d){var e=!!b.call(a,d,a);return e===c});if(b.nodeType)return p.grep(a,function(a,d){return a===b===c});if(typeof b=="string"){var d=p.grep(a,function(a){return a.nodeType===1});if(be.test(b))return p.filter(b,d,!c);b=p.filter(b,d)}return p.grep(a,function(a,d){return p.inArray(a,b)&gt;=0===c})}function bk(a){var b=bl.split("|"),c=a.createDocumentFragment();if(c.createElement)while(b.length)c.createElement(b.pop());return c}function bC(a,b){return a.getElementsByTagName(b)[0]||a.appendChild(a.ownerDocument.createElement(b))}function bD(a,b){if(b.nodeType!==1||!p.hasData(a))return;var c,d,e,f=p._data(a),g=p._data(b,f),h=f.events;if(h){delete g.handle,g.events={};for(c in h)for(d=0,e=h[c].length;d&lt;e;d++)p.event.add(b,c,h[c][d])}g.data&amp;&amp;(g.data=p.extend({},g.data))}function bE(a,b){var c;if(b.nodeType!==1)return;b.clearAttributes&amp;&amp;b.clearAttributes(),b.mergeAttributes&amp;&amp;b.mergeAttributes(a),c=b.nodeName.toLowerCase(),c==="object"?(b.parentNode&amp;&amp;(b.outerHTML=a.outerHTML),p.support.html5Clone&amp;&amp;a.innerHTML&amp;&amp;!p.trim(b.innerHTML)&amp;&amp;(b.innerHTML=a.innerHTML)):c==="input"&amp;&amp;bv.test(a.type)?(b.defaultChecked=b.checked=a.checked,b.value!==a.value&amp;&amp;(b.value=a.value)):c==="option"?b.selected=a.defaultSelected:c==="input"||c==="textarea"?b.defaultValue=a.defaultValue:c==="script"&amp;&amp;b.text!==a.text&amp;&amp;(b.text=a.text),b.removeAttribute(p.expando)}function bF(a){return typeof a.getElementsByTagName!="undefined"?a.getElementsByTagName("*"):typeof a.querySelectorAll!="undefined"?a.querySelectorAll("*"):[]}function bG(a){bv.test(a.type)&amp;&amp;(a.defaultChecked=a.checked)}function bY(a,b){if(b in a)return b;var c=b.charAt(0).toUpperCase()+b.slice(1),d=b,e=bW.length;while(e--){b=bW[e]+c;if(b in a)return b}return d}function bZ(a,b){return a=b||a,p.css(a,"display")==="none"||!p.contains(a.ownerDocument,a)}function b$(a,b){var c,d,e=[],f=0,g=a.length;for(;f&lt;g;f++){c=a[f];if(!c.style)continue;e[f]=p._data(c,"olddisplay"),b?(!e[f]&amp;&amp;c.style.display==="none"&amp;&amp;(c.style.display=""),c.style.display===""&amp;&amp;bZ(c)&amp;&amp;(e[f]=p._data(c,"olddisplay",cc(c.nodeName)))):(d=bH(c,"display"),!e[f]&amp;&amp;d!=="none"&amp;&amp;p._data(c,"olddisplay",d))}for(f=0;f&lt;g;f++){c=a[f];if(!c.style)continue;if(!b||c.style.display==="none"||c.style.display==="")c.style.display=b?e[f]||"":"none"}return a}function b_(a,b,c){var d=bP.exec(b);return d?Math.max(0,d[1]-(c||0))+(d[2]||"px"):b}function ca(a,b,c,d){var e=c===(d?"border":"content")?4:b==="width"?1:0,f=0;for(;e&lt;4;e+=2)c==="margin"&amp;&amp;(f+=p.css(a,c+bV[e],!0)),d?(c==="content"&amp;&amp;(f-=parseFloat(bH(a,"padding"+bV[e]))||0),c!=="margin"&amp;&amp;(f-=parseFloat(bH(a,"border"+bV[e]+"Width"))||0)):(f+=parseFloat(bH(a,"padding"+bV[e]))||0,c!=="padding"&amp;&amp;(f+=parseFloat(bH(a,"border"+bV[e]+"Width"))||0));return f}function cb(a,b,c){var d=b==="width"?a.offsetWidth:a.offsetHeight,e=!0,f=p.support.boxSizing&amp;&amp;p.css(a,"boxSizing")==="border-box";if(d&lt;=0||d==null){d=bH(a,b);if(d&lt;0||d==null)d=a.style[b];if(bQ.test(d))return d;e=f&amp;&amp;(p.support.boxSizingReliable||d===a.style[b]),d=parseFloat(d)||0}return d+ca(a,b,c||(f?"border":"content"),e)+"px"}function cc(a){if(bS[a])return bS[a];var b=p("&lt;"+a+"&gt;").appendTo(e.body),c=b.css("display");b.remove();if(c==="none"||c===""){bI=e.body.appendChild(bI||p.extend(e.createElement("iframe"),{frameBorder:0,width:0,height:0}));if(!bJ||!bI.createElement)bJ=(bI.contentWindow||bI.contentDocument).document,bJ.write("&lt;!doctype html&gt;&lt;html&gt;&lt;body&gt;"),bJ.close();b=bJ.body.appendChild(bJ.createElement(a)),c=bH(b,"display"),e.body.removeChild(bI)}return bS[a]=c,c}function ci(a,b,c,d){var e;if(p.isArray(b))p.each(b,function(b,e){c||ce.test(a)?d(a,e):ci(a+"["+(typeof e=="object"?b:"")+"]",e,c,d)});else if(!c&amp;&amp;p.type(b)==="object")for(e in b)ci(a+"["+e+"]",b[e],c,d);else d(a,b)}function cz(a){return function(b,c){typeof b!="string"&amp;&amp;(c=b,b="*");var d,e,f,g=b.toLowerCase().split(s),h=0,i=g.length;if(p.isFunction(c))for(;h&lt;i;h++)d=g[h],f=/^\+/.test(d),f&amp;&amp;(d=d.substr(1)||"*"),e=a[d]=a[d]||[],e[f?"unshift":"push"](c)}}function cA(a,c,d,e,f,g){f=f||c.dataTypes[0],g=g||{},g[f]=!0;var h,i=a[f],j=0,k=i?i.length:0,l=a===cv;for(;j&lt;k&amp;&amp;(l||!h);j++)h=i[j](c,d,e),typeof h=="string"&amp;&amp;(!l||g[h]?h=b:(c.dataTypes.unshift(h),h=cA(a,c,d,e,h,g)));return(l||!h)&amp;&amp;!g["*"]&amp;&amp;(h=cA(a,c,d,e,"*",g)),h}function cB(a,c){var d,e,f=p.ajaxSettings.flatOptions||{};for(d in c)c[d]!==b&amp;&amp;((f[d]?a:e||(e={}))[d]=c[d]);e&amp;&amp;p.extend(!0,a,e)}function cC(a,c,d){var e,f,g,h,i=a.contents,j=a.dataTypes,k=a.responseFields;for(f in k)f in d&amp;&amp;(c[k[f]]=d[f]);while(j[0]==="*")j.shift(),e===b&amp;&amp;(e=a.mimeType||c.getResponseHeader("content-type"));if(e)for(f in i)if(i[f]&amp;&amp;i[f].test(e)){j.unshift(f);break}if(j[0]in d)g=j[0];else{for(f in d){if(!j[0]||a.converters[f+" "+j[0]]){g=f;break}h||(h=f)}g=g||h}if(g)return g!==j[0]&amp;&amp;j.unshift(g),d[g]}function cD(a,b){var c,d,e,f,g=a.dataTypes.slice(),h=g[0],i={},j=0;a.dataFilter&amp;&amp;(b=a.dataFilter(b,a.dataType));if(g[1])for(c in a.converters)i[c.toLowerCase()]=a.converters[c];for(;e=g[++j];)if(e!=="*"){if(h!=="*"&amp;&amp;h!==e){c=i[h+" "+e]||i["* "+e];if(!c)for(d in i){f=d.split(" ");if(f[1]===e){c=i[h+" "+f[0]]||i["* "+f[0]];if(c){c===!0?c=i[d]:i[d]!==!0&amp;&amp;(e=f[0],g.splice(j--,0,e));break}}}if(c!==!0)if(c&amp;&amp;a["throws"])b=c(b);else try{b=c(b)}catch(k){return{state:"parsererror",error:c?k:"No conversion from "+h+" to "+e}}}h=e}return{state:"success",data:b}}function cL(){try{return new a.XMLHttpRequest}catch(b){}}function cM(){try{return new a.ActiveXObject("Microsoft.XMLHTTP")}catch(b){}}function cU(){return setTimeout(function(){cN=b},0),cN=p.now()}function cV(a,b){p.each(b,function(b,c){var d=(cT[b]||[]).concat(cT["*"]),e=0,f=d.length;for(;e&lt;f;e++)if(d[e].call(a,b,c))return})}function cW(a,b,c){var d,e=0,f=0,g=cS.length,h=p.Deferred().always(function(){delete i.elem}),i=function(){var b=cN||cU(),c=Math.max(0,j.startTime+j.duration-b),d=1-(c/j.duration||0),e=0,f=j.tweens.length;for(;e&lt;f;e++)j.tweens[e].run(d);return h.notifyWith(a,[j,d,c]),d&lt;1&amp;&amp;f?c:(h.resolveWith(a,[j]),!1)},j=h.promise({elem:a,props:p.extend({},b),opts:p.extend(!0,{specialEasing:{}},c),originalProperties:b,originalOptions:c,startTime:cN||cU(),duration:c.duration,tweens:[],createTween:function(b,c,d){var e=p.Tween(a,j.opts,b,c,j.opts.specialEasing[b]||j.opts.easing);return j.tweens.push(e),e},stop:function(b){var c=0,d=b?j.tweens.length:0;for(;c&lt;d;c++)j.tweens[c].run(1);return b?h.resolveWith(a,[j,b]):h.rejectWith(a,[j,b]),this}}),k=j.props;cX(k,j.opts.specialEasing);for(;e&lt;g;e++){d=cS[e].call(j,a,k,j.opts);if(d)return d}return cV(j,k),p.isFunction(j.opts.start)&amp;&amp;j.opts.start.call(a,j),p.fx.timer(p.extend(i,{anim:j,queue:j.opts.queue,elem:a})),j.progress(j.opts.progress).done(j.opts.done,j.opts.complete).fail(j.opts.fail).always(j.opts.always)}function cX(a,b){var c,d,e,f,g;for(c in a){d=p.camelCase(c),e=b[d],f=a[c],p.isArray(f)&amp;&amp;(e=f[1],f=a[c]=f[0]),c!==d&amp;&amp;(a[d]=f,delete a[c]),g=p.cssHooks[d];if(g&amp;&amp;"expand"in g){f=g.expand(f),delete a[d];for(c in f)c in a||(a[c]=f[c],b[c]=e)}else b[d]=e}}function cY(a,b,c){var d,e,f,g,h,i,j,k,l=this,m=a.style,n={},o=[],q=a.nodeType&amp;&amp;bZ(a);c.queue||(j=p._queueHooks(a,"fx"),j.unqueued==null&amp;&amp;(j.unqueued=0,k=j.empty.fire,j.empty.fire=function(){j.unqueued||k()}),j.unqueued++,l.always(function(){l.always(function(){j.unqueued--,p.queue(a,"fx").length||j.empty.fire()})})),a.nodeType===1&amp;&amp;("height"in b||"width"in b)&amp;&amp;(c.overflow=[m.overflow,m.overflowX,m.overflowY],p.css(a,"display")==="inline"&amp;&amp;p.css(a,"float")==="none"&amp;&amp;(!p.support.inlineBlockNeedsLayout||cc(a.nodeName)==="inline"?m.display="inline-block":m.zoom=1)),c.overflow&amp;&amp;(m.overflow="hidden",p.support.shrinkWrapBlocks||l.done(function(){m.overflow=c.overflow[0],m.overflowX=c.overflow[1],m.overflowY=c.overflow[2]}));for(d in b){f=b[d];if(cP.exec(f)){delete b[d];if(f===(q?"hide":"show"))continue;o.push(d)}}g=o.length;if(g){h=p._data(a,"fxshow")||p._data(a,"fxshow",{}),q?p(a).show():l.done(function(){p(a).hide()}),l.done(function(){var b;p.removeData(a,"fxshow",!0);for(b in n)p.style(a,b,n[b])});for(d=0;d&lt;g;d++)e=o[d],i=l.createTween(e,q?h[e]:0),n[e]=h[e]||p.style(a,e),e in h||(h[e]=i.start,q&amp;&amp;(i.end=i.start,i.start=e==="width"||e==="height"?1:0))}}function cZ(a,b,c,d,e){return new cZ.prototype.init(a,b,c,d,e)}function c$(a,b){var c,d={height:a},e=0;b=b?1:0;for(;e&lt;4;e+=2-b)c=bV[e],d["margin"+c]=d["padding"+c]=a;return b&amp;&amp;(d.opacity=d.width=a),d}function da(a){return p.isWindow(a)?a:a.nodeType===9?a.defaultView||a.parentWindow:!1}var c,d,e=a.document,f=a.location,g=a.navigator,h=a.jQuery,i=a.$,j=Array.prototype.push,k=Array.prototype.slice,l=Array.prototype.indexOf,m=Object.prototype.toString,n=Object.prototype.hasOwnProperty,o=String.prototype.trim,p=function(a,b){return new p.fn.init(a,b,c)},q=/[\-+]?(?:\d*\.|)\d+(?:[eE][\-+]?\d+|)/.source,r=/\S/,s=/\s+/,t=/^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g,u=/^(?:[^#&lt;]*(&lt;[\w\W]+&gt;)[^&gt;]*$|#([\w\-]*)$)/,v=/^&lt;(\w+)\s*\/?&gt;(?:&lt;\/\1&gt;|)$/,w=/^[\],:{}\s]*$/,x=/(?:^|:|,)(?:\s*\[)+/g,y=/\\(?:["\\\/bfnrt]|u[\da-fA-F]{4})/g,z=/"[^"\\\r\n]*"|true|false|null|-?(?:\d\d*\.|)\d+(?:[eE][\-+]?\d+|)/g,A=/^-ms-/,B=/-([\da-z])/gi,C=function(a,b){return(b+"").toUpperCase()},D=function(){e.addEventListener?(e.removeEventListener("DOMContentLoaded",D,!1),p.ready()):e.readyState==="complete"&amp;&amp;(e.detachEvent("onreadystatechange",D),p.ready())},E={};p.fn=p.prototype={constructor:p,init:function(a,c,d){var f,g,h,i;if(!a)return this;if(a.nodeType)return this.context=this[0]=a,this.length=1,this;if(typeof a=="string"){a.charAt(0)==="&lt;"&amp;&amp;a.charAt(a.length-1)==="&gt;"&amp;&amp;a.length&gt;=3?f=[null,a,null]:f=u.exec(a);if(f&amp;&amp;(f[1]||!c)){if(f[1])return c=c instanceof p?c[0]:c,i=c&amp;&amp;c.nodeType?c.ownerDocument||c:e,a=p.parseHTML(f[1],i,!0),v.test(f[1])&amp;&amp;p.isPlainObject(c)&amp;&amp;this.attr.call(a,c,!0),p.merge(this,a);g=e.getElementById(f[2]);if(g&amp;&amp;g.parentNode){if(g.id!==f[2])return d.find(a);this.length=1,this[0]=g}return this.context=e,this.selector=a,this}return!c||c.jquery?(c||d).find(a):this.constructor(c).find(a)}return p.isFunction(a)?d.ready(a):(a.selector!==b&amp;&amp;(this.selector=a.selector,this.context=a.context),p.makeArray(a,this))},selector:"",jquery:"1.8.2",length:0,size:function(){return this.length},toArray:function(){return k.call(this)},get:function(a){return a==null?this.toArray():a&lt;0?this[this.length+a]:this[a]},pushStack:function(a,b,c){var d=p.merge(this.constructor(),a);return d.prevObject=this,d.context=this.context,b==="find"?d.selector=this.selector+(this.selector?" ":"")+c:b&amp;&amp;(d.selector=this.selector+"."+b+"("+c+")"),d},each:function(a,b){return p.each(this,a,b)},ready:function(a){return p.ready.promise().done(a),this},eq:function(a){return a=+a,a===-1?this.slice(a):this.slice(a,a+1)},first:function(){return this.eq(0)},last:function(){return this.eq(-1)},slice:function(){return this.pushStack(k.apply(this,arguments),"slice",k.call(arguments).join(","))},map:function(a){return this.pushStack(p.map(this,function(b,c){return a.call(b,c,b)}))},end:function(){return this.prevObject||this.constructor(null)},push:j,sort:[].sort,splice:[].splice},p.fn.init.prototype=p.fn,p.extend=p.fn.extend=function(){var a,c,d,e,f,g,h=arguments[0]||{},i=1,j=arguments.length,k=!1;typeof h=="boolean"&amp;&amp;(k=h,h=arguments[1]||{},i=2),typeof h!="object"&amp;&amp;!p.isFunction(h)&amp;&amp;(h={}),j===i&amp;&amp;(h=this,--i);for(;i&lt;j;i++)if((a=arguments[i])!=null)for(c in a){d=h[c],e=a[c];if(h===e)continue;k&amp;&amp;e&amp;&amp;(p.isPlainObject(e)||(f=p.isArray(e)))?(f?(f=!1,g=d&amp;&amp;p.isArray(d)?d:[]):g=d&amp;&amp;p.isPlainObject(d)?d:{},h[c]=p.extend(k,g,e)):e!==b&amp;&amp;(h[c]=e)}return h},p.extend({noConflict:function(b){return a.$===p&amp;&amp;(a.$=i),b&amp;&amp;a.jQuery===p&amp;&amp;(a.jQuery=h),p},isReady:!1,readyWait:1,holdReady:function(a){a?p.readyWait++:p.ready(!0)},ready:function(a){if(a===!0?--p.readyWait:p.isReady)return;if(!e.body)return setTimeout(p.ready,1);p.isReady=!0;if(a!==!0&amp;&amp;--p.readyWait&gt;0)return;d.resolveWith(e,[p]),p.fn.trigger&amp;&amp;p(e).trigger("ready").off("ready")},isFunction:function(a){return p.type(a)==="function"},isArray:Array.isArray||function(a){return p.type(a)==="array"},isWindow:function(a){return a!=null&amp;&amp;a==a.window},isNumeric:function(a){return!isNaN(parseFloat(a))&amp;&amp;isFinite(a)},type:function(a){return a==null?String(a):E[m.call(a)]||"object"},isPlainObject:function(a){if(!a||p.type(a)!=="object"||a.nodeType||p.isWindow(a))return!1;try{if(a.constructor&amp;&amp;!n.call(a,"constructor")&amp;&amp;!n.call(a.constructor.prototype,"isPrototypeOf"))return!1}catch(c){return!1}var d;for(d in a);return d===b||n.call(a,d)},isEmptyObject:function(a){var b;for(b in a)return!1;return!0},error:function(a){throw new Error(a)},parseHTML:function(a,b,c){var d;return!a||typeof a!="string"?null:(typeof b=="boolean"&amp;&amp;(c=b,b=0),b=b||e,(d=v.exec(a))?[b.createElement(d[1])]:(d=p.buildFragment([a],b,c?null:[]),p.merge([],(d.cacheable?p.clone(d.fragment):d.fragment).childNodes)))},parseJSON:function(b){if(!b||typeof b!="string")return null;b=p.trim(b);if(a.JSON&amp;&amp;a.JSON.parse)return a.JSON.parse(b);if(w.test(b.replace(y,"@").replace(z,"]").replace(x,"")))return(new Function("return "+b))();p.error("Invalid JSON: "+b)},parseXML:function(c){var d,e;if(!c||typeof c!="string")return null;try{a.DOMParser?(e=new DOMParser,d=e.parseFromString(c,"text/xml")):(d=new ActiveXObject("Microsoft.XMLDOM"),d.async="false",d.loadXML(c))}catch(f){d=b}return(!d||!d.documentElement||d.getElementsByTagName("parsererror").length)&amp;&amp;p.error("Invalid XML: "+c),d},noop:function(){},globalEval:function(b){b&amp;&amp;r.test(b)&amp;&amp;(a.execScript||function(b){a.eval.call(a,b)})(b)},camelCase:function(a){return a.replace(A,"ms-").replace(B,C)},nodeName:function(a,b){return a.nodeName&amp;&amp;a.nodeName.toLowerCase()===b.toLowerCase()},each:function(a,c,d){var e,f=0,g=a.length,h=g===b||p.isFunction(a);if(d){if(h){for(e in a)if(c.apply(a[e],d)===!1)break}else for(;f&lt;g;)if(c.apply(a[f++],d)===!1)break}else if(h){for(e in a)if(c.call(a[e],e,a[e])===!1)break}else for(;f&lt;g;)if(c.call(a[f],f,a[f++])===!1)break;return a},trim:o&amp;&amp;!o.call("﻿ ")?function(a){return a==null?"":o.call(a)}:function(a){return a==null?"":(a+"").replace(t,"")},makeArray:function(a,b){var c,d=b||[];return a!=null&amp;&amp;(c=p.type(a),a.length==null||c==="string"||c==="function"||c==="regexp"||p.isWindow(a)?j.call(d,a):p.merge(d,a)),d},inArray:function(a,b,c){var d;if(b){if(l)return l.call(b,a,c);d=b.length,c=c?c&lt;0?Math.max(0,d+c):c:0;for(;c&lt;d;c++)if(c in b&amp;&amp;b[c]===a)return c}return-1},merge:function(a,c){var d=c.length,e=a.length,f=0;if(typeof d=="number")for(;f&lt;d;f++)a[e++]=c[f];else while(c[f]!==b)a[e++]=c[f++];return a.length=e,a},grep:function(a,b,c){var d,e=[],f=0,g=a.length;c=!!c;for(;f&lt;g;f++)d=!!b(a[f],f),c!==d&amp;&amp;e.push(a[f]);return e},map:function(a,c,d){var e,f,g=[],h=0,i=a.length,j=a instanceof p||i!==b&amp;&amp;typeof i=="number"&amp;&amp;(i&gt;0&amp;&amp;a[0]&amp;&amp;a[i-1]||i===0||p.isArray(a));if(j)for(;h&lt;i;h++)e=c(a[h],h,d),e!=null&amp;&amp;(g[g.length]=e);else for(f in a)e=c(a[f],f,d),e!=null&amp;&amp;(g[g.length]=e);return g.concat.apply([],g)},guid:1,proxy:function(a,c){var d,e,f;return typeof c=="string"&amp;&amp;(d=a[c],c=a,a=d),p.isFunction(a)?(e=k.call(arguments,2),f=function(){return a.apply(c,e.concat(k.call(arguments)))},f.guid=a.guid=a.guid||p.guid++,f):b},access:function(a,c,d,e,f,g,h){var i,j=d==null,k=0,l=a.length;if(d&amp;&amp;typeof d=="object"){for(k in d)p.access(a,c,k,d[k],1,g,e);f=1}else if(e!==b){i=h===b&amp;&amp;p.isFunction(e),j&amp;&amp;(i?(i=c,c=function(a,b,c){return i.call(p(a),c)}):(c.call(a,e),c=null));if(c)for(;k&lt;l;k++)c(a[k],d,i?e.call(a[k],k,c(a[k],d)):e,h);f=1}return f?a:j?c.call(a):l?c(a[0],d):g},now:function(){return(new Date).getTime()}}),p.ready.promise=function(b){if(!d){d=p.Deferred();if(e.readyState==="complete")setTimeout(p.ready,1);else if(e.addEventListener)e.addEventListener("DOMContentLoaded",D,!1),a.addEventListener("load",p.ready,!1);else{e.attachEvent("onreadystatechange",D),a.attachEvent("onload",p.ready);var c=!1;try{c=a.frameElement==null&amp;&amp;e.documentElement}catch(f){}c&amp;&amp;c.doScroll&amp;&amp;function g(){if(!p.isReady){try{c.doScroll("left")}catch(a){return setTimeout(g,50)}p.ready()}}()}}return d.promise(b)},p.each("Boolean Number String Function Array Date RegExp Object".split(" "),function(a,b){E["[object "+b+"]"]=b.toLowerCase()}),c=p(e);var F={};p.Callbacks=function(a){a=typeof a=="string"?F[a]||G(a):p.extend({},a);var c,d,e,f,g,h,i=[],j=!a.once&amp;&amp;[],k=function(b){c=a.memory&amp;&amp;b,d=!0,h=f||0,f=0,g=i.length,e=!0;for(;i&amp;&amp;h&lt;g;h++)if(i[h].apply(b[0],b[1])===!1&amp;&amp;a.stopOnFalse){c=!1;break}e=!1,i&amp;&amp;(j?j.length&amp;&amp;k(j.shift()):c?i=[]:l.disable())},l={add:function(){if(i){var b=i.length;(function d(b){p.each(b,function(b,c){var e=p.type(c);e==="function"&amp;&amp;(!a.unique||!l.has(c))?i.push(c):c&amp;&amp;c.length&amp;&amp;e!=="string"&amp;&amp;d(c)})})(arguments),e?g=i.length:c&amp;&amp;(f=b,k(c))}return this},remove:function(){return i&amp;&amp;p.each(arguments,function(a,b){var c;while((c=p.inArray(b,i,c))&gt;-1)i.splice(c,1),e&amp;&amp;(c&lt;=g&amp;&amp;g--,c&lt;=h&amp;&amp;h--)}),this},has:function(a){return p.inArray(a,i)&gt;-1},empty:function(){return i=[],this},disable:function(){return i=j=c=b,this},disabled:function(){return!i},lock:function(){return j=b,c||l.disable(),this},locked:function(){return!j},fireWith:function(a,b){return b=b||[],b=[a,b.slice?b.slice():b],i&amp;&amp;(!d||j)&amp;&amp;(e?j.push(b):k(b)),this},fire:function(){return l.fireWith(this,arguments),this},fired:function(){return!!d}};return l},p.extend({Deferred:function(a){var b=[["resolve","done",p.Callbacks("once memory"),"resolved"],["reject","fail",p.Callbacks("once memory"),"rejected"],["notify","progress",p.Callbacks("memory")]],c="pending",d={state:function(){return c},always:function(){return e.done(arguments).fail(arguments),this},then:function(){var a=arguments;return p.Deferred(function(c){p.each(b,function(b,d){var f=d[0],g=a[b];e[d[1]](p.isFunction(g)?function(){var a=g.apply(this,arguments);a&amp;&amp;p.isFunction(a.promise)?a.promise().done(c.resolve).fail(c.reject).progress(c.notify):c[f+"With"](this===e?c:this,[a])}:c[f])}),a=null}).promise()},promise:function(a){return a!=null?p.extend(a,d):d}},e={};return d.pipe=d.then,p.each(b,function(a,f){var g=f[2],h=f[3];d[f[1]]=g.add,h&amp;&amp;g.add(function(){c=h},b[a^1][2].disable,b[2][2].lock),e[f[0]]=g.fire,e[f[0]+"With"]=g.fireWith}),d.promise(e),a&amp;&amp;a.call(e,e),e},when:function(a){var b=0,c=k.call(arguments),d=c.length,e=d!==1||a&amp;&amp;p.isFunction(a.promise)?d:0,f=e===1?a:p.Deferred(),g=function(a,b,c){return function(d){b[a]=this,c[a]=arguments.length&gt;1?k.call(arguments):d,c===h?f.notifyWith(b,c):--e||f.resolveWith(b,c)}},h,i,j;if(d&gt;1){h=new Array(d),i=new Array(d),j=new Array(d);for(;b&lt;d;b++)c[b]&amp;&amp;p.isFunction(c[b].promise)?c[b].promise().done(g(b,j,c)).fail(f.reject).progress(g(b,i,h)):--e}return e||f.resolveWith(j,c),f.promise()}}),p.support=function(){var b,c,d,f,g,h,i,j,k,l,m,n=e.createElement("div");n.setAttribute("className","t"),n.innerHTML="  &lt;link/&gt;&lt;table&gt;&lt;/table&gt;&lt;a href='/a'&gt;a&lt;/a&gt;&lt;input type='checkbox'/&gt;",c=n.getElementsByTagName("*"),d=n.getElementsByTagName("a")[0],d.style.cssText="top:1px;float:left;opacity:.5";if(!c||!c.length)return{};f=e.createElement("select"),g=f.appendChild(e.createElement("option")),h=n.getElementsByTagName("input")[0],b={leadingWhitespace:n.firstChild.nodeType===3,tbody:!n.getElementsByTagName("tbody").length,htmlSerialize:!!n.getElementsByTagName("link").length,style:/top/.test(d.getAttribute("style")),hrefNormalized:d.getAttribute("href")==="/a",opacity:/^0.5/.test(d.style.opacity),cssFloat:!!d.style.cssFloat,checkOn:h.value==="on",optSelected:g.selected,getSetAttribute:n.className!=="t",enctype:!!e.createElement("form").enctype,html5Clone:e.createElement("nav").cloneNode(!0).outerHTML!=="&lt;:nav&gt;&lt;/:nav&gt;",boxModel:e.compatMode==="CSS1Compat",submitBubbles:!0,changeBubbles:!0,focusinBubbles:!1,deleteExpando:!0,noCloneEvent:!0,inlineBlockNeedsLayout:!1,shrinkWrapBlocks:!1,reliableMarginRight:!0,boxSizingReliable:!0,pixelPosition:!1},h.checked=!0,b.noCloneChecked=h.cloneNode(!0).checked,f.disabled=!0,b.optDisabled=!g.disabled;try{delete n.test}catch(o){b.deleteExpando=!1}!n.addEventListener&amp;&amp;n.attachEvent&amp;&amp;n.fireEvent&amp;&amp;(n.attachEvent("onclick",m=function(){b.noCloneEvent=!1}),n.cloneNode(!0).fireEvent("onclick"),n.detachEvent("onclick",m)),h=e.createElement("input"),h.value="t",h.setAttribute("type","radio"),b.radioValue=h.value==="t",h.setAttribute("checked","checked"),h.setAttribute("name","t"),n.appendChild(h),i=e.createDocumentFragment(),i.appendChild(n.lastChild),b.checkClone=i.cloneNode(!0).cloneNode(!0).lastChild.checked,b.appendChecked=h.checked,i.removeChild(h),i.appendChild(n);if(n.attachEvent)for(k in{submit:!0,change:!0,focusin:!0})j="on"+k,l=j in n,l||(n.setAttribute(j,"return;"),l=typeof n[j]=="function"),b[k+"Bubbles"]=l;return p(function(){var c,d,f,g,h="padding:0;margin:0;border:0;display:block;overflow:hidden;",i=e.getElementsByTagName("body")[0];if(!i)return;c=e.createElement("div"),c.style.cssText="visibility:hidden;border:0;width:0;height:0;position:static;top:0;margin-top:1px",i.insertBefore(c,i.firstChild),d=e.createElement("div"),c.appendChild(d),d.innerHTML="&lt;table&gt;&lt;tr&gt;&lt;td&gt;&lt;/td&gt;&lt;td&gt;t&lt;/td&gt;&lt;/tr&gt;&lt;/table&gt;",f=d.getElementsByTagName("td"),f[0].style.cssText="padding:0;margin:0;border:0;display:none",l=f[0].offsetHeight===0,f[0].style.display="",f[1].style.display="none",b.reliableHiddenOffsets=l&amp;&amp;f[0].offsetHeight===0,d.innerHTML="",d.style.cssText="box-sizing:border-box;-moz-box-sizing:border-box;-webkit-box-sizing:border-box;padding:1px;border:1px;display:block;width:4px;margin-top:1%;position:absolute;top:1%;",b.boxSizing=d.offsetWidth===4,b.doesNotIncludeMarginInBodyOffset=i.offsetTop!==1,a.getComputedStyle&amp;&amp;(b.pixelPosition=(a.getComputedStyle(d,null)||{}).top!=="1%",b.boxSizingReliable=(a.getComputedStyle(d,null)||{width:"4px"}).width==="4px",g=e.createElement("div"),g.style.cssText=d.style.cssText=h,g.style.marginRight=g.style.width="0",d.style.width="1px",d.appendChild(g),b.reliableMarginRight=!parseFloat((a.getComputedStyle(g,null)||{}).marginRight)),typeof d.style.zoom!="undefined"&amp;&amp;(d.innerHTML="",d.style.cssText=h+"width:1px;padding:1px;display:inline;zoom:1",b.inlineBlockNeedsLayout=d.offsetWidth===3,d.style.display="block",d.style.overflow="visible",d.innerHTML="&lt;div&gt;&lt;/div&gt;",d.firstChild.style.width="5px",b.shrinkWrapBlocks=d.offsetWidth!==3,c.style.zoom=1),i.removeChild(c),c=d=f=g=null}),i.removeChild(n),c=d=f=g=h=i=n=null,b}();var H=/(?:\{[\s\S]*\}|\[[\s\S]*\])$/,I=/([A-Z])/g;p.extend({cache:{},deletedIds:[],uuid:0,expando:"jQuery"+(p.fn.jquery+Math.random()).replace(/\D/g,""),noData:{embed:!0,object:"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000",applet:!0},hasData:function(a){return a=a.nodeType?p.cache[a[p.expando]]:a[p.expando],!!a&amp;&amp;!K(a)},data:function(a,c,d,e){if(!p.acceptData(a))return;var f,g,h=p.expando,i=typeof c=="string",j=a.nodeType,k=j?p.cache:a,l=j?a[h]:a[h]&amp;&amp;h;if((!l||!k[l]||!e&amp;&amp;!k[l].data)&amp;&amp;i&amp;&amp;d===b)return;l||(j?a[h]=l=p.deletedIds.pop()||p.guid++:l=h),k[l]||(k[l]={},j||(k[l].toJSON=p.noop));if(typeof c=="object"||typeof c=="function")e?k[l]=p.extend(k[l],c):k[l].data=p.extend(k[l].data,c);return f=k[l],e||(f.data||(f.data={}),f=f.data),d!==b&amp;&amp;(f[p.camelCase(c)]=d),i?(g=f[c],g==null&amp;&amp;(g=f[p.camelCase(c)])):g=f,g},removeData:function(a,b,c){if(!p.acceptData(a))return;var d,e,f,g=a.nodeType,h=g?p.cache:a,i=g?a[p.expando]:p.expando;if(!h[i])return;if(b){d=c?h[i]:h[i].data;if(d){p.isArray(b)||(b in d?b=[b]:(b=p.camelCase(b),b in d?b=[b]:b=b.split(" ")));for(e=0,f=b.length;e&lt;f;e++)delete d[b[e]];if(!(c?K:p.isEmptyObject)(d))return}}if(!c){delete h[i].data;if(!K(h[i]))return}g?p.cleanData([a],!0):p.support.deleteExpando||h!=h.window?delete h[i]:h[i]=null},_data:function(a,b,c){return p.data(a,b,c,!0)},acceptData:function(a){var b=a.nodeName&amp;&amp;p.noData[a.nodeName.toLowerCase()];return!b||b!==!0&amp;&amp;a.getAttribute("classid")===b}}),p.fn.extend({data:function(a,c){var d,e,f,g,h,i=this[0],j=0,k=null;if(a===b){if(this.length){k=p.data(i);if(i.nodeType===1&amp;&amp;!p._data(i,"parsedAttrs")){f=i.attributes;for(h=f.length;j&lt;h;j++)g=f[j].name,g.indexOf("data-")||(g=p.camelCase(g.substring(5)),J(i,g,k[g]));p._data(i,"parsedAttrs",!0)}}return k}return typeof a=="object"?this.each(function(){p.data(this,a)}):(d=a.split(".",2),d[1]=d[1]?"."+d[1]:"",e=d[1]+"!",p.access(this,function(c){if(c===b)return k=this.triggerHandler("getData"+e,[d[0]]),k===b&amp;&amp;i&amp;&amp;(k=p.data(i,a),k=J(i,a,k)),k===b&amp;&amp;d[1]?this.data(d[0]):k;d[1]=c,this.each(function(){var b=p(this);b.triggerHandler("setData"+e,d),p.data(this,a,c),b.triggerHandler("changeData"+e,d)})},null,c,arguments.length&gt;1,null,!1))},removeData:function(a){return this.each(function(){p.removeData(this,a)})}}),p.extend({queue:function(a,b,c){var d;if(a)return b=(b||"fx")+"queue",d=p._data(a,b),c&amp;&amp;(!d||p.isArray(c)?d=p._data(a,b,p.makeArray(c)):d.push(c)),d||[]},dequeue:function(a,b){b=b||"fx";var c=p.queue(a,b),d=c.length,e=c.shift(),f=p._queueHooks(a,b),g=function(){p.dequeue(a,b)};e==="inprogress"&amp;&amp;(e=c.shift(),d--),e&amp;&amp;(b==="fx"&amp;&amp;c.unshift("inprogress"),delete f.stop,e.call(a,g,f)),!d&amp;&amp;f&amp;&amp;f.empty.fire()},_queueHooks:function(a,b){var c=b+"queueHooks";return p._data(a,c)||p._data(a,c,{empty:p.Callbacks("once memory").add(function(){p.removeData(a,b+"queue",!0),p.removeData(a,c,!0)})})}}),p.fn.extend({queue:function(a,c){var d=2;return typeof a!="string"&amp;&amp;(c=a,a="fx",d--),arguments.length&lt;d?p.queue(this[0],a):c===b?this:this.each(function(){var b=p.queue(this,a,c);p._queueHooks(this,a),a==="fx"&amp;&amp;b[0]!=="inprogress"&amp;&amp;p.dequeue(this,a)})},dequeue:function(a){return this.each(function(){p.dequeue(this,a)})},delay:function(a,b){return a=p.fx?p.fx.speeds[a]||a:a,b=b||"fx",this.queue(b,function(b,c){var d=setTimeout(b,a);c.stop=function(){clearTimeout(d)}})},clearQueue:function(a){return this.queue(a||"fx",[])},promise:function(a,c){var d,e=1,f=p.Deferred(),g=this,h=this.length,i=function(){--e||f.resolveWith(g,[g])};typeof a!="string"&amp;&amp;(c=a,a=b),a=a||"fx";while(h--)d=p._data(g[h],a+"queueHooks"),d&amp;&amp;d.empty&amp;&amp;(e++,d.empty.add(i));return i(),f.promise(c)}});var L,M,N,O=/[\t\r\n]/g,P=/\r/g,Q=/^(?:button|input)$/i,R=/^(?:button|input|object|select|textarea)$/i,S=/^a(?:rea|)$/i,T=/^(?:autofocus|autoplay|async|checked|controls|defer|disabled|hidden|loop|multiple|open|readonly|required|scoped|selected)$/i,U=p.support.getSetAttribute;p.fn.extend({attr:function(a,b){return p.access(this,p.attr,a,b,arguments.length&gt;1)},removeAttr:function(a){return this.each(function(){p.removeAttr(this,a)})},prop:function(a,b){return p.access(this,p.prop,a,b,arguments.length&gt;1)},removeProp:function(a){return a=p.propFix[a]||a,this.each(function(){try{this[a]=b,delete this[a]}catch(c){}})},addClass:function(a){var b,c,d,e,f,g,h;if(p.isFunction(a))return this.each(function(b){p(this).addClass(a.call(this,b,this.className))});if(a&amp;&amp;typeof a=="string"){b=a.split(s);for(c=0,d=this.length;c&lt;d;c++){e=this[c];if(e.nodeType===1)if(!e.className&amp;&amp;b.length===1)e.className=a;else{f=" "+e.className+" ";for(g=0,h=b.length;g&lt;h;g++)f.indexOf(" "+b[g]+" ")&lt;0&amp;&amp;(f+=b[g]+" ");e.className=p.trim(f)}}}return this},removeClass:function(a){var c,d,e,f,g,h,i;if(p.isFunction(a))return this.each(function(b){p(this).removeClass(a.call(this,b,this.className))});if(a&amp;&amp;typeof a=="string"||a===b){c=(a||"").split(s);for(h=0,i=this.length;h&lt;i;h++){e=this[h];if(e.nodeType===1&amp;&amp;e.className){d=(" "+e.className+" ").replace(O," ");for(f=0,g=c.length;f&lt;g;f++)while(d.indexOf(" "+c[f]+" ")&gt;=0)d=d.replace(" "+c[f]+" "," ");e.className=a?p.trim(d):""}}}return this},toggleClass:function(a,b){var c=typeof a,d=typeof b=="boolean";return p.isFunction(a)?this.each(function(c){p(this).toggleClass(a.call(this,c,this.className,b),b)}):this.each(function(){if(c==="string"){var e,f=0,g=p(this),h=b,i=a.split(s);while(e=i[f++])h=d?h:!g.hasClass(e),g[h?"addClass":"removeClass"](e)}else if(c==="undefined"||c==="boolean")this.className&amp;&amp;p._data(this,"__className__",this.className),this.className=this.className||a===!1?"":p._data(this,"__className__")||""})},hasClass:function(a){var b=" "+a+" ",c=0,d=this.length;for(;c&lt;d;c++)if(this[c].nodeType===1&amp;&amp;(" "+this[c].className+" ").replace(O," ").indexOf(b)&gt;=0)return!0;return!1},val:function(a){var c,d,e,f=this[0];if(!arguments.length){if(f)return c=p.valHooks[f.type]||p.valHooks[f.nodeName.toLowerCase()],c&amp;&amp;"get"in c&amp;&amp;(d=c.get(f,"value"))!==b?d:(d=f.value,typeof d=="string"?d.replace(P,""):d==null?"":d);return}return e=p.isFunction(a),this.each(function(d){var f,g=p(this);if(this.nodeType!==1)return;e?f=a.call(this,d,g.val()):f=a,f==null?f="":typeof f=="number"?f+="":p.isArray(f)&amp;&amp;(f=p.map(f,function(a){return a==null?"":a+""})),c=p.valHooks[this.type]||p.valHooks[this.nodeName.toLowerCase()];if(!c||!("set"in c)||c.set(this,f,"value")===b)this.value=f})}}),p.extend({valHooks:{option:{get:function(a){var b=a.attributes.value;return!b||b.specified?a.value:a.text}},select:{get:function(a){var b,c,d,e,f=a.selectedIndex,g=[],h=a.options,i=a.type==="select-one";if(f&lt;0)return null;c=i?f:0,d=i?f+1:h.length;for(;c&lt;d;c++){e=h[c];if(e.selected&amp;&amp;(p.support.optDisabled?!e.disabled:e.getAttribute("disabled")===null)&amp;&amp;(!e.parentNode.disabled||!p.nodeName(e.parentNode,"optgroup"))){b=p(e).val();if(i)return b;g.push(b)}}return i&amp;&amp;!g.length&amp;&amp;h.length?p(h[f]).val():g},set:function(a,b){var c=p.makeArray(b);return p(a).find("option").each(function(){this.selected=p.inArray(p(this).val(),c)&gt;=0}),c.length||(a.selectedIndex=-1),c}}},attrFn:{},attr:function(a,c,d,e){var f,g,h,i=a.nodeType;if(!a||i===3||i===8||i===2)return;if(e&amp;&amp;p.isFunction(p.fn[c]))return p(a)[c](d);if(typeof a.getAttribute=="undefined")return p.prop(a,c,d);h=i!==1||!p.isXMLDoc(a),h&amp;&amp;(c=c.toLowerCase(),g=p.attrHooks[c]||(T.test(c)?M:L));if(d!==b){if(d===null){p.removeAttr(a,c);return}return g&amp;&amp;"set"in g&amp;&amp;h&amp;&amp;(f=g.set(a,d,c))!==b?f:(a.setAttribute(c,d+""),d)}return g&amp;&amp;"get"in g&amp;&amp;h&amp;&amp;(f=g.get(a,c))!==null?f:(f=a.getAttribute(c),f===null?b:f)},removeAttr:function(a,b){var c,d,e,f,g=0;if(b&amp;&amp;a.nodeType===1){d=b.split(s);for(;g&lt;d.length;g++)e=d[g],e&amp;&amp;(c=p.propFix[e]||e,f=T.test(e),f||p.attr(a,e,""),a.removeAttribute(U?e:c),f&amp;&amp;c in a&amp;&amp;(a[c]=!1))}},attrHooks:{type:{set:function(a,b){if(Q.test(a.nodeName)&amp;&amp;a.parentNode)p.error("type property can't be changed");else if(!p.support.radioValue&amp;&amp;b==="radio"&amp;&amp;p.nodeName(a,"input")){var c=a.value;return a.setAttribute("type",b),c&amp;&amp;(a.value=c),b}}},value:{get:function(a,b){return L&amp;&amp;p.nodeName(a,"button")?L.get(a,b):b in a?a.value:null},set:function(a,b,c){if(L&amp;&amp;p.nodeName(a,"button"))return L.set(a,b,c);a.value=b}}},propFix:{tabindex:"tabIndex",readonly:"readOnly","for":"htmlFor","class":"className",maxlength:"maxLength",cellspacing:"cellSpacing",cellpadding:"cellPadding",rowspan:"rowSpan",colspan:"colSpan",usemap:"useMap",frameborder:"frameBorder",contenteditable:"contentEditable"},prop:function(a,c,d){var e,f,g,h=a.nodeType;if(!a||h===3||h===8||h===2)return;return g=h!==1||!p.isXMLDoc(a),g&amp;&amp;(c=p.propFix[c]||c,f=p.propHooks[c]),d!==b?f&amp;&amp;"set"in f&amp;&amp;(e=f.set(a,d,c))!==b?e:a[c]=d:f&amp;&amp;"get"in f&amp;&amp;(e=f.get(a,c))!==null?e:a[c]},propHooks:{tabIndex:{get:function(a){var c=a.getAttributeNode("tabindex");return c&amp;&amp;c.specified?parseInt(c.value,10):R.test(a.nodeName)||S.test(a.nodeName)&amp;&amp;a.href?0:b}}}}),M={get:function(a,c){var d,e=p.prop(a,c);return e===!0||typeof e!="boolean"&amp;&amp;(d=a.getAttributeNode(c))&amp;&amp;d.nodeValue!==!1?c.toLowerCase():b},set:function(a,b,c){var d;return b===!1?p.removeAttr(a,c):(d=p.propFix[c]||c,d in a&amp;&amp;(a[d]=!0),a.setAttribute(c,c.toLowerCase())),c}},U||(N={name:!0,id:!0,coords:!0},L=p.valHooks.button={get:function(a,c){var d;return d=a.getAttributeNode(c),d&amp;&amp;(N[c]?d.value!=="":d.specified)?d.value:b},set:function(a,b,c){var d=a.getAttributeNode(c);return d||(d=e.createAttribute(c),a.setAttributeNode(d)),d.value=b+""}},p.each(["width","height"],function(a,b){p.attrHooks[b]=p.extend(p.attrHooks[b],{set:function(a,c){if(c==="")return a.setAttribute(b,"auto"),c}})}),p.attrHooks.contenteditable={get:L.get,set:function(a,b,c){b===""&amp;&amp;(b="false"),L.set(a,b,c)}}),p.support.hrefNormalized||p.each(["href","src","width","height"],function(a,c){p.attrHooks[c]=p.extend(p.attrHooks[c],{get:function(a){var d=a.getAttribute(c,2);return d===null?b:d}})}),p.support.style||(p.attrHooks.style={get:function(a){return a.style.cssText.toLowerCase()||b},set:function(a,b){return a.style.cssText=b+""}}),p.support.optSelected||(p.propHooks.selected=p.extend(p.propHooks.selected,{get:function(a){var b=a.parentNode;return b&amp;&amp;(b.selectedIndex,b.parentNode&amp;&amp;b.parentNode.selectedIndex),null}})),p.support.enctype||(p.propFix.enctype="encoding"),p.support.checkOn||p.each(["radio","checkbox"],function(){p.valHooks[this]={get:function(a){return a.getAttribute("value")===null?"on":a.value}}}),p.each(["radio","checkbox"],function(){p.valHooks[this]=p.extend(p.valHooks[this],{set:function(a,b){if(p.isArray(b))return a.checked=p.inArray(p(a).val(),b)&gt;=0}})});var V=/^(?:textarea|input|select)$/i,W=/^([^\.]*|)(?:\.(.+)|)$/,X=/(?:^|\s)hover(\.\S+|)\b/,Y=/^key/,Z=/^(?:mouse|contextmenu)|click/,$=/^(?:focusinfocus|focusoutblur)$/,_=function(a){return p.event.special.hover?a:a.replace(X,"mouseenter$1 mouseleave$1")};p.event={add:function(a,c,d,e,f){var g,h,i,j,k,l,m,n,o,q,r;if(a.nodeType===3||a.nodeType===8||!c||!d||!(g=p._data(a)))return;d.handler&amp;&amp;(o=d,d=o.handler,f=o.selector),d.guid||(d.guid=p.guid++),i=g.events,i||(g.events=i={}),h=g.handle,h||(g.handle=h=function(a){return typeof p!="undefined"&amp;&amp;(!a||p.event.triggered!==a.type)?p.event.dispatch.apply(h.elem,arguments):b},h.elem=a),c=p.trim(_(c)).split(" ");for(j=0;j&lt;c.length;j++){k=W.exec(c[j])||[],l=k[1],m=(k[2]||"").split(".").sort(),r=p.event.special[l]||{},l=(f?r.delegateType:r.bindType)||l,r=p.event.special[l]||{},n=p.extend({type:l,origType:k[1],data:e,handler:d,guid:d.guid,selector:f,needsContext:f&amp;&amp;p.expr.match.needsContext.test(f),namespace:m.join(".")},o),q=i[l];if(!q){q=i[l]=[],q.delegateCount=0;if(!r.setup||r.setup.call(a,e,m,h)===!1)a.addEventListener?a.addEventListener(l,h,!1):a.attachEvent&amp;&amp;a.attachEvent("on"+l,h)}r.add&amp;&amp;(r.add.call(a,n),n.handler.guid||(n.handler.guid=d.guid)),f?q.splice(q.delegateCount++,0,n):q.push(n),p.event.global[l]=!0}a=null},global:{},remove:function(a,b,c,d,e){var f,g,h,i,j,k,l,m,n,o,q,r=p.hasData(a)&amp;&amp;p._data(a);if(!r||!(m=r.events))return;b=p.trim(_(b||"")).split(" ");for(f=0;f&lt;b.length;f++){g=W.exec(b[f])||[],h=i=g[1],j=g[2];if(!h){for(h in m)p.event.remove(a,h+b[f],c,d,!0);continue}n=p.event.special[h]||{},h=(d?n.delegateType:n.bindType)||h,o=m[h]||[],k=o.length,j=j?new RegExp("(^|\\.)"+j.split(".").sort().join("\\.(?:.*\\.|)")+"(\\.|$)"):null;for(l=0;l&lt;o.length;l++)q=o[l],(e||i===q.origType)&amp;&amp;(!c||c.guid===q.guid)&amp;&amp;(!j||j.test(q.namespace))&amp;&amp;(!d||d===q.selector||d==="**"&amp;&amp;q.selector)&amp;&amp;(o.splice(l--,1),q.selector&amp;&amp;o.delegateCount--,n.remove&amp;&amp;n.remove.call(a,q));o.length===0&amp;&amp;k!==o.length&amp;&amp;((!n.teardown||n.teardown.call(a,j,r.handle)===!1)&amp;&amp;p.removeEvent(a,h,r.handle),delete m[h])}p.isEmptyObject(m)&amp;&amp;(delete r.handle,p.removeData(a,"events",!0))},customEvent:{getData:!0,setData:!0,changeData:!0},trigger:function(c,d,f,g){if(!f||f.nodeType!==3&amp;&amp;f.nodeType!==8){var h,i,j,k,l,m,n,o,q,r,s=c.type||c,t=[];if($.test(s+p.event.triggered))return;s.indexOf("!")&gt;=0&amp;&amp;(s=s.slice(0,-1),i=!0),s.indexOf(".")&gt;=0&amp;&amp;(t=s.split("."),s=t.shift(),t.sort());if((!f||p.event.customEvent[s])&amp;&amp;!p.event.global[s])return;c=typeof c=="object"?c[p.expando]?c:new p.Event(s,c):new p.Event(s),c.type=s,c.isTrigger=!0,c.exclusive=i,c.namespace=t.join("."),c.namespace_re=c.namespace?new RegExp("(^|\\.)"+t.join("\\.(?:.*\\.|)")+"(\\.|$)"):null,m=s.indexOf(":")&lt;0?"on"+s:"";if(!f){h=p.cache;for(j in h)h[j].events&amp;&amp;h[j].events[s]&amp;&amp;p.event.trigger(c,d,h[j].handle.elem,!0);return}c.result=b,c.target||(c.target=f),d=d!=null?p.makeArray(d):[],d.unshift(c),n=p.event.special[s]||{};if(n.trigger&amp;&amp;n.trigger.apply(f,d)===!1)return;q=[[f,n.bindType||s]];if(!g&amp;&amp;!n.noBubble&amp;&amp;!p.isWindow(f)){r=n.delegateType||s,k=$.test(r+s)?f:f.parentNode;for(l=f;k;k=k.parentNode)q.push([k,r]),l=k;l===(f.ownerDocument||e)&amp;&amp;q.push([l.defaultView||l.parentWindow||a,r])}for(j=0;j&lt;q.length&amp;&amp;!c.isPropagationStopped();j++)k=q[j][0],c.type=q[j][1],o=(p._data(k,"events")||{})[c.type]&amp;&amp;p._data(k,"handle"),o&amp;&amp;o.apply(k,d),o=m&amp;&amp;k[m],o&amp;&amp;p.acceptData(k)&amp;&amp;o.apply&amp;&amp;o.apply(k,d)===!1&amp;&amp;c.preventDefault();return c.type=s,!g&amp;&amp;!c.isDefaultPrevented()&amp;&amp;(!n._default||n._default.apply(f.ownerDocument,d)===!1)&amp;&amp;(s!=="click"||!p.nodeName(f,"a"))&amp;&amp;p.acceptData(f)&amp;&amp;m&amp;&amp;f[s]&amp;&amp;(s!=="focus"&amp;&amp;s!=="blur"||c.target.offsetWidth!==0)&amp;&amp;!p.isWindow(f)&amp;&amp;(l=f[m],l&amp;&amp;(f[m]=null),p.event.triggered=s,f[s](),p.event.triggered=b,l&amp;&amp;(f[m]=l)),c.result}return},dispatch:function(c){c=p.event.fix(c||a.event);var d,e,f,g,h,i,j,l,m,n,o=(p._data(this,"events")||{})[c.type]||[],q=o.delegateCount,r=k.call(arguments),s=!c.exclusive&amp;&amp;!c.namespace,t=p.event.special[c.type]||{},u=[];r[0]=c,c.delegateTarget=this;if(t.preDispatch&amp;&amp;t.preDispatch.call(this,c)===!1)return;if(q&amp;&amp;(!c.button||c.type!=="click"))for(f=c.target;f!=this;f=f.parentNode||this)if(f.disabled!==!0||c.type!=="click"){h={},j=[];for(d=0;d&lt;q;d++)l=o[d],m=l.selector,h[m]===b&amp;&amp;(h[m]=l.needsContext?p(m,this).index(f)&gt;=0:p.find(m,this,null,[f]).length),h[m]&amp;&amp;j.push(l);j.length&amp;&amp;u.push({elem:f,matches:j})}o.length&gt;q&amp;&amp;u.push({elem:this,matches:o.slice(q)});for(d=0;d&lt;u.length&amp;&amp;!c.isPropagationStopped();d++){i=u[d],c.currentTarget=i.elem;for(e=0;e&lt;i.matches.length&amp;&amp;!c.isImmediatePropagationStopped();e++){l=i.matches[e];if(s||!c.namespace&amp;&amp;!l.namespace||c.namespace_re&amp;&amp;c.namespace_re.test(l.namespace))c.data=l.data,c.handleObj=l,g=((p.event.special[l.origType]||{}).handle||l.handler).apply(i.elem,r),g!==b&amp;&amp;(c.result=g,g===!1&amp;&amp;(c.preventDefault(),c.stopPropagation()))}}return t.postDispatch&amp;&amp;t.postDispatch.call(this,c),c.result},props:"attrChange attrName relatedNode srcElement altKey bubbles cancelable ctrlKey currentTarget eventPhase metaKey relatedTarget shiftKey target timeStamp view which".split(" "),fixHooks:{},keyHooks:{props:"char charCode key keyCode".split(" "),filter:function(a,b){return a.which==null&amp;&amp;(a.which=b.charCode!=null?b.charCode:b.keyCode),a}},mouseHooks:{props:"button buttons clientX clientY fromElement offsetX offsetY pageX pageY screenX screenY toElement".split(" "),filter:function(a,c){var d,f,g,h=c.button,i=c.fromElement;return a.pageX==null&amp;&amp;c.clientX!=null&amp;&amp;(d=a.target.ownerDocument||e,f=d.documentElement,g=d.body,a.pageX=c.clientX+(f&amp;&amp;f.scrollLeft||g&amp;&amp;g.scrollLeft||0)-(f&amp;&amp;f.clientLeft||g&amp;&amp;g.clientLeft||0),a.pageY=c.clientY+(f&amp;&amp;f.scrollTop||g&amp;&amp;g.scrollTop||0)-(f&amp;&amp;f.clientTop||g&amp;&amp;g.clientTop||0)),!a.relatedTarget&amp;&amp;i&amp;&amp;(a.relatedTarget=i===a.target?c.toElement:i),!a.which&amp;&amp;h!==b&amp;&amp;(a.which=h&amp;1?1:h&amp;2?3:h&amp;4?2:0),a}},fix:function(a){if(a[p.expando])return a;var b,c,d=a,f=p.event.fixHooks[a.type]||{},g=f.props?this.props.concat(f.props):this.props;a=p.Event(d);for(b=g.length;b;)c=g[--b],a[c]=d[c];return a.target||(a.target=d.srcElement||e),a.target.nodeType===3&amp;&amp;(a.target=a.target.parentNode),a.metaKey=!!a.metaKey,f.filter?f.filter(a,d):a},special:{load:{noBubble:!0},focus:{delegateType:"focusin"},blur:{delegateType:"focusout"},beforeunload:{setup:function(a,b,c){p.isWindow(this)&amp;&amp;(this.onbeforeunload=c)},teardown:function(a,b){this.onbeforeunload===b&amp;&amp;(this.onbeforeunload=null)}}},simulate:function(a,b,c,d){var e=p.extend(new p.Event,c,{type:a,isSimulated:!0,originalEvent:{}});d?p.event.trigger(e,null,b):p.event.dispatch.call(b,e),e.isDefaultPrevented()&amp;&amp;c.preventDefault()}},p.event.handle=p.event.dispatch,p.removeEvent=e.removeEventListener?function(a,b,c){a.removeEventListener&amp;&amp;a.removeEventListener(b,c,!1)}:function(a,b,c){var d="on"+b;a.detachEvent&amp;&amp;(typeof a[d]=="undefined"&amp;&amp;(a[d]=null),a.detachEvent(d,c))},p.Event=function(a,b){if(this instanceof p.Event)a&amp;&amp;a.type?(this.originalEvent=a,this.type=a.type,this.isDefaultPrevented=a.defaultPrevented||a.returnValue===!1||a.getPreventDefault&amp;&amp;a.getPreventDefault()?bb:ba):this.type=a,b&amp;&amp;p.extend(this,b),this.timeStamp=a&amp;&amp;a.timeStamp||p.now(),this[p.expando]=!0;else return new p.Event(a,b)},p.Event.prototype={preventDefault:function(){this.isDefaultPrevented=bb;var a=this.originalEvent;if(!a)return;a.preventDefault?a.preventDefault():a.returnValue=!1},stopPropagation:function(){this.isPropagationStopped=bb;var a=this.originalEvent;if(!a)return;a.stopPropagation&amp;&amp;a.stopPropagation(),a.cancelBubble=!0},stopImmediatePropagation:function(){this.isImmediatePropagationStopped=bb,this.stopPropagation()},isDefaultPrevented:ba,isPropagationStopped:ba,isImmediatePropagationStopped:ba},p.each({mouseenter:"mouseover",mouseleave:"mouseout"},function(a,b){p.event.special[a]={delegateType:b,bindType:b,handle:function(a){var c,d=this,e=a.relatedTarget,f=a.handleObj,g=f.selector;if(!e||e!==d&amp;&amp;!p.contains(d,e))a.type=f.origType,c=f.handler.apply(this,arguments),a.type=b;return c}}}),p.support.submitBubbles||(p.event.special.submit={setup:function(){if(p.nodeName(this,"form"))return!1;p.event.add(this,"click._submit keypress._submit",function(a){var c=a.target,d=p.nodeName(c,"input")||p.nodeName(c,"button")?c.form:b;d&amp;&amp;!p._data(d,"_submit_attached")&amp;&amp;(p.event.add(d,"submit._submit",function(a){a._submit_bubble=!0}),p._data(d,"_submit_attached",!0))})},postDispatch:function(a){a._submit_bubble&amp;&amp;(delete a._submit_bubble,this.parentNode&amp;&amp;!a.isTrigger&amp;&amp;p.event.simulate("submit",this.parentNode,a,!0))},teardown:function(){if(p.nodeName(this,"form"))return!1;p.event.remove(this,"._submit")}}),p.support.changeBubbles||(p.event.special.change={setup:function(){if(V.test(this.nodeName)){if(this.type==="checkbox"||this.type==="radio")p.event.add(this,"propertychange._change",function(a){a.originalEvent.propertyName==="checked"&amp;&amp;(this._just_changed=!0)}),p.event.add(this,"click._change",function(a){this._just_changed&amp;&amp;!a.isTrigger&amp;&amp;(this._just_changed=!1),p.event.simulate("change",this,a,!0)});return!1}p.event.add(this,"beforeactivate._change",function(a){var b=a.target;V.test(b.nodeName)&amp;&amp;!p._data(b,"_change_attached")&amp;&amp;(p.event.add(b,"change._change",function(a){this.parentNode&amp;&amp;!a.isSimulated&amp;&amp;!a.isTrigger&amp;&amp;p.event.simulate("change",this.parentNode,a,!0)}),p._data(b,"_change_attached",!0))})},handle:function(a){var b=a.target;if(this!==b||a.isSimulated||a.isTrigger||b.type!=="radio"&amp;&amp;b.type!=="checkbox")return a.handleObj.handler.apply(this,arguments)},teardown:function(){return p.event.remove(this,"._change"),!V.test(this.nodeName)}}),p.support.focusinBubbles||p.each({focus:"focusin",blur:"focusout"},function(a,b){var c=0,d=function(a){p.event.simulate(b,a.target,p.event.fix(a),!0)};p.event.special[b]={setup:function(){c++===0&amp;&amp;e.addEventListener(a,d,!0)},teardown:function(){--c===0&amp;&amp;e.removeEventListener(a,d,!0)}}}),p.fn.extend({on:function(a,c,d,e,f){var g,h;if(typeof a=="object"){typeof c!="string"&amp;&amp;(d=d||c,c=b);for(h in a)this.on(h,c,d,a[h],f);return this}d==null&amp;&amp;e==null?(e=c,d=c=b):e==null&amp;&amp;(typeof c=="string"?(e=d,d=b):(e=d,d=c,c=b));if(e===!1)e=ba;else if(!e)return this;return f===1&amp;&amp;(g=e,e=function(a){return p().off(a),g.apply(this,arguments)},e.guid=g.guid||(g.guid=p.guid++)),this.each(function(){p.event.add(this,a,e,d,c)})},one:function(a,b,c,d){return this.on(a,b,c,d,1)},off:function(a,c,d){var e,f;if(a&amp;&amp;a.preventDefault&amp;&amp;a.handleObj)return e=a.handleObj,p(a.delegateTarget).off(e.namespace?e.origType+"."+e.namespace:e.origType,e.selector,e.handler),this;if(typeof a=="object"){for(f in a)this.off(f,c,a[f]);return this}if(c===!1||typeof c=="function")d=c,c=b;return d===!1&amp;&amp;(d=ba),this.each(function(){p.event.remove(this,a,d,c)})},bind:function(a,b,c){return this.on(a,null,b,c)},unbind:function(a,b){return this.off(a,null,b)},live:function(a,b,c){return p(this.context).on(a,this.selector,b,c),this},die:function(a,b){return p(this.context).off(a,this.selector||"**",b),this},delegate:function(a,b,c,d){return this.on(b,a,c,d)},undelegate:function(a,b,c){return arguments.length===1?this.off(a,"**"):this.off(b,a||"**",c)},trigger:function(a,b){return this.each(function(){p.event.trigger(a,b,this)})},triggerHandler:function(a,b){if(this[0])return p.event.trigger(a,b,this[0],!0)},toggle:function(a){var b=arguments,c=a.guid||p.guid++,d=0,e=function(c){var e=(p._data(this,"lastToggle"+a.guid)||0)%d;return p._data(this,"lastToggle"+a.guid,e+1),c.preventDefault(),b[e].apply(this,arguments)||!1};e.guid=c;while(d&lt;b.length)b[d++].guid=c;return this.click(e)},hover:function(a,b){return this.mouseenter(a).mouseleave(b||a)}}),p.each("blur focus focusin focusout load resize scroll unload click dblclick mousedown mouseup mousemove mouseover mouseout mouseenter mouseleave change select submit keydown keypress keyup error contextmenu".split(" "),function(a,b){p.fn[b]=function(a,c){return c==null&amp;&amp;(c=a,a=null),arguments.length&gt;0?this.on(b,null,a,c):this.trigger(b)},Y.test(b)&amp;&amp;(p.event.fixHooks[b]=p.event.keyHooks),Z.test(b)&amp;&amp;(p.event.fixHooks[b]=p.event.mouseHooks)}),function(a,b){function bc(a,b,c,d){c=c||[],b=b||r;var e,f,i,j,k=b.nodeType;if(!a||typeof a!="string")return c;if(k!==1&amp;&amp;k!==9)return[];i=g(b);if(!i&amp;&amp;!d)if(e=P.exec(a))if(j=e[1]){if(k===9){f=b.getElementById(j);if(!f||!f.parentNode)return c;if(f.id===j)return c.push(f),c}else if(b.ownerDocument&amp;&amp;(f=b.ownerDocument.getElementById(j))&amp;&amp;h(b,f)&amp;&amp;f.id===j)return c.push(f),c}else{if(e[2])return w.apply(c,x.call(b.getElementsByTagName(a),0)),c;if((j=e[3])&amp;&amp;_&amp;&amp;b.getElementsByClassName)return w.apply(c,x.call(b.getElementsByClassName(j),0)),c}return bp(a.replace(L,"$1"),b,c,d,i)}function bd(a){return function(b){var c=b.nodeName.toLowerCase();return c==="input"&amp;&amp;b.type===a}}function be(a){return function(b){var c=b.nodeName.toLowerCase();return(c==="input"||c==="button")&amp;&amp;b.type===a}}function bf(a){return z(function(b){return b=+b,z(function(c,d){var e,f=a([],c.length,b),g=f.length;while(g--)c[e=f[g]]&amp;&amp;(c[e]=!(d[e]=c[e]))})})}function bg(a,b,c){if(a===b)return c;var d=a.nextSibling;while(d){if(d===b)return-1;d=d.nextSibling}return 1}function bh(a,b){var c,d,f,g,h,i,j,k=C[o][a];if(k)return b?0:k.slice(0);h=a,i=[],j=e.preFilter;while(h){if(!c||(d=M.exec(h)))d&amp;&amp;(h=h.slice(d[0].length)),i.push(f=[]);c=!1;if(d=N.exec(h))f.push(c=new q(d.shift())),h=h.slice(c.length),c.type=d[0].replace(L," ");for(g in e.filter)(d=W[g].exec(h))&amp;&amp;(!j[g]||(d=j[g](d,r,!0)))&amp;&amp;(f.push(c=new q(d.shift())),h=h.slice(c.length),c.type=g,c.matches=d);if(!c)break}return b?h.length:h?bc.error(a):C(a,i).slice(0)}function bi(a,b,d){var e=b.dir,f=d&amp;&amp;b.dir==="parentNode",g=u++;return b.first?function(b,c,d){while(b=b[e])if(f||b.nodeType===1)return a(b,c,d)}:function(b,d,h){if(!h){var i,j=t+" "+g+" ",k=j+c;while(b=b[e])if(f||b.nodeType===1){if((i=b[o])===k)return b.sizset;if(typeof i=="string"&amp;&amp;i.indexOf(j)===0){if(b.sizset)return b}else{b[o]=k;if(a(b,d,h))return b.sizset=!0,b;b.sizset=!1}}}else while(b=b[e])if(f||b.nodeType===1)if(a(b,d,h))return b}}function bj(a){return a.length&gt;1?function(b,c,d){var e=a.length;while(e--)if(!a[e](b,c,d))return!1;return!0}:a[0]}function bk(a,b,c,d,e){var f,g=[],h=0,i=a.length,j=b!=null;for(;h&lt;i;h++)if(f=a[h])if(!c||c(f,d,e))g.push(f),j&amp;&amp;b.push(h);return g}function bl(a,b,c,d,e,f){return d&amp;&amp;!d[o]&amp;&amp;(d=bl(d)),e&amp;&amp;!e[o]&amp;&amp;(e=bl(e,f)),z(function(f,g,h,i){if(f&amp;&amp;e)return;var j,k,l,m=[],n=[],o=g.length,p=f||bo(b||"*",h.nodeType?[h]:h,[],f),q=a&amp;&amp;(f||!b)?bk(p,m,a,h,i):p,r=c?e||(f?a:o||d)?[]:g:q;c&amp;&amp;c(q,r,h,i);if(d){l=bk(r,n),d(l,[],h,i),j=l.length;while(j--)if(k=l[j])r[n[j]]=!(q[n[j]]=k)}if(f){j=a&amp;&amp;r.length;while(j--)if(k=r[j])f[m[j]]=!(g[m[j]]=k)}else r=bk(r===g?r.splice(o,r.length):r),e?e(null,g,r,i):w.apply(g,r)})}function bm(a){var b,c,d,f=a.length,g=e.relative[a[0].type],h=g||e.relative[" "],i=g?1:0,j=bi(function(a){return a===b},h,!0),k=bi(function(a){return y.call(b,a)&gt;-1},h,!0),m=[function(a,c,d){return!g&amp;&amp;(d||c!==l)||((b=c).nodeType?j(a,c,d):k(a,c,d))}];for(;i&lt;f;i++)if(c=e.relative[a[i].type])m=[bi(bj(m),c)];else{c=e.filter[a[i].type].apply(null,a[i].matches);if(c[o]){d=++i;for(;d&lt;f;d++)if(e.relative[a[d].type])break;return bl(i&gt;1&amp;&amp;bj(m),i&gt;1&amp;&amp;a.slice(0,i-1).join("").replace(L,"$1"),c,i&lt;d&amp;&amp;bm(a.slice(i,d)),d&lt;f&amp;&amp;bm(a=a.slice(d)),d&lt;f&amp;&amp;a.join(""))}m.push(c)}return bj(m)}function bn(a,b){var d=b.length&gt;0,f=a.length&gt;0,g=function(h,i,j,k,m){var n,o,p,q=[],s=0,u="0",x=h&amp;&amp;[],y=m!=null,z=l,A=h||f&amp;&amp;e.find.TAG("*",m&amp;&amp;i.parentNode||i),B=t+=z==null?1:Math.E;y&amp;&amp;(l=i!==r&amp;&amp;i,c=g.el);for(;(n=A[u])!=null;u++){if(f&amp;&amp;n){for(o=0;p=a[o];o++)if(p(n,i,j)){k.push(n);break}y&amp;&amp;(t=B,c=++g.el)}d&amp;&amp;((n=!p&amp;&amp;n)&amp;&amp;s--,h&amp;&amp;x.push(n))}s+=u;if(d&amp;&amp;u!==s){for(o=0;p=b[o];o++)p(x,q,i,j);if(h){if(s&gt;0)while(u--)!x[u]&amp;&amp;!q[u]&amp;&amp;(q[u]=v.call(k));q=bk(q)}w.apply(k,q),y&amp;&amp;!h&amp;&amp;q.length&gt;0&amp;&amp;s+b.length&gt;1&amp;&amp;bc.uniqueSort(k)}return y&amp;&amp;(t=B,l=z),x};return g.el=0,d?z(g):g}function bo(a,b,c,d){var e=0,f=b.length;for(;e&lt;f;e++)bc(a,b[e],c,d);return c}function bp(a,b,c,d,f){var g,h,j,k,l,m=bh(a),n=m.length;if(!d&amp;&amp;m.length===1){h=m[0]=m[0].slice(0);if(h.length&gt;2&amp;&amp;(j=h[0]).type==="ID"&amp;&amp;b.nodeType===9&amp;&amp;!f&amp;&amp;e.relative[h[1].type]){b=e.find.ID(j.matches[0].replace(V,""),b,f)[0];if(!b)return c;a=a.slice(h.shift().length)}for(g=W.POS.test(a)?-1:h.length-1;g&gt;=0;g--){j=h[g];if(e.relative[k=j.type])break;if(l=e.find[k])if(d=l(j.matches[0].replace(V,""),R.test(h[0].type)&amp;&amp;b.parentNode||b,f)){h.splice(g,1),a=d.length&amp;&amp;h.join("");if(!a)return w.apply(c,x.call(d,0)),c;break}}}return i(a,m)(d,b,f,c,R.test(a)),c}function bq(){}var c,d,e,f,g,h,i,j,k,l,m=!0,n="undefined",o=("sizcache"+Math.random()).replace(".",""),q=String,r=a.document,s=r.documentElement,t=0,u=0,v=[].pop,w=[].push,x=[].slice,y=[].indexOf||function(a){var b=0,c=this.length;for(;b&lt;c;b++)if(this[b]===a)return b;return-1},z=function(a,b){return a[o]=b==null||b,a},A=function(){var a={},b=[];return z(function(c,d){return b.push(c)&gt;e.cacheLength&amp;&amp;delete a[b.shift()],a[c]=d},a)},B=A(),C=A(),D=A(),E="[\\x20\\t\\r\\n\\f]",F="(?:\\\\.|[-\\w]|[^\\x00-\\xa0])+",G=F.replace("w","w#"),H="([*^$|!~]?=)",I="\\["+E+"*("+F+")"+E+"*(?:"+H+E+"*(?:(['\"])((?:\\\\.|[^\\\\])*?)\\3|("+G+")|)|)"+E+"*\\]",J=":("+F+")(?:\\((?:(['\"])((?:\\\\.|[^\\\\])*?)\\2|([^()[\\]]*|(?:(?:"+I+")|[^:]|\\\\.)*|.*))\\)|)",K=":(even|odd|eq|gt|lt|nth|first|last)(?:\\("+E+"*((?:-\\d)?\\d*)"+E+"*\\)|)(?=[^-]|$)",L=new RegExp("^"+E+"+|((?:^|[^\\\\])(?:\\\\.)*)"+E+"+$","g"),M=new RegExp("^"+E+"*,"+E+"*"),N=new RegExp("^"+E+"*([\\x20\\t\\r\\n\\f&gt;+~])"+E+"*"),O=new RegExp(J),P=/^(?:#([\w\-]+)|(\w+)|\.([\w\-]+))$/,Q=/^:not/,R=/[\x20\t\r\n\f]*[+~]/,S=/:not\($/,T=/h\d/i,U=/input|select|textarea|button/i,V=/\\(?!\\)/g,W={ID:new RegExp("^#("+F+")"),CLASS:new RegExp("^\\.("+F+")"),NAME:new RegExp("^\\[name=['\"]?("+F+")['\"]?\\]"),TAG:new RegExp("^("+F.replace("w","w*")+")"),ATTR:new RegExp("^"+I),PSEUDO:new RegExp("^"+J),POS:new RegExp(K,"i"),CHILD:new RegExp("^:(only|nth|first|last)-child(?:\\("+E+"*(even|odd|(([+-]|)(\\d*)n|)"+E+"*(?:([+-]|)"+E+"*(\\d+)|))"+E+"*\\)|)","i"),needsContext:new RegExp("^"+E+"*[&gt;+~]|"+K,"i")},X=function(a){var b=r.createElement("div");try{return a(b)}catch(c){return!1}finally{b=null}},Y=X(function(a){return a.appendChild(r.createComment("")),!a.getElementsByTagName("*").length}),Z=X(function(a){return a.innerHTML="&lt;a href='#'&gt;&lt;/a&gt;",a.firstChild&amp;&amp;typeof a.firstChild.getAttribute!==n&amp;&amp;a.firstChild.getAttribute("href")==="#"}),$=X(function(a){a.innerHTML="&lt;select&gt;&lt;/select&gt;";var b=typeof a.lastChild.getAttribute("multiple");return b!=="boolean"&amp;&amp;b!=="string"}),_=X(function(a){return a.innerHTML="&lt;div class='hidden e'&gt;&lt;/div&gt;&lt;div class='hidden'&gt;&lt;/div&gt;",!a.getElementsByClassName||!a.getElementsByClassName("e").length?!1:(a.lastChild.className="e",a.getElementsByClassName("e").length===2)}),ba=X(function(a){a.id=o+0,a.innerHTML="&lt;a name='"+o+"'&gt;&lt;/a&gt;&lt;div name='"+o+"'&gt;&lt;/div&gt;",s.insertBefore(a,s.firstChild);var b=r.getElementsByName&amp;&amp;r.getElementsByName(o).length===2+r.getElementsByName(o+0).length;return d=!r.getElementById(o),s.removeChild(a),b});try{x.call(s.childNodes,0)[0].nodeType}catch(bb){x=function(a){var b,c=[];for(;b=this[a];a++)c.push(b);return c}}bc.matches=function(a,b){return bc(a,null,null,b)},bc.matchesSelector=function(a,b){return bc(b,null,null,[a]).length&gt;0},f=bc.getText=function(a){var b,c="",d=0,e=a.nodeType;if(e){if(e===1||e===9||e===11){if(typeof a.textContent=="string")return a.textContent;for(a=a.firstChild;a;a=a.nextSibling)c+=f(a)}else if(e===3||e===4)return a.nodeValue}else for(;b=a[d];d++)c+=f(b);return c},g=bc.isXML=function(a){var b=a&amp;&amp;(a.ownerDocument||a).documentElement;return b?b.nodeName!=="HTML":!1},h=bc.contains=s.contains?function(a,b){var c=a.nodeType===9?a.documentElement:a,d=b&amp;&amp;b.parentNode;return a===d||!!(d&amp;&amp;d.nodeType===1&amp;&amp;c.contains&amp;&amp;c.contains(d))}:s.compareDocumentPosition?function(a,b){return b&amp;&amp;!!(a.compareDocumentPosition(b)&amp;16)}:function(a,b){while(b=b.parentNode)if(b===a)return!0;return!1},bc.attr=function(a,b){var c,d=g(a);return d||(b=b.toLowerCase()),(c=e.attrHandle[b])?c(a):d||$?a.getAttribute(b):(c=a.getAttributeNode(b),c?typeof a[b]=="boolean"?a[b]?b:null:c.specified?c.value:null:null)},e=bc.selectors={cacheLength:50,createPseudo:z,match:W,attrHandle:Z?{}:{href:function(a){return a.getAttribute("href",2)},type:function(a){return a.getAttribute("type")}},find:{ID:d?function(a,b,c){if(typeof b.getElementById!==n&amp;&amp;!c){var d=b.getElementById(a);return d&amp;&amp;d.parentNode?[d]:[]}}:function(a,c,d){if(typeof c.getElementById!==n&amp;&amp;!d){var e=c.getElementById(a);return e?e.id===a||typeof e.getAttributeNode!==n&amp;&amp;e.getAttributeNode("id").value===a?[e]:b:[]}},TAG:Y?function(a,b){if(typeof b.getElementsByTagName!==n)return b.getElementsByTagName(a)}:function(a,b){var c=b.getElementsByTagName(a);if(a==="*"){var d,e=[],f=0;for(;d=c[f];f++)d.nodeType===1&amp;&amp;e.push(d);return e}return c},NAME:ba&amp;&amp;function(a,b){if(typeof b.getElementsByName!==n)return b.getElementsByName(name)},CLASS:_&amp;&amp;function(a,b,c){if(typeof b.getElementsByClassName!==n&amp;&amp;!c)return b.getElementsByClassName(a)}},relative:{"&gt;":{dir:"parentNode",first:!0}," ":{dir:"parentNode"},"+":{dir:"previousSibling",first:!0},"~":{dir:"previousSibling"}},preFilter:{ATTR:function(a){return a[1]=a[1].replace(V,""),a[3]=(a[4]||a[5]||"").replace(V,""),a[2]==="~="&amp;&amp;(a[3]=" "+a[3]+" "),a.slice(0,4)},CHILD:function(a){return a[1]=a[1].toLowerCase(),a[1]==="nth"?(a[2]||bc.error(a[0]),a[3]=+(a[3]?a[4]+(a[5]||1):2*(a[2]==="even"||a[2]==="odd")),a[4]=+(a[6]+a[7]||a[2]==="odd")):a[2]&amp;&amp;bc.error(a[0]),a},PSEUDO:function(a){var b,c;if(W.CHILD.test(a[0]))return null;if(a[3])a[2]=a[3];else if(b=a[4])O.test(b)&amp;&amp;(c=bh(b,!0))&amp;&amp;(c=b.indexOf(")",b.length-c)-b.length)&amp;&amp;(b=b.slice(0,c),a[0]=a[0].slice(0,c)),a[2]=b;return a.slice(0,3)}},filter:{ID:d?function(a){return a=a.replace(V,""),function(b){return b.getAttribute("id")===a}}:function(a){return a=a.replace(V,""),function(b){var c=typeof b.getAttributeNode!==n&amp;&amp;b.getAttributeNode("id");return c&amp;&amp;c.value===a}},TAG:function(a){return a==="*"?function(){return!0}:(a=a.replace(V,"").toLowerCase(),function(b){return b.nodeName&amp;&amp;b.nodeName.toLowerCase()===a})},CLASS:function(a){var b=B[o][a];return b||(b=B(a,new RegExp("(^|"+E+")"+a+"("+E+"|$)"))),function(a){return b.test(a.className||typeof a.getAttribute!==n&amp;&amp;a.getAttribute("class")||"")}},ATTR:function(a,b,c){return function(d,e){var f=bc.attr(d,a);return f==null?b==="!=":b?(f+="",b==="="?f===c:b==="!="?f!==c:b==="^="?c&amp;&amp;f.indexOf(c)===0:b==="*="?c&amp;&amp;f.indexOf(c)&gt;-1:b==="$="?c&amp;&amp;f.substr(f.length-c.length)===c:b==="~="?(" "+f+" ").indexOf(c)&gt;-1:b==="|="?f===c||f.substr(0,c.length+1)===c+"-":!1):!0}},CHILD:function(a,b,c,d){return a==="nth"?function(a){var b,e,f=a.parentNode;if(c===1&amp;&amp;d===0)return!0;if(f){e=0;for(b=f.firstChild;b;b=b.nextSibling)if(b.nodeType===1){e++;if(a===b)break}}return e-=d,e===c||e%c===0&amp;&amp;e/c&gt;=0}:function(b){var c=b;switch(a){case"only":case"first":while(c=c.previousSibling)if(c.nodeType===1)return!1;if(a==="first")return!0;c=b;case"last":while(c=c.nextSibling)if(c.nodeType===1)return!1;return!0}}},PSEUDO:function(a,b){var c,d=e.pseudos[a]||e.setFilters[a.toLowerCase()]||bc.error("unsupported pseudo: "+a);return d[o]?d(b):d.length&gt;1?(c=[a,a,"",b],e.setFilters.hasOwnProperty(a.toLowerCase())?z(function(a,c){var e,f=d(a,b),g=f.length;while(g--)e=y.call(a,f[g]),a[e]=!(c[e]=f[g])}):function(a){return d(a,0,c)}):d}},pseudos:{not:z(function(a){var b=[],c=[],d=i(a.replace(L,"$1"));return d[o]?z(function(a,b,c,e){var f,g=d(a,null,e,[]),h=a.length;while(h--)if(f=g[h])a[h]=!(b[h]=f)}):function(a,e,f){return b[0]=a,d(b,null,f,c),!c.pop()}}),has:z(function(a){return function(b){return bc(a,b).length&gt;0}}),contains:z(function(a){return function(b){return(b.textContent||b.innerText||f(b)).indexOf(a)&gt;-1}}),enabled:function(a){return a.disabled===!1},disabled:function(a){return a.disabled===!0},checked:function(a){var b=a.nodeName.toLowerCase();return b==="input"&amp;&amp;!!a.checked||b==="option"&amp;&amp;!!a.selected},selected:function(a){return a.parentNode&amp;&amp;a.parentNode.selectedIndex,a.selected===!0},parent:function(a){return!e.pseudos.empty(a)},empty:function(a){var b;a=a.firstChild;while(a){if(a.nodeName&gt;"@"||(b=a.nodeType)===3||b===4)return!1;a=a.nextSibling}return!0},header:function(a){return T.test(a.nodeName)},text:function(a){var b,c;return a.nodeName.toLowerCase()==="input"&amp;&amp;(b=a.type)==="text"&amp;&amp;((c=a.getAttribute("type"))==null||c.toLowerCase()===b)},radio:bd("radio"),checkbox:bd("checkbox"),file:bd("file"),password:bd("password"),image:bd("image"),submit:be("submit"),reset:be("reset"),button:function(a){var b=a.nodeName.toLowerCase();return b==="input"&amp;&amp;a.type==="button"||b==="button"},input:function(a){return U.test(a.nodeName)},focus:function(a){var b=a.ownerDocument;return a===b.activeElement&amp;&amp;(!b.hasFocus||b.hasFocus())&amp;&amp;(!!a.type||!!a.href)},active:function(a){return a===a.ownerDocument.activeElement},first:bf(function(a,b,c){return[0]}),last:bf(function(a,b,c){return[b-1]}),eq:bf(function(a,b,c){return[c&lt;0?c+b:c]}),even:bf(function(a,b,c){for(var d=0;d&lt;b;d+=2)a.push(d);return a}),odd:bf(function(a,b,c){for(var d=1;d&lt;b;d+=2)a.push(d);return a}),lt:bf(function(a,b,c){for(var d=c&lt;0?c+b:c;--d&gt;=0;)a.push(d);return a}),gt:bf(function(a,b,c){for(var d=c&lt;0?c+b:c;++d&lt;b;)a.push(d);return a})}},j=s.compareDocumentPosition?function(a,b){return a===b?(k=!0,0):(!a.compareDocumentPosition||!b.compareDocumentPosition?a.compareDocumentPosition:a.compareDocumentPosition(b)&amp;4)?-1:1}:function(a,b){if(a===b)return k=!0,0;if(a.sourceIndex&amp;&amp;b.sourceIndex)return a.sourceIndex-b.sourceIndex;var c,d,e=[],f=[],g=a.parentNode,h=b.parentNode,i=g;if(g===h)return bg(a,b);if(!g)return-1;if(!h)return 1;while(i)e.unshift(i),i=i.parentNode;i=h;while(i)f.unshift(i),i=i.parentNode;c=e.length,d=f.length;for(var j=0;j&lt;c&amp;&amp;j&lt;d;j++)if(e[j]!==f[j])return bg(e[j],f[j]);return j===c?bg(a,f[j],-1):bg(e[j],b,1)},[0,0].sort(j),m=!k,bc.uniqueSort=function(a){var b,c=1;k=m,a.sort(j);if(k)for(;b=a[c];c++)b===a[c-1]&amp;&amp;a.splice(c--,1);return a},bc.error=function(a){throw new Error("Syntax error, unrecognized expression: "+a)},i=bc.compile=function(a,b){var c,d=[],e=[],f=D[o][a];if(!f){b||(b=bh(a)),c=b.length;while(c--)f=bm(b[c]),f[o]?d.push(f):e.push(f);f=D(a,bn(e,d))}return f},r.querySelectorAll&amp;&amp;function(){var a,b=bp,c=/'|\\/g,d=/\=[\x20\t\r\n\f]*([^'"\]]*)[\x20\t\r\n\f]*\]/g,e=[":focus"],f=[":active",":focus"],h=s.matchesSelector||s.mozMatchesSelector||s.webkitMatchesSelector||s.oMatchesSelector||s.msMatchesSelector;X(function(a){a.innerHTML="&lt;select&gt;&lt;option selected=''&gt;&lt;/option&gt;&lt;/select&gt;",a.querySelectorAll("[selected]").length||e.push("\\["+E+"*(?:checked|disabled|ismap|multiple|readonly|selected|value)"),a.querySelectorAll(":checked").length||e.push(":checked")}),X(function(a){a.innerHTML="&lt;p test=''&gt;&lt;/p&gt;",a.querySelectorAll("[test^='']").length&amp;&amp;e.push("[*^$]="+E+"*(?:\"\"|'')"),a.innerHTML="&lt;input type='hidden'/&gt;",a.querySelectorAll(":enabled").length||e.push(":enabled",":disabled")}),e=new RegExp(e.join("|")),bp=function(a,d,f,g,h){if(!g&amp;&amp;!h&amp;&amp;(!e||!e.test(a))){var i,j,k=!0,l=o,m=d,n=d.nodeType===9&amp;&amp;a;if(d.nodeType===1&amp;&amp;d.nodeName.toLowerCase()!=="object"){i=bh(a),(k=d.getAttribute("id"))?l=k.replace(c,"\\$&amp;"):d.setAttribute("id",l),l="[id='"+l+"'] ",j=i.length;while(j--)i[j]=l+i[j].join("");m=R.test(a)&amp;&amp;d.parentNode||d,n=i.join(",")}if(n)try{return w.apply(f,x.call(m.querySelectorAll(n),0)),f}catch(p){}finally{k||d.removeAttribute("id")}}return b(a,d,f,g,h)},h&amp;&amp;(X(function(b){a=h.call(b,"div");try{h.call(b,"[test!='']:sizzle"),f.push("!=",J)}catch(c){}}),f=new RegExp(f.join("|")),bc.matchesSelector=function(b,c){c=c.replace(d,"='$1']");if(!g(b)&amp;&amp;!f.test(c)&amp;&amp;(!e||!e.test(c)))try{var i=h.call(b,c);if(i||a||b.document&amp;&amp;b.document.nodeType!==11)return i}catch(j){}return bc(c,null,null,[b]).length&gt;0})}(),e.pseudos.nth=e.pseudos.eq,e.filters=bq.prototype=e.pseudos,e.setFilters=new bq,bc.attr=p.attr,p.find=bc,p.expr=bc.selectors,p.expr[":"]=p.expr.pseudos,p.unique=bc.uniqueSort,p.text=bc.getText,p.isXMLDoc=bc.isXML,p.contains=bc.contains}(a);var bc=/Until$/,bd=/^(?:parents|prev(?:Until|All))/,be=/^.[^:#\[\.,]*$/,bf=p.expr.match.needsContext,bg={children:!0,contents:!0,next:!0,prev:!0};p.fn.extend({find:function(a){var b,c,d,e,f,g,h=this;if(typeof a!="string")return p(a).filter(function(){for(b=0,c=h.length;b&lt;c;b++)if(p.contains(h[b],this))return!0});g=this.pushStack("","find",a);for(b=0,c=this.length;b&lt;c;b++){d=g.length,p.find(a,this[b],g);if(b&gt;0)for(e=d;e&lt;g.length;e++)for(f=0;f&lt;d;f++)if(g[f]===g[e]){g.splice(e--,1);break}}return g},has:function(a){var b,c=p(a,this),d=c.length;return this.filter(function(){for(b=0;b&lt;d;b++)if(p.contains(this,c[b]))return!0})},not:function(a){return this.pushStack(bj(this,a,!1),"not",a)},filter:function(a){return this.pushStack(bj(this,a,!0),"filter",a)},is:function(a){return!!a&amp;&amp;(typeof a=="string"?bf.test(a)?p(a,this.context).index(this[0])&gt;=0:p.filter(a,this).length&gt;0:this.filter(a).length&gt;0)},closest:function(a,b){var c,d=0,e=this.length,f=[],g=bf.test(a)||typeof a!="string"?p(a,b||this.context):0;for(;d&lt;e;d++){c=this[d];while(c&amp;&amp;c.ownerDocument&amp;&amp;c!==b&amp;&amp;c.nodeType!==11){if(g?g.index(c)&gt;-1:p.find.matchesSelector(c,a)){f.push(c);break}c=c.parentNode}}return f=f.length&gt;1?p.unique(f):f,this.pushStack(f,"closest",a)},index:function(a){return a?typeof a=="string"?p.inArray(this[0],p(a)):p.inArray(a.jquery?a[0]:a,this):this[0]&amp;&amp;this[0].parentNode?this.prevAll().length:-1},add:function(a,b){var c=typeof a=="string"?p(a,b):p.makeArray(a&amp;&amp;a.nodeType?[a]:a),d=p.merge(this.get(),c);return this.pushStack(bh(c[0])||bh(d[0])?d:p.unique(d))},addBack:function(a){return this.add(a==null?this.prevObject:this.prevObject.filter(a))}}),p.fn.andSelf=p.fn.addBack,p.each({parent:function(a){var b=a.parentNode;return b&amp;&amp;b.nodeType!==11?b:null},parents:function(a){return p.dir(a,"parentNode")},parentsUntil:function(a,b,c){return p.dir(a,"parentNode",c)},next:function(a){return bi(a,"nextSibling")},prev:function(a){return bi(a,"previousSibling")},nextAll:function(a){return p.dir(a,"nextSibling")},prevAll:function(a){return p.dir(a,"previousSibling")},nextUntil:function(a,b,c){return p.dir(a,"nextSibling",c)},prevUntil:function(a,b,c){return p.dir(a,"previousSibling",c)},siblings:function(a){return p.sibling((a.parentNode||{}).firstChild,a)},children:function(a){return p.sibling(a.firstChild)},contents:function(a){return p.nodeName(a,"iframe")?a.contentDocument||a.contentWindow.document:p.merge([],a.childNodes)}},function(a,b){p.fn[a]=function(c,d){var e=p.map(this,b,c);return bc.test(a)||(d=c),d&amp;&amp;typeof d=="string"&amp;&amp;(e=p.filter(d,e)),e=this.length&gt;1&amp;&amp;!bg[a]?p.unique(e):e,this.length&gt;1&amp;&amp;bd.test(a)&amp;&amp;(e=e.reverse()),this.pushStack(e,a,k.call(arguments).join(","))}}),p.extend({filter:function(a,b,c){return c&amp;&amp;(a=":not("+a+")"),b.length===1?p.find.matchesSelector(b[0],a)?[b[0]]:[]:p.find.matches(a,b)},dir:function(a,c,d){var e=[],f=a[c];while(f&amp;&amp;f.nodeType!==9&amp;&amp;(d===b||f.nodeType!==1||!p(f).is(d)))f.nodeType===1&amp;&amp;e.push(f),f=f[c];return e},sibling:function(a,b){var c=[];for(;a;a=a.nextSibling)a.nodeType===1&amp;&amp;a!==b&amp;&amp;c.push(a);return c}});var bl="abbr|article|aside|audio|bdi|canvas|data|datalist|details|figcaption|figure|footer|header|hgroup|mark|meter|nav|output|progress|section|summary|time|video",bm=/ jQuery\d+="(?:null|\d+)"/g,bn=/^\s+/,bo=/&lt;(?!area|br|col|embed|hr|img|input|link|meta|param)(([\w:]+)[^&gt;]*)\/&gt;/gi,bp=/&lt;([\w:]+)/,bq=/&lt;tbody/i,br=/&lt;|&amp;#?\w+;/,bs=/&lt;(?:script|style|link)/i,bt=/&lt;(?:script|object|embed|option|style)/i,bu=new RegExp("&lt;(?:"+bl+")[\\s/&gt;]","i"),bv=/^(?:checkbox|radio)$/,bw=/checked\s*(?:[^=]|=\s*.checked.)/i,bx=/\/(java|ecma)script/i,by=/^\s*&lt;!(?:\[CDATA\[|\-\-)|[\]\-]{2}&gt;\s*$/g,bz={option:[1,"&lt;select multiple='multiple'&gt;","&lt;/select&gt;"],legend:[1,"&lt;fieldset&gt;","&lt;/fieldset&gt;"],thead:[1,"&lt;table&gt;","&lt;/table&gt;"],tr:[2,"&lt;table&gt;&lt;tbody&gt;","&lt;/tbody&gt;&lt;/table&gt;"],td:[3,"&lt;table&gt;&lt;tbody&gt;&lt;tr&gt;","&lt;/tr&gt;&lt;/tbody&gt;&lt;/table&gt;"],col:[2,"&lt;table&gt;&lt;tbody&gt;&lt;/tbody&gt;&lt;colgroup&gt;","&lt;/colgroup&gt;&lt;/table&gt;"],area:[1,"&lt;map&gt;","&lt;/map&gt;"],_default:[0,"",""]},bA=bk(e),bB=bA.appendChild(e.createElement("div"));bz.optgroup=bz.option,bz.tbody=bz.tfoot=bz.colgroup=bz.caption=bz.thead,bz.th=bz.td,p.support.htmlSerialize||(bz._default=[1,"X&lt;div&gt;","&lt;/div&gt;"]),p.fn.extend({text:function(a){return p.access(this,function(a){return a===b?p.text(this):this.empty().append((this[0]&amp;&amp;this[0].ownerDocument||e).createTextNode(a))},null,a,arguments.length)},wrapAll:function(a){if(p.isFunction(a))return this.each(function(b){p(this).wrapAll(a.call(this,b))});if(this[0]){var b=p(a,this[0].ownerDocument).eq(0).clone(!0);this[0].parentNode&amp;&amp;b.insertBefore(this[0]),b.map(function(){var a=this;while(a.firstChild&amp;&amp;a.firstChild.nodeType===1)a=a.firstChild;return a}).append(this)}return this},wrapInner:function(a){return p.isFunction(a)?this.each(function(b){p(this).wrapInner(a.call(this,b))}):this.each(function(){var b=p(this),c=b.contents();c.length?c.wrapAll(a):b.append(a)})},wrap:function(a){var b=p.isFunction(a);return this.each(function(c){p(this).wrapAll(b?a.call(this,c):a)})},unwrap:function(){return this.parent().each(function(){p.nodeName(this,"body")||p(this).replaceWith(this.childNodes)}).end()},append:function(){return this.domManip(arguments,!0,function(a){(this.nodeType===1||this.nodeType===11)&amp;&amp;this.appendChild(a)})},prepend:function(){return this.domManip(arguments,!0,function(a){(this.nodeType===1||this.nodeType===11)&amp;&amp;this.insertBefore(a,this.firstChild)})},before:function(){if(!bh(this[0]))return this.domManip(arguments,!1,function(a){this.parentNode.insertBefore(a,this)});if(arguments.length){var a=p.clean(arguments);return this.pushStack(p.merge(a,this),"before",this.selector)}},after:function(){if(!bh(this[0]))return this.domManip(arguments,!1,function(a){this.parentNode.insertBefore(a,this.nextSibling)});if(arguments.length){var a=p.clean(arguments);return this.pushStack(p.merge(this,a),"after",this.selector)}},remove:function(a,b){var c,d=0;for(;(c=this[d])!=null;d++)if(!a||p.filter(a,[c]).length)!b&amp;&amp;c.nodeType===1&amp;&amp;(p.cleanData(c.getElementsByTagName("*")),p.cleanData([c])),c.parentNode&amp;&amp;c.parentNode.removeChild(c);return this},empty:function(){var a,b=0;for(;(a=this[b])!=null;b++){a.nodeType===1&amp;&amp;p.cleanData(a.getElementsByTagName("*"));while(a.firstChild)a.removeChild(a.firstChild)}return this},clone:function(a,b){return a=a==null?!1:a,b=b==null?a:b,this.map(function(){return p.clone(this,a,b)})},html:function(a){return p.access(this,function(a){var c=this[0]||{},d=0,e=this.length;if(a===b)return c.nodeType===1?c.innerHTML.replace(bm,""):b;if(typeof a=="string"&amp;&amp;!bs.test(a)&amp;&amp;(p.support.htmlSerialize||!bu.test(a))&amp;&amp;(p.support.leadingWhitespace||!bn.test(a))&amp;&amp;!bz[(bp.exec(a)||["",""])[1].toLowerCase()]){a=a.replace(bo,"&lt;$1&gt;&lt;/$2&gt;");try{for(;d&lt;e;d++)c=this[d]||{},c.nodeType===1&amp;&amp;(p.cleanData(c.getElementsByTagName("*")),c.innerHTML=a);c=0}catch(f){}}c&amp;&amp;this.empty().append(a)},null,a,arguments.length)},replaceWith:function(a){return bh(this[0])?this.length?this.pushStack(p(p.isFunction(a)?a():a),"replaceWith",a):this:p.isFunction(a)?this.each(function(b){var c=p(this),d=c.html();c.replaceWith(a.call(this,b,d))}):(typeof a!="string"&amp;&amp;(a=p(a).detach()),this.each(function(){var b=this.nextSibling,c=this.parentNode;p(this).remove(),b?p(b).before(a):p(c).append(a)}))},detach:function(a){return this.remove(a,!0)},domManip:function(a,c,d){a=[].concat.apply([],a);var e,f,g,h,i=0,j=a[0],k=[],l=this.length;if(!p.support.checkClone&amp;&amp;l&gt;1&amp;&amp;typeof j=="string"&amp;&amp;bw.test(j))return this.each(function(){p(this).domManip(a,c,d)});if(p.isFunction(j))return this.each(function(e){var f=p(this);a[0]=j.call(this,e,c?f.html():b),f.domManip(a,c,d)});if(this[0]){e=p.buildFragment(a,this,k),g=e.fragment,f=g.firstChild,g.childNodes.length===1&amp;&amp;(g=f);if(f){c=c&amp;&amp;p.nodeName(f,"tr");for(h=e.cacheable||l-1;i&lt;l;i++)d.call(c&amp;&amp;p.nodeName(this[i],"table")?bC(this[i],"tbody"):this[i],i===h?g:p.clone(g,!0,!0))}g=f=null,k.length&amp;&amp;p.each(k,function(a,b){b.src?p.ajax?p.ajax({url:b.src,type:"GET",dataType:"script",async:!1,global:!1,"throws":!0}):p.error("no ajax"):p.globalEval((b.text||b.textContent||b.innerHTML||"").replace(by,"")),b.parentNode&amp;&amp;b.parentNode.removeChild(b)})}return this}}),p.buildFragment=function(a,c,d){var f,g,h,i=a[0];return c=c||e,c=!c.nodeType&amp;&amp;c[0]||c,c=c.ownerDocument||c,a.length===1&amp;&amp;typeof i=="string"&amp;&amp;i.length&lt;512&amp;&amp;c===e&amp;&amp;i.charAt(0)==="&lt;"&amp;&amp;!bt.test(i)&amp;&amp;(p.support.checkClone||!bw.test(i))&amp;&amp;(p.support.html5Clone||!bu.test(i))&amp;&amp;(g=!0,f=p.fragments[i],h=f!==b),f||(f=c.createDocumentFragment(),p.clean(a,c,f,d),g&amp;&amp;(p.fragments[i]=h&amp;&amp;f)),{fragment:f,cacheable:g}},p.fragments={},p.each({appendTo:"append",prependTo:"prepend",insertBefore:"before",insertAfter:"after",replaceAll:"replaceWith"},function(a,b){p.fn[a]=function(c){var d,e=0,f=[],g=p(c),h=g.length,i=this.length===1&amp;&amp;this[0].parentNode;if((i==null||i&amp;&amp;i.nodeType===11&amp;&amp;i.childNodes.length===1)&amp;&amp;h===1)return g[b](this[0]),this;for(;e&lt;h;e++)d=(e&gt;0?this.clone(!0):this).get(),p(g[e])[b](d),f=f.concat(d);return this.pushStack(f,a,g.selector)}}),p.extend({clone:function(a,b,c){var d,e,f,g;p.support.html5Clone||p.isXMLDoc(a)||!bu.test("&lt;"+a.nodeName+"&gt;")?g=a.cloneNode(!0):(bB.innerHTML=a.outerHTML,bB.removeChild(g=bB.firstChild));if((!p.support.noCloneEvent||!p.support.noCloneChecked)&amp;&amp;(a.nodeType===1||a.nodeType===11)&amp;&amp;!p.isXMLDoc(a)){bE(a,g),d=bF(a),e=bF(g);for(f=0;d[f];++f)e[f]&amp;&amp;bE(d[f],e[f])}if(b){bD(a,g);if(c){d=bF(a),e=bF(g);for(f=0;d[f];++f)bD(d[f],e[f])}}return d=e=null,g},clean:function(a,b,c,d){var f,g,h,i,j,k,l,m,n,o,q,r,s=b===e&amp;&amp;bA,t=[];if(!b||typeof b.createDocumentFragment=="undefined")b=e;for(f=0;(h=a[f])!=null;f++){typeof h=="number"&amp;&amp;(h+="");if(!h)continue;if(typeof h=="string")if(!br.test(h))h=b.createTextNode(h);else{s=s||bk(b),l=b.createElement("div"),s.appendChild(l),h=h.replace(bo,"&lt;$1&gt;&lt;/$2&gt;"),i=(bp.exec(h)||["",""])[1].toLowerCase(),j=bz[i]||bz._default,k=j[0],l.innerHTML=j[1]+h+j[2];while(k--)l=l.lastChild;if(!p.support.tbody){m=bq.test(h),n=i==="table"&amp;&amp;!m?l.firstChild&amp;&amp;l.firstChild.childNodes:j[1]==="&lt;table&gt;"&amp;&amp;!m?l.childNodes:[];for(g=n.length-1;g&gt;=0;--g)p.nodeName(n[g],"tbody")&amp;&amp;!n[g].childNodes.length&amp;&amp;n[g].parentNode.removeChild(n[g])}!p.support.leadingWhitespace&amp;&amp;bn.test(h)&amp;&amp;l.insertBefore(b.createTextNode(bn.exec(h)[0]),l.firstChild),h=l.childNodes,l.parentNode.removeChild(l)}h.nodeType?t.push(h):p.merge(t,h)}l&amp;&amp;(h=l=s=null);if(!p.support.appendChecked)for(f=0;(h=t[f])!=null;f++)p.nodeName(h,"input")?bG(h):typeof h.getElementsByTagName!="undefined"&amp;&amp;p.grep(h.getElementsByTagName("input"),bG);if(c){q=function(a){if(!a.type||bx.test(a.type))return d?d.push(a.parentNode?a.parentNode.removeChild(a):a):c.appendChild(a)};for(f=0;(h=t[f])!=null;f++)if(!p.nodeName(h,"script")||!q(h))c.appendChild(h),typeof h.getElementsByTagName!="undefined"&amp;&amp;(r=p.grep(p.merge([],h.getElementsByTagName("script")),q),t.splice.apply(t,[f+1,0].concat(r)),f+=r.length)}return t},cleanData:function(a,b){var c,d,e,f,g=0,h=p.expando,i=p.cache,j=p.support.deleteExpando,k=p.event.special;for(;(e=a[g])!=null;g++)if(b||p.acceptData(e)){d=e[h],c=d&amp;&amp;i[d];if(c){if(c.events)for(f in c.events)k[f]?p.event.remove(e,f):p.removeEvent(e,f,c.handle);i[d]&amp;&amp;(delete i[d],j?delete e[h]:e.removeAttribute?e.removeAttribute(h):e[h]=null,p.deletedIds.push(d))}}}}),function(){var a,b;p.uaMatch=function(a){a=a.toLowerCase();var b=/(chrome)[ \/]([\w.]+)/.exec(a)||/(webkit)[ \/]([\w.]+)/.exec(a)||/(opera)(?:.*version|)[ \/]([\w.]+)/.exec(a)||/(msie) ([\w.]+)/.exec(a)||a.indexOf("compatible")&lt;0&amp;&amp;/(mozilla)(?:.*? rv:([\w.]+)|)/.exec(a)||[];return{browser:b[1]||"",version:b[2]||"0"}},a=p.uaMatch(g.userAgent),b={},a.browser&amp;&amp;(b[a.browser]=!0,b.version=a.version),b.chrome?b.webkit=!0:b.webkit&amp;&amp;(b.safari=!0),p.browser=b,p.sub=function(){function a(b,c){return new a.fn.init(b,c)}p.extend(!0,a,this),a.superclass=this,a.fn=a.prototype=this(),a.fn.constructor=a,a.sub=this.sub,a.fn.init=function c(c,d){return d&amp;&amp;d instanceof p&amp;&amp;!(d instanceof a)&amp;&amp;(d=a(d)),p.fn.init.call(this,c,d,b)},a.fn.init.prototype=a.fn;var b=a(e);return a}}();var bH,bI,bJ,bK=/alpha\([^)]*\)/i,bL=/opacity=([^)]*)/,bM=/^(top|right|bottom|left)$/,bN=/^(none|table(?!-c[ea]).+)/,bO=/^margin/,bP=new RegExp("^("+q+")(.*)$","i"),bQ=new RegExp("^("+q+")(?!px)[a-z%]+$","i"),bR=new RegExp("^([-+])=("+q+")","i"),bS={},bT={position:"absolute",visibility:"hidden",display:"block"},bU={letterSpacing:0,fontWeight:400},bV=["Top","Right","Bottom","Left"],bW=["Webkit","O","Moz","ms"],bX=p.fn.toggle;p.fn.extend({css:function(a,c){return p.access(this,function(a,c,d){return d!==b?p.style(a,c,d):p.css(a,c)},a,c,arguments.length&gt;1)},show:function(){return b$(this,!0)},hide:function(){return b$(this)},toggle:function(a,b){var c=typeof a=="boolean";return p.isFunction(a)&amp;&amp;p.isFunction(b)?bX.apply(this,arguments):this.each(function(){(c?a:bZ(this))?p(this).show():p(this).hide()})}}),p.extend({cssHooks:{opacity:{get:function(a,b){if(b){var c=bH(a,"opacity");return c===""?"1":c}}}},cssNumber:{fillOpacity:!0,fontWeight:!0,lineHeight:!0,opacity:!0,orphans:!0,widows:!0,zIndex:!0,zoom:!0},cssProps:{"float":p.support.cssFloat?"cssFloat":"styleFloat"},style:function(a,c,d,e){if(!a||a.nodeType===3||a.nodeType===8||!a.style)return;var f,g,h,i=p.camelCase(c),j=a.style;c=p.cssProps[i]||(p.cssProps[i]=bY(j,i)),h=p.cssHooks[c]||p.cssHooks[i];if(d===b)return h&amp;&amp;"get"in h&amp;&amp;(f=h.get(a,!1,e))!==b?f:j[c];g=typeof d,g==="string"&amp;&amp;(f=bR.exec(d))&amp;&amp;(d=(f[1]+1)*f[2]+parseFloat(p.css(a,c)),g="number");if(d==null||g==="number"&amp;&amp;isNaN(d))return;g==="number"&amp;&amp;!p.cssNumber[i]&amp;&amp;(d+="px");if(!h||!("set"in h)||(d=h.set(a,d,e))!==b)try{j[c]=d}catch(k){}},css:function(a,c,d,e){var f,g,h,i=p.camelCase(c);return c=p.cssProps[i]||(p.cssProps[i]=bY(a.style,i)),h=p.cssHooks[c]||p.cssHooks[i],h&amp;&amp;"get"in h&amp;&amp;(f=h.get(a,!0,e)),f===b&amp;&amp;(f=bH(a,c)),f==="normal"&amp;&amp;c in bU&amp;&amp;(f=bU[c]),d||e!==b?(g=parseFloat(f),d||p.isNumeric(g)?g||0:f):f},swap:function(a,b,c){var d,e,f={};for(e in b)f[e]=a.style[e],a.style[e]=b[e];d=c.call(a);for(e in b)a.style[e]=f[e];return d}}),a.getComputedStyle?bH=function(b,c){var d,e,f,g,h=a.getComputedStyle(b,null),i=b.style;return h&amp;&amp;(d=h[c],d===""&amp;&amp;!p.contains(b.ownerDocument,b)&amp;&amp;(d=p.style(b,c)),bQ.test(d)&amp;&amp;bO.test(c)&amp;&amp;(e=i.width,f=i.minWidth,g=i.maxWidth,i.minWidth=i.maxWidth=i.width=d,d=h.width,i.width=e,i.minWidth=f,i.maxWidth=g)),d}:e.documentElement.currentStyle&amp;&amp;(bH=function(a,b){var c,d,e=a.currentStyle&amp;&amp;a.currentStyle[b],f=a.style;return e==null&amp;&amp;f&amp;&amp;f[b]&amp;&amp;(e=f[b]),bQ.test(e)&amp;&amp;!bM.test(b)&amp;&amp;(c=f.left,d=a.runtimeStyle&amp;&amp;a.runtimeStyle.left,d&amp;&amp;(a.runtimeStyle.left=a.currentStyle.left),f.left=b==="fontSize"?"1em":e,e=f.pixelLeft+"px",f.left=c,d&amp;&amp;(a.runtimeStyle.left=d)),e===""?"auto":e}),p.each(["height","width"],function(a,b){p.cssHooks[b]={get:function(a,c,d){if(c)return a.offsetWidth===0&amp;&amp;bN.test(bH(a,"display"))?p.swap(a,bT,function(){return cb(a,b,d)}):cb(a,b,d)},set:function(a,c,d){return b_(a,c,d?ca(a,b,d,p.support.boxSizing&amp;&amp;p.css(a,"boxSizing")==="border-box"):0)}}}),p.support.opacity||(p.cssHooks.opacity={get:function(a,b){return bL.test((b&amp;&amp;a.currentStyle?a.currentStyle.filter:a.style.filter)||"")?.01*parseFloat(RegExp.$1)+"":b?"1":""},set:function(a,b){var c=a.style,d=a.currentStyle,e=p.isNumeric(b)?"alpha(opacity="+b*100+")":"",f=d&amp;&amp;d.filter||c.filter||"";c.zoom=1;if(b&gt;=1&amp;&amp;p.trim(f.replace(bK,""))===""&amp;&amp;c.removeAttribute){c.removeAttribute("filter");if(d&amp;&amp;!d.filter)return}c.filter=bK.test(f)?f.replace(bK,e):f+" "+e}}),p(function(){p.support.reliableMarginRight||(p.cssHooks.marginRight={get:function(a,b){return p.swap(a,{display:"inline-block"},function(){if(b)return bH(a,"marginRight")})}}),!p.support.pixelPosition&amp;&amp;p.fn.position&amp;&amp;p.each(["top","left"],function(a,b){p.cssHooks[b]={get:function(a,c){if(c){var d=bH(a,b);return bQ.test(d)?p(a).position()[b]+"px":d}}}})}),p.expr&amp;&amp;p.expr.filters&amp;&amp;(p.expr.filters.hidden=function(a){return a.offsetWidth===0&amp;&amp;a.offsetHeight===0||!p.support.reliableHiddenOffsets&amp;&amp;(a.style&amp;&amp;a.style.display||bH(a,"display"))==="none"},p.expr.filters.visible=function(a){return!p.expr.filters.hidden(a)}),p.each({margin:"",padding:"",border:"Width"},function(a,b){p.cssHooks[a+b]={expand:function(c){var d,e=typeof c=="string"?c.split(" "):[c],f={};for(d=0;d&lt;4;d++)f[a+bV[d]+b]=e[d]||e[d-2]||e[0];return f}},bO.test(a)||(p.cssHooks[a+b].set=b_)});var cd=/%20/g,ce=/\[\]$/,cf=/\r?\n/g,cg=/^(?:color|date|datetime|datetime-local|email|hidden|month|number|password|range|search|tel|text|time|url|week)$/i,ch=/^(?:select|textarea)/i;p.fn.extend({serialize:function(){return p.param(this.serializeArray())},serializeArray:function(){return this.map(function(){return this.elements?p.makeArray(this.elements):this}).filter(function(){return this.name&amp;&amp;!this.disabled&amp;&amp;(this.checked||ch.test(this.nodeName)||cg.test(this.type))}).map(function(a,b){var c=p(this).val();return c==null?null:p.isArray(c)?p.map(c,function(a,c){return{name:b.name,value:a.replace(cf,"\r\n")}}):{name:b.name,value:c.replace(cf,"\r\n")}}).get()}}),p.param=function(a,c){var d,e=[],f=function(a,b){b=p.isFunction(b)?b():b==null?"":b,e[e.length]=encodeURIComponent(a)+"="+encodeURIComponent(b)};c===b&amp;&amp;(c=p.ajaxSettings&amp;&amp;p.ajaxSettings.traditional);if(p.isArray(a)||a.jquery&amp;&amp;!p.isPlainObject(a))p.each(a,function(){f(this.name,this.value)});else for(d in a)ci(d,a[d],c,f);return e.join("&amp;").replace(cd,"+")};var cj,ck,cl=/#.*$/,cm=/^(.*?):[ \t]*([^\r\n]*)\r?$/mg,cn=/^(?:about|app|app\-storage|.+\-extension|file|res|widget):$/,co=/^(?:GET|HEAD)$/,cp=/^\/\//,cq=/\?/,cr=/&lt;script\b[^&lt;]*(?:(?!&lt;\/script&gt;)&lt;[^&lt;]*)*&lt;\/script&gt;/gi,cs=/([?&amp;])_=[^&amp;]*/,ct=/^([\w\+\.\-]+:)(?:\/\/([^\/?#:]*)(?::(\d+)|)|)/,cu=p.fn.load,cv={},cw={},cx=["*/"]+["*"];try{ck=f.href}catch(cy){ck=e.createElement("a"),ck.href="",ck=ck.href}cj=ct.exec(ck.toLowerCase())||[],p.fn.load=function(a,c,d){if(typeof a!="string"&amp;&amp;cu)return cu.apply(this,arguments);if(!this.length)return this;var e,f,g,h=this,i=a.indexOf(" ");return i&gt;=0&amp;&amp;(e=a.slice(i,a.length),a=a.slice(0,i)),p.isFunction(c)?(d=c,c=b):c&amp;&amp;typeof c=="object"&amp;&amp;(f="POST"),p.ajax({url:a,type:f,dataType:"html",data:c,complete:function(a,b){d&amp;&amp;h.each(d,g||[a.responseText,b,a])}}).done(function(a){g=arguments,h.html(e?p("&lt;div&gt;").append(a.replace(cr,"")).find(e):a)}),this},p.each("ajaxStart ajaxStop ajaxComplete ajaxError ajaxSuccess ajaxSend".split(" "),function(a,b){p.fn[b]=function(a){return this.on(b,a)}}),p.each(["get","post"],function(a,c){p[c]=function(a,d,e,f){return p.isFunction(d)&amp;&amp;(f=f||e,e=d,d=b),p.ajax({type:c,url:a,data:d,success:e,dataType:f})}}),p.extend({getScript:function(a,c){return p.get(a,b,c,"script")},getJSON:function(a,b,c){return p.get(a,b,c,"json")},ajaxSetup:function(a,b){return b?cB(a,p.ajaxSettings):(b=a,a=p.ajaxSettings),cB(a,b),a},ajaxSettings:{url:ck,isLocal:cn.test(cj[1]),global:!0,type:"GET",contentType:"application/x-www-form-urlencoded; charset=UTF-8",processData:!0,async:!0,accepts:{xml:"application/xml, text/xml",html:"text/html",text:"text/plain",json:"application/json, text/javascript","*":cx},contents:{xml:/xml/,html:/html/,json:/json/},responseFields:{xml:"responseXML",text:"responseText"},converters:{"* text":a.String,"text html":!0,"text json":p.parseJSON,"text xml":p.parseXML},flatOptions:{context:!0,url:!0}},ajaxPrefilter:cz(cv),ajaxTransport:cz(cw),ajax:function(a,c){function y(a,c,f,i){var k,s,t,u,w,y=c;if(v===2)return;v=2,h&amp;&amp;clearTimeout(h),g=b,e=i||"",x.readyState=a&gt;0?4:0,f&amp;&amp;(u=cC(l,x,f));if(a&gt;=200&amp;&amp;a&lt;300||a===304)l.ifModified&amp;&amp;(w=x.getResponseHeader("Last-Modified"),w&amp;&amp;(p.lastModified[d]=w),w=x.getResponseHeader("Etag"),w&amp;&amp;(p.etag[d]=w)),a===304?(y="notmodified",k=!0):(k=cD(l,u),y=k.state,s=k.data,t=k.error,k=!t);else{t=y;if(!y||a)y="error",a&lt;0&amp;&amp;(a=0)}x.status=a,x.statusText=(c||y)+"",k?o.resolveWith(m,[s,y,x]):o.rejectWith(m,[x,y,t]),x.statusCode(r),r=b,j&amp;&amp;n.trigger("ajax"+(k?"Success":"Error"),[x,l,k?s:t]),q.fireWith(m,[x,y]),j&amp;&amp;(n.trigger("ajaxComplete",[x,l]),--p.active||p.event.trigger("ajaxStop"))}typeof a=="object"&amp;&amp;(c=a,a=b),c=c||{};var d,e,f,g,h,i,j,k,l=p.ajaxSetup({},c),m=l.context||l,n=m!==l&amp;&amp;(m.nodeType||m instanceof p)?p(m):p.event,o=p.Deferred(),q=p.Callbacks("once memory"),r=l.statusCode||{},t={},u={},v=0,w="canceled",x={readyState:0,setRequestHeader:function(a,b){if(!v){var c=a.toLowerCase();a=u[c]=u[c]||a,t[a]=b}return this},getAllResponseHeaders:function(){return v===2?e:null},getResponseHeader:function(a){var c;if(v===2){if(!f){f={};while(c=cm.exec(e))f[c[1].toLowerCase()]=c[2]}c=f[a.toLowerCase()]}return c===b?null:c},overrideMimeType:function(a){return v||(l.mimeType=a),this},abort:function(a){return a=a||w,g&amp;&amp;g.abort(a),y(0,a),this}};o.promise(x),x.success=x.done,x.error=x.fail,x.complete=q.add,x.statusCode=function(a){if(a){var b;if(v&lt;2)for(b in a)r[b]=[r[b],a[b]];else b=a[x.status],x.always(b)}return this},l.url=((a||l.url)+"").replace(cl,"").replace(cp,cj[1]+"//"),l.dataTypes=p.trim(l.dataType||"*").toLowerCase().split(s),l.crossDomain==null&amp;&amp;(i=ct.exec(l.url.toLowerCase())||!1,l.crossDomain=i&amp;&amp;i.join(":")+(i[3]?"":i[1]==="http:"?80:443)!==cj.join(":")+(cj[3]?"":cj[1]==="http:"?80:443)),l.data&amp;&amp;l.processData&amp;&amp;typeof l.data!="string"&amp;&amp;(l.data=p.param(l.data,l.traditional)),cA(cv,l,c,x);if(v===2)return x;j=l.global,l.type=l.type.toUpperCase(),l.hasContent=!co.test(l.type),j&amp;&amp;p.active++===0&amp;&amp;p.event.trigger("ajaxStart");if(!l.hasContent){l.data&amp;&amp;(l.url+=(cq.test(l.url)?"&amp;":"?")+l.data,delete l.data),d=l.url;if(l.cache===!1){var z=p.now(),A=l.url.replace(cs,"$1_="+z);l.url=A+(A===l.url?(cq.test(l.url)?"&amp;":"?")+"_="+z:"")}}(l.data&amp;&amp;l.hasContent&amp;&amp;l.contentType!==!1||c.contentType)&amp;&amp;x.setRequestHeader("Content-Type",l.contentType),l.ifModified&amp;&amp;(d=d||l.url,p.lastModified[d]&amp;&amp;x.setRequestHeader("If-Modified-Since",p.lastModified[d]),p.etag[d]&amp;&amp;x.setRequestHeader("If-None-Match",p.etag[d])),x.setRequestHeader("Accept",l.dataTypes[0]&amp;&amp;l.accepts[l.dataTypes[0]]?l.accepts[l.dataTypes[0]]+(l.dataTypes[0]!=="*"?", "+cx+"; q=0.01":""):l.accepts["*"]);for(k in l.headers)x.setRequestHeader(k,l.headers[k]);if(!l.beforeSend||l.beforeSend.call(m,x,l)!==!1&amp;&amp;v!==2){w="abort";for(k in{success:1,error:1,complete:1})x[k](l[k]);g=cA(cw,l,c,x);if(!g)y(-1,"No Transport");else{x.readyState=1,j&amp;&amp;n.trigger("ajaxSend",[x,l]),l.async&amp;&amp;l.timeout&gt;0&amp;&amp;(h=setTimeout(function(){x.abort("timeout")},l.timeout));try{v=1,g.send(t,y)}catch(B){if(v&lt;2)y(-1,B);else throw B}}return x}return x.abort()},active:0,lastModified:{},etag:{}});var cE=[],cF=/\?/,cG=/(=)\?(?=&amp;|$)|\?\?/,cH=p.now();p.ajaxSetup({jsonp:"callback",jsonpCallback:function(){var a=cE.pop()||p.expando+"_"+cH++;return this[a]=!0,a}}),p.ajaxPrefilter("json jsonp",function(c,d,e){var f,g,h,i=c.data,j=c.url,k=c.jsonp!==!1,l=k&amp;&amp;cG.test(j),m=k&amp;&amp;!l&amp;&amp;typeof i=="string"&amp;&amp;!(c.contentType||"").indexOf("application/x-www-form-urlencoded")&amp;&amp;cG.test(i);if(c.dataTypes[0]==="jsonp"||l||m)return f=c.jsonpCallback=p.isFunction(c.jsonpCallback)?c.jsonpCallback():c.jsonpCallback,g=a[f],l?c.url=j.replace(cG,"$1"+f):m?c.data=i.replace(cG,"$1"+f):k&amp;&amp;(c.url+=(cF.test(j)?"&amp;":"?")+c.jsonp+"="+f),c.converters["script json"]=function(){return h||p.error(f+" was not called"),h[0]},c.dataTypes[0]="json",a[f]=function(){h=arguments},e.always(function(){a[f]=g,c[f]&amp;&amp;(c.jsonpCallback=d.jsonpCallback,cE.push(f)),h&amp;&amp;p.isFunction(g)&amp;&amp;g(h[0]),h=g=b}),"script"}),p.ajaxSetup({accepts:{script:"text/javascript, application/javascript, application/ecmascript, application/x-ecmascript"},contents:{script:/javascript|ecmascript/},converters:{"text script":function(a){return p.globalEval(a),a}}}),p.ajaxPrefilter("script",function(a){a.cache===b&amp;&amp;(a.cache=!1),a.crossDomain&amp;&amp;(a.type="GET",a.global=!1)}),p.ajaxTransport("script",function(a){if(a.crossDomain){var c,d=e.head||e.getElementsByTagName("head")[0]||e.documentElement;return{send:function(f,g){c=e.createElement("script"),c.async="async",a.scriptCharset&amp;&amp;(c.charset=a.scriptCharset),c.src=a.url,c.onload=c.onreadystatechange=function(a,e){if(e||!c.readyState||/loaded|complete/.test(c.readyState))c.onload=c.onreadystatechange=null,d&amp;&amp;c.parentNode&amp;&amp;d.removeChild(c),c=b,e||g(200,"success")},d.insertBefore(c,d.firstChild)},abort:function(){c&amp;&amp;c.onload(0,1)}}}});var cI,cJ=a.ActiveXObject?function(){for(var a in cI)cI[a](0,1)}:!1,cK=0;p.ajaxSettings.xhr=a.ActiveXObject?function(){return!this.isLocal&amp;&amp;cL()||cM()}:cL,function(a){p.extend(p.support,{ajax:!!a,cors:!!a&amp;&amp;"withCredentials"in a})}(p.ajaxSettings.xhr()),p.support.ajax&amp;&amp;p.ajaxTransport(function(c){if(!c.crossDomain||p.support.cors){var d;return{send:function(e,f){var g,h,i=c.xhr();c.username?i.open(c.type,c.url,c.async,c.username,c.password):i.open(c.type,c.url,c.async);if(c.xhrFields)for(h in c.xhrFields)i[h]=c.xhrFields[h];c.mimeType&amp;&amp;i.overrideMimeType&amp;&amp;i.overrideMimeType(c.mimeType),!c.crossDomain&amp;&amp;!e["X-Requested-With"]&amp;&amp;(e["X-Requested-With"]="XMLHttpRequest");try{for(h in e)i.setRequestHeader(h,e[h])}catch(j){}i.send(c.hasContent&amp;&amp;c.data||null),d=function(a,e){var h,j,k,l,m;try{if(d&amp;&amp;(e||i.readyState===4)){d=b,g&amp;&amp;(i.onreadystatechange=p.noop,cJ&amp;&amp;delete cI[g]);if(e)i.readyState!==4&amp;&amp;i.abort();else{h=i.status,k=i.getAllResponseHeaders(),l={},m=i.responseXML,m&amp;&amp;m.documentElement&amp;&amp;(l.xml=m);try{l.text=i.responseText}catch(a){}try{j=i.statusText}catch(n){j=""}!h&amp;&amp;c.isLocal&amp;&amp;!c.crossDomain?h=l.text?200:404:h===1223&amp;&amp;(h=204)}}}catch(o){e||f(-1,o)}l&amp;&amp;f(h,j,l,k)},c.async?i.readyState===4?setTimeout(d,0):(g=++cK,cJ&amp;&amp;(cI||(cI={},p(a).unload(cJ)),cI[g]=d),i.onreadystatechange=d):d()},abort:function(){d&amp;&amp;d(0,1)}}}});var cN,cO,cP=/^(?:toggle|show|hide)$/,cQ=new RegExp("^(?:([-+])=|)("+q+")([a-z%]*)$","i"),cR=/queueHooks$/,cS=[cY],cT={"*":[function(a,b){var c,d,e=this.createTween(a,b),f=cQ.exec(b),g=e.cur(),h=+g||0,i=1,j=20;if(f){c=+f[2],d=f[3]||(p.cssNumber[a]?"":"px");if(d!=="px"&amp;&amp;h){h=p.css(e.elem,a,!0)||c||1;do i=i||".5",h=h/i,p.style(e.elem,a,h+d);while(i!==(i=e.cur()/g)&amp;&amp;i!==1&amp;&amp;--j)}e.unit=d,e.start=h,e.end=f[1]?h+(f[1]+1)*c:c}return e}]};p.Animation=p.extend(cW,{tweener:function(a,b){p.isFunction(a)?(b=a,a=["*"]):a=a.split(" ");var c,d=0,e=a.length;for(;d&lt;e;d++)c=a[d],cT[c]=cT[c]||[],cT[c].unshift(b)},prefilter:function(a,b){b?cS.unshift(a):cS.push(a)}}),p.Tween=cZ,cZ.prototype={constructor:cZ,init:function(a,b,c,d,e,f){this.elem=a,this.prop=c,this.easing=e||"swing",this.options=b,this.start=this.now=this.cur(),this.end=d,this.unit=f||(p.cssNumber[c]?"":"px")},cur:function(){var a=cZ.propHooks[this.prop];return a&amp;&amp;a.get?a.get(this):cZ.propHooks._default.get(this)},run:function(a){var b,c=cZ.propHooks[this.prop];return this.options.duration?this.pos=b=p.easing[this.easing](a,this.options.duration*a,0,1,this.options.duration):this.pos=b=a,this.now=(this.end-this.start)*b+this.start,this.options.step&amp;&amp;this.options.step.call(this.elem,this.now,this),c&amp;&amp;c.set?c.set(this):cZ.propHooks._default.set(this),this}},cZ.prototype.init.prototype=cZ.prototype,cZ.propHooks={_default:{get:function(a){var b;return a.elem[a.prop]==null||!!a.elem.style&amp;&amp;a.elem.style[a.prop]!=null?(b=p.css(a.elem,a.prop,!1,""),!b||b==="auto"?0:b):a.elem[a.prop]},set:function(a){p.fx.step[a.prop]?p.fx.step[a.prop](a):a.elem.style&amp;&amp;(a.elem.style[p.cssProps[a.prop]]!=null||p.cssHooks[a.prop])?p.style(a.elem,a.prop,a.now+a.unit):a.elem[a.prop]=a.now}}},cZ.propHooks.scrollTop=cZ.propHooks.scrollLeft={set:function(a){a.elem.nodeType&amp;&amp;a.elem.parentNode&amp;&amp;(a.elem[a.prop]=a.now)}},p.each(["toggle","show","hide"],function(a,b){var c=p.fn[b];p.fn[b]=function(d,e,f){return d==null||typeof d=="boolean"||!a&amp;&amp;p.isFunction(d)&amp;&amp;p.isFunction(e)?c.apply(this,arguments):this.animate(c$(b,!0),d,e,f)}}),p.fn.extend({fadeTo:function(a,b,c,d){return this.filter(bZ).css("opacity",0).show().end().animate({opacity:b},a,c,d)},animate:function(a,b,c,d){var e=p.isEmptyObject(a),f=p.speed(b,c,d),g=function(){var b=cW(this,p.extend({},a),f);e&amp;&amp;b.stop(!0)};return e||f.queue===!1?this.each(g):this.queue(f.queue,g)},stop:function(a,c,d){var e=function(a){var b=a.stop;delete a.stop,b(d)};return typeof a!="string"&amp;&amp;(d=c,c=a,a=b),c&amp;&amp;a!==!1&amp;&amp;this.queue(a||"fx",[]),this.each(function(){var b=!0,c=a!=null&amp;&amp;a+"queueHooks",f=p.timers,g=p._data(this);if(c)g[c]&amp;&amp;g[c].stop&amp;&amp;e(g[c]);else for(c in g)g[c]&amp;&amp;g[c].stop&amp;&amp;cR.test(c)&amp;&amp;e(g[c]);for(c=f.length;c--;)f[c].elem===this&amp;&amp;(a==null||f[c].queue===a)&amp;&amp;(f[c].anim.stop(d),b=!1,f.splice(c,1));(b||!d)&amp;&amp;p.dequeue(this,a)})}}),p.each({slideDown:c$("show"),slideUp:c$("hide"),slideToggle:c$("toggle"),fadeIn:{opacity:"show"},fadeOut:{opacity:"hide"},fadeToggle:{opacity:"toggle"}},function(a,b){p.fn[a]=function(a,c,d){return this.animate(b,a,c,d)}}),p.speed=function(a,b,c){var d=a&amp;&amp;typeof a=="object"?p.extend({},a):{complete:c||!c&amp;&amp;b||p.isFunction(a)&amp;&amp;a,duration:a,easing:c&amp;&amp;b||b&amp;&amp;!p.isFunction(b)&amp;&amp;b};d.duration=p.fx.off?0:typeof d.duration=="number"?d.duration:d.duration in p.fx.speeds?p.fx.speeds[d.duration]:p.fx.speeds._default;if(d.queue==null||d.queue===!0)d.queue="fx";return d.old=d.complete,d.complete=function(){p.isFunction(d.old)&amp;&amp;d.old.call(this),d.queue&amp;&amp;p.dequeue(this,d.queue)},d},p.easing={linear:function(a){return a},swing:function(a){return.5-Math.cos(a*Math.PI)/2}},p.timers=[],p.fx=cZ.prototype.init,p.fx.tick=function(){var a,b=p.timers,c=0;for(;c&lt;b.length;c++)a=b[c],!a()&amp;&amp;b[c]===a&amp;&amp;b.splice(c--,1);b.length||p.fx.stop()},p.fx.timer=function(a){a()&amp;&amp;p.timers.push(a)&amp;&amp;!cO&amp;&amp;(cO=setInterval(p.fx.tick,p.fx.interval))},p.fx.interval=13,p.fx.stop=function(){clearInterval(cO),cO=null},p.fx.speeds={slow:600,fast:200,_default:400},p.fx.step={},p.expr&amp;&amp;p.expr.filters&amp;&amp;(p.expr.filters.animated=function(a){return p.grep(p.timers,function(b){return a===b.elem}).length});var c_=/^(?:body|html)$/i;p.fn.offset=function(a){if(arguments.length)return a===b?this:this.each(function(b){p.offset.setOffset(this,a,b)});var c,d,e,f,g,h,i,j={top:0,left:0},k=this[0],l=k&amp;&amp;k.ownerDocument;if(!l)return;return(d=l.body)===k?p.offset.bodyOffset(k):(c=l.documentElement,p.contains(c,k)?(typeof k.getBoundingClientRect!="undefined"&amp;&amp;(j=k.getBoundingClientRect()),e=da(l),f=c.clientTop||d.clientTop||0,g=c.clientLeft||d.clientLeft||0,h=e.pageYOffset||c.scrollTop,i=e.pageXOffset||c.scrollLeft,{top:j.top+h-f,left:j.left+i-g}):j)},p.offset={bodyOffset:function(a){var b=a.offsetTop,c=a.offsetLeft;return p.support.doesNotIncludeMarginInBodyOffset&amp;&amp;(b+=parseFloat(p.css(a,"marginTop"))||0,c+=parseFloat(p.css(a,"marginLeft"))||0),{top:b,left:c}},setOffset:function(a,b,c){var d=p.css(a,"position");d==="static"&amp;&amp;(a.style.position="relative");var e=p(a),f=e.offset(),g=p.css(a,"top"),h=p.css(a,"left"),i=(d==="absolute"||d==="fixed")&amp;&amp;p.inArray("auto",[g,h])&gt;-1,j={},k={},l,m;i?(k=e.position(),l=k.top,m=k.left):(l=parseFloat(g)||0,m=parseFloat(h)||0),p.isFunction(b)&amp;&amp;(b=b.call(a,c,f)),b.top!=null&amp;&amp;(j.top=b.top-f.top+l),b.left!=null&amp;&amp;(j.left=b.left-f.left+m),"using"in b?b.using.call(a,j):e.css(j)}},p.fn.extend({position:function(){if(!this[0])return;var a=this[0],b=this.offsetParent(),c=this.offset(),d=c_.test(b[0].nodeName)?{top:0,left:0}:b.offset();return c.top-=parseFloat(p.css(a,"marginTop"))||0,c.left-=parseFloat(p.css(a,"marginLeft"))||0,d.top+=parseFloat(p.css(b[0],"borderTopWidth"))||0,d.left+=parseFloat(p.css(b[0],"borderLeftWidth"))||0,{top:c.top-d.top,left:c.left-d.left}},offsetParent:function(){return this.map(function(){var a=this.offsetParent||e.body;while(a&amp;&amp;!c_.test(a.nodeName)&amp;&amp;p.css(a,"position")==="static")a=a.offsetParent;return a||e.body})}}),p.each({scrollLeft:"pageXOffset",scrollTop:"pageYOffset"},function(a,c){var d=/Y/.test(c);p.fn[a]=function(e){return p.access(this,function(a,e,f){var g=da(a);if(f===b)return g?c in g?g[c]:g.document.documentElement[e]:a[e];g?g.scrollTo(d?p(g).scrollLeft():f,d?f:p(g).scrollTop()):a[e]=f},a,e,arguments.length,null)}}),p.each({Height:"height",Width:"width"},function(a,c){p.each({padding:"inner"+a,content:c,"":"outer"+a},function(d,e){p.fn[e]=function(e,f){var g=arguments.length&amp;&amp;(d||typeof e!="boolean"),h=d||(e===!0||f===!0?"margin":"border");return p.access(this,function(c,d,e){var f;return p.isWindow(c)?c.document.documentElement["client"+a]:c.nodeType===9?(f=c.documentElement,Math.max(c.body["scroll"+a],f["scroll"+a],c.body["offset"+a],f["offset"+a],f["client"+a])):e===b?p.css(c,d,e,h):p.style(c,d,e,h)},c,g?e:b,g,null)}})}),a.jQuery=a.$=p,typeof define=="function"&amp;&amp;define.amd&amp;&amp;define.amd.jQuery&amp;&amp;define("jquery",[],function(){return p})})(window);

</xsl:variable>

<!--
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    End of included transformation: wsdl-viewer-jquery-min.xsl
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-->





<!--
==================================================================
	Starting point
==================================================================
-->

<xsl:template match="/">
	<html>
		<xsl:call-template name="head.render"/>
		<xsl:call-template name="body.render"/>
	</html>
</xsl:template>



<!--
==================================================================
	Rendering: HTML head
==================================================================
-->

<xsl:template name="head.render">
<head>
	<title>
<xsl:value-of select="concat($html-title, ' - ', 'Generated by wsdl-viewer.xsl')"/>
</title>
	<meta http-equiv="content-type" content="text/html; charset=utf-8"/>
	<meta http-equiv="content-script-type" content="text/javascript"/>
	<meta http-equiv="content-style-type" content="text/css"/>
	<meta name="Generator" content="http://tomi.vanek.sk/xml/wsdl-viewer.xsl"/>

	<meta http-equiv="imagetoolbar" content="false"/>
	<meta name="MSSmartTagsPreventParsing" content="true"/>

	<style type="text/css">
<xsl:value-of select="$css" disable-output-escaping="yes"/>
</style>
    <script type="text/javascript" language="javascript">
<xsl:value-of select="$jquery" disable-output-escaping="yes"/>
</script>
	<script type="text/javascript" language="javascript">
<xsl:value-of select="$js" disable-output-escaping="yes"/>
</script>
</head>
</xsl:template>



<!--
==================================================================
	Rendering: HTML body
==================================================================
-->

<xsl:template name="body.render">
<body id="operations">
	<xsl:call-template name="title.render"/>
    <xsl:call-template name="services.render"/>
    <xsl:call-template name="content.render"/>
	<xsl:call-template name="footer.render"/>
</body>
</xsl:template>



<!--
==================================================================
	Rendering: heading
==================================================================
-->

<xsl:template name="title.render">
	<div id="header">
		<div id="headertitle">
<xsl:value-of select="translate($html-title, 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
</div>
		<div id="namespace">Target namespace: <b>
<xsl:value-of select="$consolidated-wsdl/@targetNamespace"/>
</b>
</div>
	</div>
</xsl:template>



<!--
==================================================================
	Rendering: services
==================================================================
-->

<xsl:template name="services.render">
<div id="services">
	<xsl:if test="$ENABLE-SERVICE-PARAGRAPH">
		<xsl:call-template name="service.render"/>
	</xsl:if>
</div>
</xsl:template>


<!--
==================================================================
	Rendering: content
==================================================================
-->

<xsl:template name="content.render">
<div id="content">
	<xsl:if test="$ENABLE-OPERATIONS-PARAGRAPH">
		<xsl:call-template name="operations.render"/>
	</xsl:if>
	<xsl:if test="$ENABLE-SRC-CODE-PARAGRAPH">
		<xsl:call-template name="src.render"/>
	</xsl:if>
	<xsl:if test="$ENABLE-ABOUT-PARAGRAPH">
		<xsl:call-template name="about.render">
			<xsl:with-param name="version" select="$wsdl-viewer.version"/>
		</xsl:call-template>
	</xsl:if>
</div>
</xsl:template>



<!--
==================================================================
	Rendering: footer
==================================================================
-->

<xsl:template name="footer.render">
<div id="footer">
	This page was generated by wsdl-viewer.xsl (<a href="http://tomi.vanek.sk">http://tomi.vanek.sk</a>)
</div>
</xsl:template>



<!--
==================================================================
	Rendering: WSDL service information
==================================================================
-->

<xsl:template name="service.render">
<div class="page">
	<xsl:apply-templates select="$consolidated-wsdl/*[local-name(.) = 'documentation']" mode="documentation.render"/>
	<xsl:apply-templates select="$consolidated-wsdl/ws:service|$consolidated-wsdl/ws2:service" mode="service-start"/>
	<xsl:if test="not($consolidated-wsdl/*[local-name() = 'service']/@name)">
		

<!-- If the WS is without implementation, just with binding points = WS interface -->

		<xsl:apply-templates select="$consolidated-wsdl/ws:binding" mode="service-start"/>
		<xsl:apply-templates select="$consolidated-wsdl/ws2:interface" mode="service"/>
	</xsl:if>
</div>
</xsl:template>



<!--
==================================================================
	Rendering: WSDL operations - detail
==================================================================
-->

<xsl:template name="operations.render">
<div class="page">
    <xsl:apply-templates select="*[local-name(.) = 'documentation']" mode="documentation.render"/>

    <a class="target" name="page.operations">
		<div id="operations_title">Operations:</div>
	</a>
	<ul>
		<xsl:apply-templates select="$consolidated-wsdl/ws:portType" mode="operations">
			<xsl:sort select="@name"/>
		</xsl:apply-templates>

		<xsl:choose>
			<xsl:when test="$consolidated-wsdl/*[local-name() = 'service']/@name">
				<xsl:variable name="iface-name">
					<xsl:apply-templates select="$consolidated-wsdl/*[local-name() = 'service']/@interface" mode="qname.normalized"/>
				</xsl:variable>
				<xsl:apply-templates select="$consolidated-wsdl/ws2:interface[@name = $iface-name]" mode="operations">
					<xsl:sort select="@name"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="$consolidated-wsdl/ws2:interface/@name">
				

<!-- TODO: What to do if there are more interfaces? -->

				<xsl:apply-templates select="$consolidated-wsdl/ws2:interface[1]" mode="operations"/>
			</xsl:when>
			<xsl:otherwise>
				

<!-- TODO: Error message or handling somehow this unexpected situation -->

			</xsl:otherwise>
		</xsl:choose>
	</ul>
</div>
</xsl:template>



<!--
==================================================================
	Rendering: WSDL and XSD source code files
==================================================================
-->

<xsl:template name="src.render">
<div class="page">
	<a class="target" name="page.src">
		<h2>WSDL source code</h2>
	</a>
	<div class="box">
		<div class="xml-proc">
			<xsl:text>&lt;?xml version="1.0"?&gt;</xsl:text>
		</div>
		<xsl:apply-templates select="/" mode="src"/>
	</div>

	<xsl:apply-templates select="/*/*[local-name() = 'import'][@location]/@location" mode="src.import"/>
	<xsl:apply-templates select="$consolidated-wsdl/*[local-name() = 'types']//xsd:import[@schemaLocation]/@schemaLocation | $consolidated-wsdl/*[local-name() = 'types']//xsd:include[@schemaLocation]/@schemaLocation" mode="src.import"/>
</div>
</xsl:template>



<!--
==================================================================
	Rendering: About
==================================================================
-->

<xsl:template name="about.render">
<xsl:param name="version"/>
<div class="page">
	<a class="target" name="page.about">
		<h2>About <em>wsdl-viewer.xsl</em>
</h2>
	</a>
	<div class="floatcontainer">
		<div id="fix_column">
		<div class="shadow">
<div class="box">
			<xsl:call-template name="processor-info.render"/>
		</div>
</div>
		</div>
	
		<div id="flexi_column">
			<xsl:call-template name="about.detail">
				<xsl:with-param name="version" select="$wsdl-viewer.version"/>
			</xsl:call-template>
		</div>
	</div>
</div>
</xsl:template>


</xsl:stylesheet>
