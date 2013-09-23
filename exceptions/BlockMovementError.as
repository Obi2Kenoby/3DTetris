package exceptions
{
	import as3isolib.geom.Pt;

	public class BlockMovementError extends Error
	{
		private var x:int;
		private var y:int;
		private var z:int;
		
		public function BlockMovementError(x:int, y:int, z:int, msg:String="")
		{
			super(msg);
			this.x = x;
			this.y = y;
			this.z = z;
		}
		
		public function getIllegalBlockLocation():Pt
		{
			return new Pt(x,y,z);
		}
	}
}