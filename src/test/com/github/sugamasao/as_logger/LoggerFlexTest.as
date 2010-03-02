package test.com.github.sugamasao.as_logger
{
	import org.flexunit.Assert;
	import org.hamcrest.*;
	import org.hamcrest.core.*;
	import org.hamcrest.text.*;
	import com.github.sugamasao.as_logger.Logger;

	import flash.utils.getQualifiedClassName;
	import mx.collections.*;
	import mx.controls.*;

	/**
	 * Logger クラスのテスト用クラス
	 * Flex 特有のクラスをテスト
	 */
	public class LoggerFlexTest {

		private var className:String = "";

		/******************************************************
		* セットアップ実施
		*******************************************************/
		/*
		 * テスト毎に実行される
		 */
		[Before]
		public function alsoRunBeforeEveryTest():void { 
			trace("before");
		}

		/*
		 * テスト毎に実行される
		 */
		[After]
		public function runAfterEveryTest():void {
			trace("after");
			className = null; 
		}

		/******************************************************
		* テスト実施
		*******************************************************/
		[Test(description="ログ確認のテスト(Image)"), ]
		public function loggerLogImageTest():void {
			var image:Image = new Image();
			image.name = "test_name";
			image.source = "http://example.com/hoge.png";
			className = getQualifiedClassName(image);
			assertThat(Logger.log(image), containsString("test_name(id:`null`)(source:\"http://example.com/hoge.png\")" + "<" + className + ">"));
			// id がある場合
			image.id = "img";
			assertThat(Logger.log(image), containsString("test_name(id:\"img\")(source:\"http://example.com/hoge.png\")" + "<" + className + ">"));
		}

		[Test(description="ログ確認のテスト(ArrayCollection)"), ]
		public function loggerLogArrayCollectionTest():void {
			var list:ArrayCollection = new ArrayCollection();
			var source:Array = [1, "str", {key:"value"}];
			list.source = source;
			className = getQualifiedClassName(ArrayCollection);
			assertThat(Logger.log(list), containsString("[1<int>,\"str\",{\"key\":\"value\"}<Object>](length:3)<" + className + ">"));
		}

		[Test(description="ログ確認のテスト(XMLListCollection)"), ]
		public function loggerLogXMLListCollectionTest():void {
			var list:XMLListCollection = new XMLListCollection();
			var xml:XML = <books><book attr="hoge">1</book><book attr="fuga">2</book></books>;
			var source:XMLList = xml.book;
			list.source = source;
			className = getQualifiedClassName(XMLListCollection);
			assertThat(Logger.log(list), containsString("[<book attr=\"hoge\">1</book><XML>,<book attr=\"fuga\">2</book><XML>](length:2)<" + className + ">"));
		}
	}
}
