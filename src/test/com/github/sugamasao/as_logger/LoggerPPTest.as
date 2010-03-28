package test.com.github.sugamasao.as_logger
{
	import org.flexunit.Assert;
	import org.hamcrest.*;
	import org.hamcrest.core.*;
	import org.hamcrest.text.*;
	import com.github.sugamasao.as_logger.Logger;

	import flash.display.Sprite;
	import flash.utils.getQualifiedClassName;
	import mx.collections.*;
	import mx.controls.*;

	/**
	 * Logger クラスのテスト用クラス
	 * Flex 特有のクラスをテスト
	 */
	public class LoggerPPTest {

		private var className:String = "";

		/******************************************************
		* セットアップ実施
		*******************************************************/
		/*
		 * テスト毎に実行される
		 */
		[Before]
		public function alsoRunBeforeEveryTest():void { 
		}

		/*
		 * テスト毎に実行される
		 */
		[After]
		public function runAfterEveryTest():void {
			className = null; 
		}

		/******************************************************
		* テスト実施
		*******************************************************/
		[Test(description="PPメソッド確認のテスト(Object)"), ]
		public function loggerPPObjectTest():void {
			trace(Logger.pp([1, 2]))
			trace(Logger.pp(new Sprite()))
		}
	}
}
