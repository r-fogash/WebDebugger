function makeAttributes(node) {
        if (typeof node.getAttributeNames === 'undefined') {
            return null
        }
        if (node.getAttributeNames().length == 0) {
            return null
        }
        var object = Object()
        var attrs = node.getAttributeNames()
        for (var i=0; i<attrs.length; ++i) {
            var attributeName = attrs[i]
            object[attributeName] = node.getAttribute(attributeName)
        }
        return object
    }

    function clearObject(object) {
        if ('children' in  object && object.children.length == 0) {
            delete object.children
        }
        return object
    }

    function validateObject(object) {
        var hasChildren =  'children' in  object && object.children.length > 0
        if (!'html' in object && !hasChildren) {
            return false
        }
        if (object.html == "" && !hasChildren) {
            return false
        }
        return true
    }

    function extractString(node) {
        var text = ""
        if ('outerHTML' in node) {
            text = text + node.outerHTML
        }
        if ('textContent' in node) {
            text = text + node.textContent
        }
        if (!('outerHTML' in node) && !('textContent' in node)) {
            text = node.data()
        }
        return text.trim()
    }
        
    function process(node) {
        if (!node.hasChildNodes())
        {
            var object = Object()
            object["html"] = extractString(node)
            var attributes = makeAttributes(node)
            if (attributes != null) {
                object["attributes"] = attributes
            }
            return object
        }
        else
        {
            var processedList = Array()
            for (var i=0; i<node.childNodes.length; i++)
            {
                var child = node.childNodes[i]
                if (child == null)
                {
                    continue
                }
                var processedChild = process(child)
                processedChild = clearObject(processedChild)
                if (validateObject(processedChild)) {
                    processedList.push(processedChild)
                }
            }
            var object = Object()
            object["html"] = extractString(node.cloneNode(false))
            if (processedList.length > 0) {
                object["children"] = processedList
            }

            var attributes = makeAttributes(node)
            if (attributes != null) {
                object["attributes"] = attributes
            }

            return object
        }
    }

var d = document.documentElement.cloneNode(true)
process(d)
