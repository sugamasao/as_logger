package test.com.github.sugamasao.as_logger
{
	import org.flexunit.Assert;
	import org.hamcrest.*;
	import org.hamcrest.core.*;
	import org.hamcrest.text.*;
	import com.github.sugamasao.as_logger.Logger;

	import flash.display.Sprite;
	import flash.events.*;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	import mx.collections.*;
	import mx.controls.*;

	/**
	 * Logger クラスのテスト用クラス
	 */
	public class LoggerBasicTest {

		private var className:String = "";

		/******************************************************
		* セットアップ実施
		*******************************************************/
		/*
		 * テスト毎に実行される
		 */
		[Before]
		public function alsoRunBeforeEveryTest():void { 
			Logger.isFullPackage = false; // default
//			trace("before");
		}

		/*
		 * テスト毎に実行される
		 */
		[After]
		public function runAfterEveryTest():void {
//			trace("after");
			className = null; 
		}

		/******************************************************
		* テスト実施
		*******************************************************/
		/**
		 * インスタンス化しないことのテスト
		 */
		[Test(expected="Error", description="new するとエラーになるのを確認"), ]
		public function loggerNewTest():void {
			new Logger();
		}

		[Test(description="ログ確認のテスト(Int)"), ]
		public function loggerLogIntTest():void {
			className = getQualifiedClassName(0);
			assertThat(Logger.log(10), containsString("10<" + className + ">"));
		}

		[Test(description="ログ確認のテスト(String)"), ]
		public function loggerLogStringTest():void {
			assertThat(Logger.log("string"), containsString("\"string\""));
		}

		[Test(description="ログ確認のテスト(Null)"), ]
		public function loggerLogNullTest():void {
			assertThat(Logger.log(null), containsString("`null`"));
		}

		[Test(description="ログ確認のテスト(Object)"), ]
		public function loggerLogObjectTest():void {
			className = getQualifiedClassName({});
			assertThat(Logger.log({key:"value"}), containsString("{\"key\":\"value\"}<" + className + ">"));
		}

		[Test(description="ログ確認のテスト(Dictionary)")]
		public function loggerLogDictionaryTest():void {
			var d:Dictionary = new Dictionary();
			className = getQualifiedClassName(d);
			d["key"] = "value"
			assertThat(Logger.log(d), containsString("{\"key\":\"value\"}<" + className + ">"));
		}

		[Test(description="ログ確認のテスト(Array)"), ]
		public function loggerLogArrayTest():void {
			className = getQualifiedClassName([]);
			assertThat(Logger.log([1, "str"]), containsString("[1<int>,\"str\"]<" + className + ">"));
		}

		[Test(description="ログ確認のテスト(URLLoader)"), ]
		public function loggerLogURLLoaderTest():void {
			var loader:URLLoader = new URLLoader();
			className = getQualifiedClassName(loader);
			assertThat(Logger.log(loader), containsString("[dataFormat=" + URLLoaderDataFormat.TEXT  + " data=`null`]<" + className + ">"));
			loader.dataFormat = URLLoaderDataFormat.BINARY
			assertThat(Logger.log(loader), containsString("[dataFormat=" + URLLoaderDataFormat.BINARY  + " data=<BINARY>]<" + className + ">"));
		}

		[Test(description="ログ確認のテスト(Error)"), ]
		public function loggerLogErrorTest():void {
			var errorString:String = "error test";
			var e:Error = new Error(errorString);
			className = getQualifiedClassName(e)
			assertThat(Logger.log(e), containsString("[errorID=0 message=" + errorString + " name=Error]<" + className + ">"));
		}

		[Test(description="ログ確認のテスト(Sprite)"), ]
		public function loggerLogSpriteTest():void {
			var name:String = "sprite test";
			var sprite:Sprite = new Sprite();
			className = getQualifiedClassName(sprite);
			sprite.name = name;
			assertThat(Logger.log(sprite), containsString(name + "<" + className + ">"));
		}

		[Test(description="ログ確認のテスト(入れ子なオブジェクト)")]
		public function loggerLogObjectSpriteTest():void {
			var name:String = "sprite test";
			var sprite:Sprite = new Sprite();
			className = getQualifiedClassName(sprite);
			sprite.name = name;
			var obj:Object = {"s":sprite};
			assertThat(Logger.log(obj), containsString("{\"s\":" + name + "<" + className + ">}<Object>"));
		}

		[Test(description="ログ確認のテスト(さらに入れ子なオブジェクト)")]
		public function loggerLogObjectInObjectSpriteTest():void {
			var name:String = "sprite test";
			var sprite:Sprite = new Sprite();
			className = getQualifiedClassName(sprite);
			sprite.name = name;
			var obj:Object = {"s":sprite};
			var o:Object = {"obj":obj};
			assertThat(Logger.log(o), containsString("{\"obj\":{\"s\":" + name + "<" + className + ">}<Object>}<Object>"));
		}

		[Test(description="ログ確認のテスト(入れ子なオブジェクト)")]
		public function loggerLogArraySpriteTest():void {
			var name:String = "sprite test";
			var sprite:Sprite = new Sprite();
			className = getQualifiedClassName(sprite);
			sprite.name = name;
			var array:Array = [sprite];
			assertThat(Logger.log(array), containsString("[" + name + "<" + className + ">]<Array>"));
		}

		[Test(description="ログ確認のテスト(さらに入れ子なオブジェクト)")]
		public function loggerLogArrayInArraySpriteTest():void {
			var name:String = "sprite test";
			var sprite:Sprite = new Sprite();
			className = getQualifiedClassName(sprite);
			sprite.name = name;
			var array:Array = [sprite];
			var a:Array = [array];
			assertThat(Logger.log(a), containsString("[[" + name + "<" + className + ">]<Array>]<Array>"));
		}

		[Test(description="ログ確認のテスト(XML)")]
		public function loggerLogXMLTest():void {
			var xml:XML = <foo>hoge</foo>;
			assertThat(Logger.log(xml), containsString("<foo>hoge</foo><XML>"));
		}

		[Test(description="ログ確認のテスト(XMLList)")]
		public function loggerLogXMLListTest():void {
			var xml:XML = <list><foo>hoge</foo><foo>fuga</foo></list>;
			var xmlList:XMLList = xml.foo;
			assertThat(Logger.log(xmlList), containsString("<foo>hoge</foo><foo>fuga</foo><XMLList>"));
		}
		
		[Test(description="パッケージ名出力のテスト(デフォルトのフルパッケージ)")]
		public function loggerLogFullPackageTest():void {
			Logger.isFullPackage = true;
			assertThat(Logger.log("sample"), containsString(" test.com.github.sugamasao.as_logger::LoggerBasicTest#loggerLogFullPackageTest()"));
		}

		[Test(description="パッケージ名出力のテスト(パッケージ名省略)")]
		public function loggerLogShortPackageTest():void {
			Logger.isFullPackage = false;
			assertThat(Logger.log("sample"), containsString(" LoggerBasicTest#loggerLogShortPackageTest()"));
		}

	}
}
