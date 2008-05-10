var Settings =
{
	onLoad: function()
	{
		this.initialized = true;
	},

	getServerVersion: function()
	{
		//alert("getServerVersion");
		
		// create JSON parser object
		var JSONObject = Components.classes["@mozilla.org/dom/json;1"]
			.createInstance(Components.interfaces.nsIJSON);

		// build request object
		var request = 
		{
			'handler': 'Server',
			'method': 'version',
		};

		var encodedRequest = JSONObject.encode(request);
		dump("Encoded request: " + encodedRequest + "\n");

		// generate http request and send message
		var req = new XMLHttpRequest();
		req.open('POST', 'http://localhost:8080/bookmarks', true);
		req.onreadystatechange = function(e)
		{
			if (req.readyState == 4)
			{
				dump("Request status: " + req.status + "\n");
				if (req.status == 200)
					dump(req.responseText + "\n");
				else
					dump("Error retrieving resource!\n");
			}
		};
		req.send(encodedRequest);
	},
};

window.addEventListener("load", function(e) { Settings.onLoad(e) }, false);
