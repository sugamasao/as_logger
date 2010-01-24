/**
 * Logger.log クラスの動作確認用クラスです。
 * 不要の場合がほとんどだと思うので、削除して使用してください。
 */
package {

	import flash.events.Event;
	import flash.display.MovieClip;
	import logger.Logger;

	/**
	 * Loggerクラスの動作確認用のクラスです
	 *  @author sugamasao
	 */
	public class LoggerDrive extends MovieClip {

		/**
		 *  コンストラクタ
		 */
		public function LoggerDrive() {
			stage ? initialize() : addEventListener(Event.ADDED_TO_STAGE, initialize);
		}

		/**
		 *  初期化を行う
		 *  @param event イベント
		 */
		private function initialize(event:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			// 動作確認
			Logger.log("文字列だけの場合"); // 文字列
			Logger.log({"hoge":this, "fuga":1}); // Object
			Logger.log("文字列と配列", [1, 2, 3]); // 配列
			Logger.log("MovieClipの場合", new MovieClip()) // MovieClip
		}
	}
}

