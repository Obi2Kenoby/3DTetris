package gameUI
{
	public class GameData
	{
		private var cellSize:int;
		private var gridXSize:int;
		private var gridYSize:int;
		protected var playHeight:int;
		
		/**
		 * Init game data
		 */
		public function GameData()
		{
			cellSize = 20;
			gridXSize = 6;
			gridYSize = 6;
			playHeight = 13;
		}
		
		public function getCellSize():int
		{
			return cellSize;
		}
		
		public function getGridXSize():int
		{
			return gridXSize;
		}
		
		public function getGridYSize():int
		{
			return gridYSize;
		}
		
		public function getPlayHeight():int
		{
			return playHeight;
		}
	}
}