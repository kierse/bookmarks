var ToolsMenu = 
{
	onLoad: function() 
	{
		this.initialized = true;
	},

	onClickMenuItem: function(e, clicked)
	{
		switch(clicked)
		{
			case 'item1':
				alert("Bookmark Synchronizer toolsmenu: " + clicked);
				break;

			default:
				alert("unknown menu item selection");
		};
	},
};

window.addEventListener("load", function(e) { ToolsMenu.onLoad(e) }, false);
