var StatusBar =
{
	onLoad: function()
	{
		this.initialized = true;
	},

	onClickImage: function(e, image)
	{
		if (e.button == 0)
		{
			var re = /^(.+)?\/statusbar(\d)\.png$/gi

			var match = re.exec(image.src);
			if (match && match.length == 3)
			{
				match[2] ^= 1;
				image.src = match[1] + "/statusbar" + match[2] + ".png";

				alert("Bookmark Synchronizer statusbar image click!");
			}
		}
	},

	onClickMenuItem: function(e, clicked)
	{
		switch(clicked)
		{
			case 'item1':
				alert("Bookmark Synchronizer statusbar menu: " + clicked);
				break;
				
			default:
				alert("unknown menu item selection");
		};
	},
};

window.addEventListener("load", function(e) { StatusBar.onLoad(e) }, false);
