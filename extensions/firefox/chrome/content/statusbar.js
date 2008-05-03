var StatusBar =
{
	onLoad: function()
	{
		this.initialized = true;
	},

	onClick: function()
	{
		alert("Bookmark Synchronizer statusbar click!");
	},

	onContextClick: function()
	{
		alert("Bookmark Synchronizer statusbar context click!");
	},

	onContextOptionClick: function()
	{
		alert("Bookmark Synchronizer statusbar context menu click!");
	}
};

window.addEventListener("load", function(e) { StatusBar.onLoad(e) }, false);
