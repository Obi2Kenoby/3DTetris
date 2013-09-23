package exceptions
{
	public class BlockCreationError extends Error
	{
		public function BlockCreationError(msg:String="")
		{
			super(msg);
		}
	}
}