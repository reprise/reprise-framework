package reprise.data.validators
{
	import reprise.commands.ICommand;
	
	public interface IDataValidator extends ICommand
	{
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		function setDataForValidation(data:Object):void
	}
}