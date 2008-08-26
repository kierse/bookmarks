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
			'method': 'request',
			'version': '1.1',
			'params':
			[
				{
					'args': [],
					'handler': 'Server',
					'method': 'version',
					'token' : {'username': 'userA', 'password': 'pass'}
				},
			]
		};

		var encodedRequest = JSONObject.encode(request);
		dump("Encoded request: " + encodedRequest + "\n");

		// generate http request and send message
		var req = new XMLHttpRequest();
		req.open('GET', 'http://localhost/handler/bookmarks', true);
		req.overrideMimeType('application/json');
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
