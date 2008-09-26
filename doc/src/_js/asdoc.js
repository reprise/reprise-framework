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


var InfoBubbles;
var preferencesSlideTween;

function initTooltips()
{
	var anchors = $$('a');
	var usedAnchors = [];
	var i = anchors.length;
	while (i--)
	{
		var anchor = anchors[i];
		if (anchor.rel && anchor.rel != '')
		{
			usedAnchors.push(anchor);
		}
	}
	
	InfoBubbles = new Tips(usedAnchors, {className:'tooltip'});
	
	preferencesSlideTween = new Fx.Slide($('filterPreferences'), {duration: 250});
	preferencesSlideTween.addEvent('onComplete', function(){if (!this.open) this.element.setStyle('display', 'none')});
	preferencesSlideTween.hide();
}

function showFilterPreferences()
{
	if (preferencesSlideTween.open)
	{
		preferencesSlideTween.slideOut()
	}
	else
	{
		preferencesSlideTween.element.setStyle('display', 'block');
		preferencesSlideTween.slideIn();
	}
}

function toggleProtectedFields(toggleCheckbox)
{
	var checkbox = $('protectedFieldsCheckbox');
	if (toggleCheckbox)
	{
		checkbox.checked = !checkbox.checked;
	}
}

function toggleInheritedFields(toggleCheckbox)
{
	var checkbox = $('inheritedFieldsCheckbox');
	if (toggleCheckbox)
	{
		checkbox.checked = !checkbox.checked;
	}
}

window.addEvent('domready', initTooltips);