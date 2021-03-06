﻿/**
 * com.github.sugamasao.as_logger.Logger クラス
 * repository : http://github.com/sugamasao/as_logger
 */
package com.github.sugamasao.as_logger {

	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	/**
	 * trace 及び console.log へのログ出力クラス.
	 *
	 *  @author sugamasao
	 * - 実行方法
	 *  Logger.log("hoge") // 引数は複数渡すことが可能
	 *  Logger.log(obj, "fuga") // 引数は複数渡すことが可能
	 *
	 */
	public class Logger {

		public static const VERSION:String  = "v1.9.3";

		/**
		 * writeTarget 設定用定数.
		 *
		 * すべての出力先にログを出力する.
		 */
		public static const WRITE_TARGET_FULL:uint = 0;

		/**
		 * writeTarget 設定用定数.
		 *
		 * Flash Trace ログのみに出力する.
		 */
		public static const WRITE_TARGET_TRACE_ONLY:uint = 1;

		/**
		 * writeTarget 設定用定数.
		 *
		 * ブラウザ上のみに出力する.
		 * console.log があれば console.log を使用し、無ければ window.status(ステータスバー)に出力
		 */
		public static const WRITE_TARGET_CONSOLE_ONLY:uint = 2;

		/**
		 * writeTarget 設定用定数.
		 *
		 * 出力しない。ログメッセージ解析処理を行わないので、パフォーマンスへの影響は最小となります.
		 */
		public static const WRITE_TARGET_NOTHING:uint = 999;    // 出力しない

		/**
		 * ログ出力先の方法変更用パラメータ.
		 *
		 * @default WRITE_TARGET_FULL (すべての出力先に出力する)
		 */
		public static var writeTarget:uint = WRITE_TARGET_TRACE_ONLY; // WRITE_TARGET_XXX を設定することでログ出力先を変更します

		/**
		 * 出力ファイル名フォーマット変更パラメータ.
		 *
		 * @default false (ファイル名のみ出力)
		 */
		public static var isFullPath:Boolean = false; // true でフルパス表示

		/**
		 * 出力パスフォーマット変更パラメータ.
		 *
		 * @default false (パッケージ名省略)
		 */
		public static var isFullPackage:Boolean = false; // true でフルパッケージ表示

		/**
		 * ppメソッド用デフォルト出力変数
		 *
		 */
		private static var defaultFormat:Array = ["x", "y", "length", "width", "height", "id", "name", "parent"];

		private static const NULL_STRING:String = "`null`";
		private static const STAGE_OBJECT:String = "StageObject";
		private static const CLASS_NAME_START:String = "<";
		private static const CLASS_NAME_END:String = ">";
		private static const STRING_START:String = '"';
		private static const STRING_END:String = '"';
		private static const ARRAY_START:String = "[";
		private static const ARRAY_END:String = "]";
		private static const ARRAY_SEP:String = ",";
		private static const ARRAY_LENGTH_START:String = "(length:";
		private static const ARRAY_LENGTH_END:String = ")";
		private static const OBJECT_START:String = "{";
		private static const OBJECT_END:String = "}";
		private static const OBJECT_SEP:String = ",";
		private static const KEY_VALUE_SEP:String = ":";

		private static const FLEX_ID_START:String = "(id:";
		private static const FLEX_ID_END:String = ")";
		private static const FLEX_SOURCE_START:String = "(source:";
		private static const FLEX_SOURCE_END:String = ")";

		/**
		 *  このクラスのメソッドは static で提供しているので、 new する必要はありません.
		 *
		 * @throws Error このクラスを new しようとすると発生します.
		 */
		public function Logger() {
			throw new Error("this class is static library");
		}

		/**
		 *  ログ出力メソッドです.
		 *
		 * @example 次のコードはlogメソッドを実際に呼ぶ例です.
		 * <listing version="3.0" >
		 * var mc:MovieClip = new MovieClip();
		 * Logger.log("hoge", mc);
		 * </listing>
		 *
		 * 出力フォーマット.
		 *
		 * <pre>
		 * [yyyy-mm-ddThh:mm:ss] ファイルパス:行数(a)クラス名#メソッド名 [引数内容 Class名 ]
		 * </pre>
		 * @param args:Array 出力内容(複数可)
		 */
		public static function log(... args):String {
			// ログ出力なしの設定だったら何もしないよ
			if(writeTarget === WRITE_TARGET_NOTHING) {
				return "";
			}

			var debugInfo:String = getMetaData(new Error().getStackTrace());
			var argsInfo:Array =[];
			try {
				for each(var arg:* in args) {
					argsInfo.push(parseObject(arg));
				}
			} catch(e:Error) {
				argsInfo.push("{###parseObjectError["+ e.toString() +"]###}")
			}
			var dateInfo:String = createDateFormat(new Date);

			var message:String = [dateInfo, debugInfo, argsInfo.join(",")].join(" ");

			// 整形したテキストを出力します
			writeLog(writeTarget, message);

			return message;
	    }

		/**
		 * 引渡されたオブジェクトを人に見やすい形で出力します.
		 *
		 * 第二引数では出力したいプロパティを文字列の配列として渡すと
		 * そのプロパティを出力します。
		 * デフォルトでは以下のプロパティを（持っていれば）出力します.
		 * <pre>
		 *   ["x", "y", "length", "width", "height", "id", "name", "parent"]
		 * </pre>
		 *
		 * @param pp:* で出力したい変数
		 * @param format:Array 出力用プロパティを指定する。上記とは別の要素を出力したい場合は指定してください
		 * @return 整形された文字列
		 */
		public static function pp(obj:*, format:Array = null):String {
			var result:Array = [];
			var propList:Array = format == null ? defaultFormat : format;

			// 安全に文字列表現にする
			var to_s:Function = function(str:*):String {
				if(str == null) {
					return NULL_STRING;
				} else {
					return str.toString();
				}
			}

			// name を取得するときは id の要素を優先する
			var to_name:Function = function(parent:*):String {
				if(parent == null) return NULL_STRING;

				var nameList:Array = ["id", "name"];
				for each(var nameStr:String in nameList) {
					if(parent.hasOwnProperty(nameStr)) {
						return parent[nameStr];
					}
				}
				return "";
			}

			result.push("className => " + getQualifiedClassName(obj));

			for each(var prop:String in propList) {
				if(obj.hasOwnProperty(prop)) {
					if(prop == "length") {
						var array:Array = [];
						for each(var a:* in obj) {
							array.push(to_s(a));
						}
						result.push("\tinspect=>" + ARRAY_START + array.join(ARRAY_SEP) + ARRAY_START);
					}

					if(prop == "parent") {
						result.push("\t" + prop + "=>" + to_name(obj[prop]) + "(ClassName:" + getQualifiedClassName(obj[prop]) + ")");
					} else {
						result.push("\t" + prop + "=>" + to_s(obj[prop]));
					}
				}
			}

			// 整形したテキストを出力します
			writeLog(writeTarget, result.join("\n"));

			return result.join("\n");
		}

		/**
		 * Logger クラスの文字列表現です
		 *
		 * @return 整形された文字列（file:行番号(a)メソッド名）
		 */
		public static function toString():String {
			var array:Array  = [];
			var name:String  = "";

			array.push(getQualifiedClassName(Logger))
			array.push("version=" + VERSION);
			switch(writeTarget) {
				case WRITE_TARGET_FULL:
					name = "WRITE_TARGET_FULL";
					break;
				case WRITE_TARGET_TRACE_ONLY:
					name = "WRITE_TARGET_TRACE_ONLY";
					break;
				case WRITE_TARGET_CONSOLE_ONLY:
					name = "WRITE_TARGET_CONSOLE_ONLY";
					break;
				case WRITE_TARGET_NOTHING:
					name = "WRITE_TARGET_NOTHING";
					break;
				default:
					name = "unknown:" + writeTarget.toString();
			}
			array.push("writeTarget=" + name);
			array.push("isFullPath=" + isFullPath);
			array.push("isFullPackage=" + isFullPackage);
			return array.join(" ");
		}

		/**
		 * エラーオブジェクトからファイル名等を取得する.
		 *
		 * ただし、デバッグ版プレイヤーでしか使えない
		 * @param stackTrace:String デバッグ情報（Errorのスタックトレース）
		 * @return 整形された文字列（file:行番号(a)メソッド名）
		 */
		private static function getMetaData(stackTrace:String):String {
			var targetLine:String = "";
			var debugInfo:String = "";
			var fileName:String = "";
			var methodName:String = "";
			var lineNumber:String = "";
			// ref.http://d.hatena.ne.jp/terracken/20080409/1207699049

			// 非デバッグ版 FlashPlayer だと stackTrace が null
			if(stackTrace == null) {
				return "{### this player is not debug player ###}"
			}

			try {
				targetLine = stackTrace.split("\n")[2];
				var result:Array = targetLine.match(/at (.+)\[(.+\..+)\:(\d+)\]/);
				methodName = result[1];
				fileName = result[2];
				lineNumber = result[3];
				if(!isFullPath) { // ファイル名だけ
					fileName = fileName.split("\/").pop();
				}
				// フルパスを省略する場合は、パッケージの区切り文字がある場合のみ
				if(!isFullPackage && (methodName.indexOf("::") > -1)) {
					methodName = methodName.match(/::(.+)/)[1];
				}
				debugInfo  = fileName + ":" + lineNumber + "@" + methodName;
			} catch (e:Error) {
				try {
					debugInfo = targetLine.match( /at (.+)/)[1].replace("/", "#");
					if(!isFullPackage && (debugInfo.indexOf("::") > -1)) {
						if(debugInfo.match(/::(.+)/)) {
							debugInfo = debugInfo.match(/::(.+)/)[1];
						}
					}
				} catch (e2:Error) {
					debugInfo = "{###class or method get error["+ e.toString() +"]###}"
				}
			}

			return debugInfo;
		}

		/**
		 * 現在時刻を文字列表現にする.
		 *
		 * @param date:Date オブジェクト
		 * @return [YYYY-MM-DDThh:mm:ss] フォーマットの文字列表現
		 */
		private static function createDateFormat(date:Date):String {
			var dateMessage:String = "[" +
			[date.getFullYear(),date.getMonth()+1, date.getDate()].join("-") +
			"T" +
			[date.getHours(), date.getMinutes(), date.getSeconds()].join(":") +
			"]";

			return dateMessage;
		}

		/**
		 * 文字列表現に戻します.
		 *
		 * @param obj:* なんでも良いよ
		 * @return "文字列表現<クラス名>"の文字列
		 */
		private static function parseObject(obj:*):String {
			var className:String = getQualifiedClassName(obj);
			var result:Array = [];
			var resultMessage:String = "";
			var isClassNameShow:Boolean = true;

			if(obj is String) {
				resultMessage = STRING_START + obj + STRING_END;
				isClassNameShow = false;
			} else if(obj == null) {
				resultMessage = NULL_STRING;
				isClassNameShow = false;
			} else if(className === "Object" || obj is Dictionary) {
				for (var key:* in obj) {
					result.push(parseObject(key) + KEY_VALUE_SEP + parseObject(obj[key]));
				}
				resultMessage = OBJECT_START + result.join(OBJECT_SEP) + OBJECT_END;
			} else if(obj is Array) {
				for each(var a:* in obj) {
					result.push(parseObject(a));
				}
				resultMessage = ARRAY_START + result.join(ARRAY_SEP) + ARRAY_END;
			} else if(obj is URLRequest) {
				var obj_data:String = "";
				if(obj.data is ByteArray) {
					obj_data = String((obj.data as ByteArray).length) + " byte"
				} else if (obj.data is Object) {
					var obj_params:Array = [];
					for (var k:String in obj.data) {
						var v:Object = obj.data[k];
						obj_params.push("param:" + k + "=" + v);
					}
					obj_data = obj_params.join(" ");
				}
				resultMessage = "[url=" + obj.url + " method=" + obj.method + " contentType=" + obj.contentType + " userAgent=" + obj.userAgent + " data=" + obj_data + "]";
			} else if(obj is URLLoader) {
				if(obj.dataFormat == URLLoaderDataFormat.TEXT || obj.dataFormat == URLLoaderDataFormat.VARIABLES) {
					resultMessage = "[dataFormat=" + obj.dataFormat + " data=" + parseObject(obj.data) + "]";
				} else {
					resultMessage = "[dataFormat=" + obj.dataFormat + " data=<BINARY>]";
				}
			} else if(obj is Error) {
					resultMessage = "[errorID=" + obj.errorID + " message=" + obj.message + " name=" + obj.name + "]";
			} else if(obj is XML) {
					resultMessage = obj.toXMLString();
			} else if(obj is Stage) {
					resultMessage = STAGE_OBJECT;
			} else if(obj is DisplayObject) {
				resultMessage = String(obj.name);
				if(obj.hasOwnProperty("id")) { // Flex の コンポーネント の場合を考慮.
					resultMessage += FLEX_ID_START + parseObject(obj.id) + FLEX_ID_END;
				}
				if(obj.hasOwnProperty("source")) { // Flex の Image 等の場合を考慮.
					resultMessage += FLEX_SOURCE_START + parseObject(obj.source) + FLEX_SOURCE_END;
				}
			} else {
				// イテレータブルなオブジェクトだったら再帰的に処理をする
				if(obj.hasOwnProperty("length")) { //
					var listMessage:Array = [];
					for each(var list:* in obj) {
						listMessage.push(parseObject(list));
					}
					resultMessage += ARRAY_START + listMessage.join(ARRAY_SEP)  + ARRAY_END;
					resultMessage += ARRAY_LENGTH_START + String(obj.length) + ARRAY_LENGTH_END;
				}

				if(resultMessage === "") {
					resultMessage = obj.toString();
				}
			}

			// 改行を除去
			resultMessage = resultMessage.replace(/\r?\n|\r/g, "");

			return isClassNameShow ? (resultMessage + CLASS_NAME_START + className + CLASS_NAME_END) : resultMessage;
		}

		/**
		 * 実際にどのアウトプット先に出力するかを決定する.
		 *
		 * @param target:uint 出力先を決定するフラグ
		 * @param message:String 出力メッセージ
		 */
		private static function writeLog(target:uint, message:String):void {
			switch(target) {
				case WRITE_TARGET_FULL:
					writeTrace(message);
					writeConsole(message);
					break;
				case WRITE_TARGET_TRACE_ONLY:
					writeTrace(message);
					break;
				case WRITE_TARGET_CONSOLE_ONLY:
					writeConsole(message);
					break;
				default:
					break;
			}
		}

		/**
		 * トレースログへの出力.
		 */
		private static function writeTrace(message:String):void {
			trace(message);
		}

		/**
		 * JS でのconsoleへのログ出力.
		 */
		private static function writeConsole(message:String):void {
			if(ExternalInterface.available) {
				// ref.http://d.hatena.ne.jp/kiy0taka/20080323/p2
				// ref.http://blog.kaihatsubu.com/archives/001666.html
				var script:String =
				<![CDATA[
					function(message){
						var console = window.console || {};
						console.log = console.log || (function(log) {window.status = log});
						console.log(message);
					}
				]]>
				script = script.replace(/\r?\n|\r/g, "");
				message = message.replace(/\\/g, "\\\\");
				ExternalInterface.call(script, message);
			}
		}
	}
}
