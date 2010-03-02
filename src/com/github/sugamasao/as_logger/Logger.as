/**
 * com.github.sugamasao.as_logger.Logger クラス
 * repository : http://github.com/sugamasao/as_logger
 */
package com.github.sugamasao.as_logger {

	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
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
		
		// include Version file. "public const VERSION"
		include "./Version.as";
		
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
		public static var writeTarget:uint = WRITE_TARGET_FULL; // WRITE_TARGET_XXX を設定することでログ出力先を変更します
		
		/**
		 * 出力ファイル名フォーマット変更パラメータ.
		 * 
		 * @default false (ファイル名のみ出力)
		 */
		public static var isFullPath:Boolean = false; // true でフルパス表示
	
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
		 * Logger.log("hoge", mc);</listing>
		 * 
		 * 出力フォーマット.
		 * 
		 * <pre>
		 * [yyyy-mm-ddThh:mm:ss] ファイルパス:行数@クラス名#メソッド名 [引数内容<Class名>]
		 * </pre>
		 * 
		 * @param args 出力内容(複数可)
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
				argsInfo.push("{###parseObjectError###}")
			}
			var dateInfo:String = createDateFormat(new Date);
			
			var message:String = [dateInfo, debugInfo, argsInfo.join(",")].join(" ");
			
			// 整形したテキストを出力します
			writeLog(writeTarget, message);
			
			return message;
	    }
	
		/**
		 * エラーオブジェクトからファイル名等を取得する.
		 *
		 * ただし、デバッグ版プレイヤーでしか使えない
		 * @param デバッグ情報（Errorのスタックトレース）
		 * @return 整形された文字列（file:行番号@メソッド名）
		 */
		private static function getMetaData(stackTrace:String):String {
			var targetLine:String = "";
			var debugInfo:String = "";
			var fileName:String = "";
			var methodName:String = "";
			var lineNumber:String = "";
			// ref.http://d.hatena.ne.jp/terracken/20080409/1207699049
			try {
				targetLine = stackTrace.split("\n")[2];
				if(isFullPath) {
					// フルのファイルパス
					fileName = targetLine.match( /at .+\[(.*\..+)\:\d+\]/)[1];
				} else {
					// ファイル名だけ
					fileName = targetLine.match( /at .+\[.+[\/|\\](.*\..+)\:\d+\]/)[1];
				}
				methodName = targetLine.match( /at (.+)\[.+[\.|\\]as\:\d+\]/)[1].replace("/", "#");
				lineNumber = targetLine.match( /at .+\[.+[\.|\\]as\:(\d+)\]/)[1];
				debugInfo  = fileName + ":" + lineNumber + "@" + methodName;
			} catch (e:Error) {
				try {
					debugInfo = targetLine.match( /at (.+)/)[1].replace("/", "#");
				} catch (e2:Error) {
					debugInfo = "{###class or method get error###}"
				}
			}
	
			return debugInfo;
		}
	
		/**
		 * 現在時刻を文字列表現にする.
		 * 
		 * @param Date オブジェクト
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
		 * @param obj なんでも良いよ
		 * @return "文字列表現<クラス名>"の文字列
		 */
		private static function parseObject(obj:*):String {
			var className:String = getQualifiedClassName(obj);
			var result:Array = [];
			var resultMessage:String = "";
			var isClassNameShow:Boolean = true;
			
			if(obj is String) {
				resultMessage = '"'+obj+'"';
				isClassNameShow = false;
			} else if(obj == null) {
				resultMessage = "`null`";
				isClassNameShow = false;
			} else if(className === "Object" || obj is Dictionary) {
				for (var key:* in obj) {
					result.push(parseObject(key) + ":" + parseObject(obj[key]));
				}
				resultMessage = "{" + result.join(",") + "}";
			} else if(obj is Array) {
				for each(var a:* in obj) {
					result.push(parseObject(a));
				}
				resultMessage = "[" + result.join(",") + "]";
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
			} else {
				if(obj.toString().match(/\[object /) || obj.hasOwnProperty("name")) { // [object hoge] か Sprite 系の場合
					if(obj.hasOwnProperty("name")) {
						resultMessage = obj.name;
						if(obj.hasOwnProperty("id")) { // Flex の コンポーネント の場合を考慮.
							resultMessage += "(id:" + parseObject(obj.id) + ")";
						}
						if(obj.hasOwnProperty("source")) { // Flex の Image 等の場合を考慮.
							resultMessage += "(source:" + parseObject(obj.source) + ")";
						}
					}
				}
				
				// イテレータブルなオブジェクトだったら再帰的に処理をする
				if(obj.hasOwnProperty("length")) { // 
					var listMessage:Array = [];
					for each(var list:* in obj) {
						listMessage.push(parseObject(list))
					}
					resultMessage += "[" + listMessage.join(",")  + "]"
					resultMessage += "(length:" + obj.length.toString() + ")";
				}
				
				if(resultMessage == "") {
					resultMessage = obj.toString();
				}
			}
			
			// 改行を除去
			resultMessage = resultMessage.replace(/\r?\n|\r/g, "");
			
			return isClassNameShow ? (resultMessage + "<" + className + ">") : resultMessage;
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
