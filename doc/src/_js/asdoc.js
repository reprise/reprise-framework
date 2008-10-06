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
			item.setStyle('display', 'none');
			item.setStyle('opacity', '0');
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
	
	$$('.protected').each(function(item, i)
	{
		if (checkbox.checked)
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
		else
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
	});
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

window.addEvent('domready', initTooltips);