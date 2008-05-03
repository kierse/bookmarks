var ToolsMenu = 
{
	onLoad: function() 
	{
		this.initialized = true;
	},

	onMenuItemCommand: function()
	{
		alert("Bookmark Synchronizer");
	}
};

window.addEventListener("load", function(e) { ToolsMenu.onLoad(e) }, false);
