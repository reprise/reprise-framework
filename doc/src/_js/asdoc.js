var cookieStorage = new Storage('filterSettings');


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
	
	preferencesSlideTween = new Fx.Slide($$('#filterPreferences ul')[0], {duration: 250});
	preferencesSlideTween.addEvent('onComplete', function()
	 	{
	 		if (!this.open) this.element.setStyle('display', 'none')
	 	});
	preferencesSlideTween.hide();
	$$('#filterPreferences ul')[0].setStyle('display', 'none');
	
	initFilters();
}

function initFilters()
{
	var hideInheritedFields = cookieStorage.valueForKey('hideInheritedFields');
	var hideProtectedFields = cookieStorage.valueForKey('hideProtectedFields');
	$('inheritedFieldsCheckbox').checked = hideInheritedFields;
	$('protectedFieldsCheckbox').checked = hideProtectedFields;

	function hideElementsWithSelector(selector)
	{
		$$(selector).each(function(item, i)
		{
			item.setStyle('opacity', '0');
			var fx = new Fx.Slide(item);
			fx.hide();
		});
	}
	hideInheritedFields && hideElementsWithSelector('.inherited');
	hideProtectedFields && hideElementsWithSelector('.protected');
	updateFiltersEnabledCheck();
}

function showFilterPreferences()
{
	if (preferencesSlideTween.open)
	{
		$('filterPreferences').removeClass('expanded');
		preferencesSlideTween.slideOut();
	}
	else
	{
		$('filterPreferences').addClass('expanded');
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
	setElementsWithSelectorVisible('.protected', !checkbox.checked);
	cookieStorage.setValueForKey(checkbox.checked, 'hideProtectedFields');
	updateFiltersEnabledCheck();
}

function toggleInheritedFields(toggleCheckbox)
{
	var checkbox = $('inheritedFieldsCheckbox');
	if (toggleCheckbox)
	{
		checkbox.checked = !checkbox.checked;
	}
	setElementsWithSelectorVisible('.inherited', !checkbox.checked);
	cookieStorage.setValueForKey(checkbox.checked, 'hideInheritedFields');
	updateFiltersEnabledCheck();
}

function updateFiltersEnabledCheck()
{
	if (cookieStorage.valueForKey('hideProtectedFields') || 
		cookieStorage.valueForKey('hideInheritedFields'))
	{
		$('filterPreferences').addClass('filter_enabled');
	}
	else
	{
		$('filterPreferences').removeClass('filter_enabled');
	}
}

function setElementsWithSelectorVisible(selector, visible)
{
	$$(selector).each(function(item, i)
	{
		if (!visible)
		{
			var fx = new Fx.Tween(item, {duration:300});
			fx.start('opacity', '0').chain(
				function()
				{
					var fx = new Fx.Slide(item, {duration:300});
					fx.slideOut();
				});
		}
		else
		{
			var fx = new Fx.Slide(item, {duration:300});
			fx.slideIn().chain(
				function() 
				{
					var fx = new Fx.Tween(item, {duration:300});
					fx.start('opacity', '1');
				});
		}
	});
}

window.addEvent('domready', initTooltips);