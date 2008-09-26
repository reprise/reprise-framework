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
	
	$$('.protected').each(function(item, i)
	{
		if (checkbox.checked)
		{
			item.setStyle('display', 'block');
			var fx = new Fx.Slide(item, {duration:300});
			fx.slideIn().chain(
				function() 
				{
					var fx = new Fx.Tween(item, {duration:300});
					fx.start('opacity', '1');
				});
		}
		else
		{
			var fx = new Fx.Tween(item, {duration:300});
			fx.start('opacity', '0').chain(
				function()
				{
					var fx = new Fx.Slide(item, {duration:300});
					fx.addEvent('onComplete', function(){this.element.setStyle('display', 'none');});
					fx.slideOut();
				});
		}
	});
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