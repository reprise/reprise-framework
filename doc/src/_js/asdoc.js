function toggleClassList(id)
{
	var listEntry = $(id);
	if (listEntry.hasClass('expanded'))
	{
		listEntry.removeClass('expanded');
		setPackageListItemExpanded(id, false);
	}
	else
	{
		listEntry.addClass('expanded');
		setPackageListItemExpanded(id, true);
	}
	return false;
}

function setPackageListItemExpanded(id, isExpanded)
{
	var ids = (Cookie.read('packageExpansionState') || '').split('|');
	if (isExpanded)
	{
		if (ids.contains(id)) return;
		ids.push(id);
	}
	else
	{
		ids = ids.erase(id);
	}
	Cookie.write('packageExpansionState', ids.join('|'));
}

function restorePackageTree()
{
	var ids = (Cookie.read('packageExpansionState') || '').split('|');
	var i = ids.length;
	while (i--)
	{
		var elem = $(ids[i]);
		if (elem) elem.addClass('expanded');
	}
}