package test.com.github.sugamasao.as_logger
{
		import org.flexunit.Assert;
		import com.github.sugamasao.as_logger.Logger;



	/**
	 * Logger クラスのテスト用クラス
	 */
	public class LoggerTest {


		/** テスト対象クラスのインスタンス */
		private var target:Logger = null;

		/******************************************************
		* セットアップ実施
		*******************************************************/
		/*
		 * テスト毎に実行される
		 */
		[Before]
		public function alsoRunBeforeEveryTest():void { 
			trace("before");
			//target = Logger; 
		}

		/*
		 * テスト毎に実行される
		 */
		[After]
		public function runAfterEveryTest():void {
			trace("after");
			target = null; 
		}

		/**
		 * インスタンス化しないことのテスト
		 */
		[Test(expected="Error", description="new するとエラーになるのを確認"), ]
		public function loggerNewTest():void {
			new Logger();
		}
	}
}
