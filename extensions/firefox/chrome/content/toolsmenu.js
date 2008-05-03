var ToolsMenu = 
{
	onLoad: function() 
	{
		this.initialized = true;
	},

	onClick: function()
	{
		alert("Bookmark Synchronizer preferences!");
	}
};

window.addEventListener("load", function(e) { ToolsMenu.onLoad(e) }, false);
