/**
 * Logger.log クラスの動作確認用クラスです。
 * 不要の場合がほとんどだと思うので、削除して使用してください。
 */
package {

	import flash.events.Event;
	import flash.display.MovieClip;
	import com.github.sugamasao.as_logger.Logger;

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
			Logger.log("===== 動作確認 =====");
			Logger.log({"hoge":this, "fuga":1}); // Object
			Logger.log("array", [1, 2, 3]); // array
			Logger.log("MovieClip", new MovieClip()) // MovieClip
			
			// デフォルト値
			Logger.log("===== Loggerデフォルト値の確認 =====");
			Logger.log("Logger.writeTargetのデフォルト値", Logger.writeTarget);
			Logger.log("Logger.isFullPathのデフォルト値",  Logger.isFullPath);
			
			// 各種動作変更
			Logger.log("===== Logger出力先変更の確認 =====");
			Logger.writeTarget = Logger.WRITE_TARGET_CONSOLE_ONLY;
			Logger.log("☆コンソールのみ");
			Logger.writeTarget = Logger.WRITE_TARGET_TRACE_ONLY;
			Logger.log("●traceログのみ");
			Logger.writeTarget = Logger.WRITE_TARGET_NOTHING;
			Logger.log("出力されないよ");
			Logger.writeTarget = Logger.WRITE_TARGET_FULL;
			Logger.log("☆●両方に出力");
			
			// フルパスかどうかの確認
			Logger.log("==== デフォルト値の確認 =====");
			Logger.log("Logger.writeTargetのデフォルト値", Logger.writeTarget);
			Logger.log("Logger.isFullPathのデフォルト値",  Logger.isFullPath);
			
			// 各種動作変更
			Logger.log("===== Logger出力先変更の確認 =====");
			Logger.writeTarget = Logger.WRITE_TARGET_CONSOLE_ONLY;
			Logger.log("☆コンソールのみ");
			Logger.writeTarget = Logger.WRITE_TARGET_TRACE_ONLY;
			Logger.log("●traceログのみ");
			Logger.writeTarget = Logger.WRITE_TARGET_NOTHING;
			Logger.log("出力されないよ");
			Logger.writeTarget = Logger.WRITE_TARGET_FULL;
			Logger.log("☆●両方に出力");
			
			// フルパスかどうかの確認
			Logger.log("===== Logger出力時のファイル名変更 =====");
			Logger.isFullPath = true;
			Logger.log("このログはフルパスが出力される");
			Logger.isFullPath = false;
			Logger.log("このログはファイル名が出力される");
		}
	}
}

