/******************************************************************************
Magic XML by Tom Davies
-----------------------
Magically implements cross-browser code from w3schools.com/xsl/xsl_client.asp 
to pull in XML data and apply a specified XSLT on marked up elements.

More details at: http://www.t-davies.com/magicxml/

******************************************************************************/

/*

The MIT License (MIT)

Copyright (C) 2013 - Tom Davies (tom@t-davies.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

+function (window, document, undefined) {

    // Declare variables as early as possible.
    var j = 0,
        element,
        elementParams,
        options = {
            xmlSourceAttribute: 'data-xml',
            xslSourceAttribute: 'data-xslt',
            xslParamAttribute: 'data-xsl-params',
            xmlStringParser: getXMLStringParser()
        };

    // Closure prevents access to supporting functions we need by placing them
    // in encapsulating function scope.

    function isXML(candidate) {
        return (candidate.indexOf('<?xml version="1.0"') >= 0);
    }

    var parseXml;

    if (window.DOMParser) {
        parseXml = function(xmlStr) {
            return ( new window.DOMParser() ).parseFromString(xmlStr, "text/xml");
        };
    } else if (typeof window.ActiveXObject != "undefined" && new window.ActiveXObject("Microsoft.XMLDOM")) {
        parseXml = function(xmlStr) {
            var xmlDoc = new window.ActiveXObject("Microsoft.XMLDOM");
            xmlDoc.async = "false";
            xmlDoc.loadXML(xmlStr);
            return xmlDoc;
        };
    } else {
        parseXml = function() { return null; }
    }

    function loadXML(source) {
        var xhr = (window.ActiveXObject || "ActiveXObject" in window) ?
                new ActiveXObject("Msxml2.XMLHTTP.3.0") :
                new XMLHttpRequest();

        xhr.open("GET", source, false);
        xhr.send();
        return xhr.responseXML || parseXml(xhr.responseText);
    }
    
    function parseXMLString(xmlString) {
        return options.xmlStringParser.parse(xmlString);
    }
    
    function getXMLStringParser() {
        var parse = function() {
            console.error('[Magic XML] No XML string parser available.');
        };
              
        if (window.DOMParser) {
            parse = function(xmlString) {
                var parser = new window.DOMParser();
                return parser.parseFromString(xmlString, "text/xml");
            }
        }
        else if (window.ActiveXObject || "ActiveXObject" in window) {
            parse = function(xmlString) {
                var dom = new ActiveXObject("Microsoft.XMLDOM");
                dom.async = false;
                dom.loadXML(xmlString);
                return dom;
            }
        }
        else {
            console.warn("[Magic XML] No XML string parser available. String " + 
                "parsing will fail if used.");
        }

        return {
            parse: parse
        }
    }

    function loadXSL(source) {
        if (window.ActiveXObject || "ActiveXObject" in window) {
            var xsl = new ActiveXObject("MSXML2.FreeThreadedDOMDocument.6.0");
            xsl.async = false;
            xsl.load(source);
            return xsl;
        }

        // If we don't need to use ActiveX just get normally.
        return loadXML(source);
    }

    function getTransformFragment(xml, xsl, parameters) {
        var i = 0,
            parameter,
            xslt = new XSLTProcessor();

        xslt.importStylesheet(xsl);

        // If we have a parameters array, set the values in the XSLT.
        if (parameters !== undefined) {
            for (i; i < parameters.length; i++) {
                parameter = parameters[i];
                xslt.setParameter((parameter.xmlns !== undefined) ?
                    parameter.xmlns : null, // fix required null for FF
                    parameter.name,
                    parameter.value);
            }
        }
        return xslt.transformToFragment(xml, document);
    }

    function getActiveXTransform(xml, xsl, parameters) {
        var i = 0,
                processor,
                template = new ActiveXObject("MSXML2.XSLTemplate.6.0");

        template.stylesheet = xsl;
        processor = template.createProcessor();
        processor.input = xml;

        // If we have a parameters array, set the values in the XSLT.
        if (parameters !== undefined) {
            for (i; i < parameters.length; i++) {
                parameter = parameters[i];
                processor.addParameter(parameter.name, parameter.value,
                    parameter.xmlns);
            }
        }

        processor.transform();
        return processor.output;
    }

    function makeAttributeSelector(name) {
        return '[' + name + ']';
    }


    function execBodyScripts(body_el) {
        // Finds and executes scripts in a newly added element's body.
        // Needed since innerHTML does not run scripts.
        //
        // Argument body_el is an element in the dom.

        function nodeName(elem, name) {
            return elem.nodeName && elem.nodeName.toUpperCase() ===
                      name.toUpperCase();
        };

        function evalScript(elem) {
            var data = (elem.text || elem.textContent || elem.innerHTML || "" ),
                head = document.getElementsByTagName("head")[0] ||
                          document.documentElement,
                script = document.createElement("script");

            script.type = "text/javascript";
            try {
                // doesn't work on ie...
                script.appendChild(document.createTextNode(data));      
            } catch(e) {
                // IE has funky script nodes
                script.text = data;
            }

            head.insertBefore(script, head.firstChild);
            head.removeChild(script);
        };

        // main section of function
        var scripts = [],
            script,
            children_nodes = body_el.childNodes,
            child,
            i;

        for (i = 0; children_nodes[i]; i++) {
            child = children_nodes[i];
            if (nodeName(child, "script" ) &&
              (!child.type || child.type.toLowerCase() === "text/javascript")) {
                scripts.push(child);
            }
            execBodyScripts(child);
        }

        for (i = 0; scripts[i]; i++) {
            script = scripts[i];
            //if (script.parentNode) {script.parentNode.removeChild(script);}
            evalScript(scripts[i]);
        }
    };




    // End supporting function definitions.
      
    // Declare Magic XML functionality.
    var x = {

        /// <summary>
        /// Configures the script to use non-default names for attributes,
        /// and/or an alternative XML string parser.
        /// </summary>
        configure: function (xmlSourceAttribute, xslSourceAttribute,
            xslParamAttribute, xmlStringParser) {

            if (typeof xmlSourceAttribute === 'string')
                options.xmlSourceAttribute = xmlSourceAttribute;

            if (typeof xslSourceAttribute === 'string')
                options.xslSourceAttribute = xslSourceAttribute;

            if (typeof xslParamAttribute === 'string')
                options.xslParamAttribute = xslParamAttribute;
                
            if (typeof xmlStringParser === 'function')
                options.xmlStringParser = xmlStringParser;

        },
        
        /// <summary>
        /// Transforms an XML document using a specified XSLT, passing in any
        /// XSLT parameters that are supplied and taking care of cross browser
        /// compatability issues automatically.
        /// </summary>
        transform: function (xmlSource, xslSource, parameters) {
            var xml = (isXML(xmlSource)) ? parseXMLString(xmlSource) 
                    : loadXML(xmlSource),
                xsl = (isXML(xslSource)) ? parseXMLString(xslSource) 
                    : loadXSL(xslSource);

            if (window.ActiveXObject || "ActiveXObject" in window) {
                return getActiveXTransform(xml, xsl, parameters);
            }
            else {
                return getTransformFragment(xml, xsl, parameters);
            }
        },

        /// <summary>
        /// Gets transformed version of an XML document using transform() then
        /// replaces the content of a target DOM element with the result.
        /// </summary>
        transformAndReplace: function (target, xmlSource, xslSource,
            parameters) {
            var transformed = x.transform(xmlSource, xslSource, parameters);

            if (typeof target === 'string') {
                // If a query selector is passed in, then find the requested
                // DOM node else expect a DOM node to have been passsed.
                target = document.querySelector(target)
            }

            if (window.ActiveXObject || "ActiveXObject" in window) {
                target.innerHTML = transformed;
                execBodyScripts(target);

            }
            else {
                target.appendChild(transformed);
                execBodyScripts(target);
            }
            
        },

        /// <summary>
        /// Search through the DOM for elements which match the specified
        /// selector and apply transformAndReplace() to their contents where a
        /// source XML and XSLT file are specified by attributes.
        /// </summary>
        /// <remarks>
        /// If no selector is specified, will parse all elements on the page.
        /// </remarks>
        parse: function (selector) {

            if (typeof selector !== 'string')
                selector = '';

            // Find all elements which are marked up to use Magic XML.
            var elements = document.querySelectorAll(selector +
                '[' + options.xmlSourceAttribute +
                '][' + options.xslSourceAttribute + ']');
            
            // Automatically deal with appropriately marked up DOM elements.
            for (j=0; j < elements.length; j++) {
                elementParams = undefined;
                element = elements[j];

                // Pull in any parameters the element may want to pass.
                if (element.attributes[options.xslParamAttribute]) {
                    elementParams = JSON
                        .parse(element.attributes[options.xslParamAttribute]
                        .value);
                }

                x.transformAndReplace(element,
                    element.attributes[options.xmlSourceAttribute].value,
                    element.attributes[options.xslSourceAttribute].value,
                    elementParams);
            }

            if (elements.length === 0) {
                // If no Magic XML marked up objects found, inform users in
                // case of mis-configuration.
                console.warn('[Magic XML] No magic detected on page, is script loaded after all DOM elements?');
            }
        }
    };

    // Throw 'x' into global scope to allow use in other scripts.
    window.magicXML = x;
    
}(window, document);
