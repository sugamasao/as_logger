/**
 * Logger クラスです。
 * - 実行方法
 *  Logger.log("hoge") // 引数は複数渡すことが可能
 *  Logger.log(obj. "fuga") // 引数は複数渡すことが可能
 * 
 * - 設定パラメータ
 * Logger.isFullPath(Boolean) ログ出力時のファイル名をフルパスで表示するかどうか
 *   デフォルト false で、フルパスでは表示しない
 * Logger.writeTarget(uint) WRITE_TARGET_XXX を用いて設定してください。ログ出力対象を変更します。
 *   デフォルト WRITE_TARGET_FULL で、trace ログとブラウザ上のconsole.log(またはステータスバー)に出力します。
 */
package logger {

	import flash.external.ExternalInterface;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

  /**
   * trace 及び console.log へのログ出力クラス
   *  @author sugamasao
   */
  public class Logger {

	/*********************************************
	* 出力方法変更用パラメータ(設定用の低数値)
	*********************************************/
	public static const WRITE_TARGET_FULL:uint = 0;         // すべて出力
	public static const WRITE_TARGET_TRACE_ONLY:uint = 1;   // trace のみ
	public static const WRITE_TARGET_CONSOLE_ONLY:uint = 2; // JSでの console.log （なければステータスバー）に出力
	public static const WRITE_TARGET_NOTHING:uint = 999;    // 出力しない
	
	/*********************************************
	* 出力方法変更用パラメータ
	*********************************************/
	public static var writeTarget:uint = WRITE_TARGET_FULL; // WRITE_TARGET_XXX を設定することでログ出力先を変更します
	
	/*********************************************
	* 出力フォーマット変更パラメータ
	*********************************************/
	// true:フルパスで表示
	public static var isFullPath:Boolean = false;

	/**
	 *  コンストラクタ
	 *  このクラスのメソッドは static で提供しているので、 new する必要はありません。
	 */
	public function Logger() {
		throw new Error("this class is static library");
	}

	/**
	 *  ログ出力メソッドです。
	 *  WRITE_TARGET について
	 *  * WRITE_TARGET_FULL         : すべての出力先に出力します
	 *  * WRITE_TARGET_TRACE_ONLY   : trace にのみ出力します
	 *  * WRITE_TARGET_CONSOLE_ONLY : JSの console.log なければ window.status に出力します
	 *  * WRITE_TARGET_NOTTHING     : ログを出力しません。整形処理もおこないません。
	 * 出力フォーマット
	 * [yyyy/mm/ddThh:mm:ss] ファイルパス:行数$クラス名#メソッド名 [引数内容<Class名>]
	 * @param 出力内容(複数可)
	 */
	public static function log(... args):void {
		// ログ出力なしの設定だったら何もしないよ
		if(writeTarget === WRITE_TARGET_NOTHING) {
			return;
		}

		var debugInfo:String = getMetaData(new Error().getStackTrace());
		var argsInfo:Array =[];
		for each(var arg:* in args) {
			argsInfo.push(parseObject(arg));
		}
		var dateInfo:String = createDateFormat(new Date);

		var message:String = [dateInfo, debugInfo, argsInfo.join(",")].join(" ");

		// 整形したテキストを出力します
		writeLog(writeTarget, message);
    }

	/**
	 * エラーオブジェクトからファイル名等を取得するかを
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
		try {
			targetLine = stackTrace.split("\n")[2];
			if(isFullPath) {
				// フルのファイルパス
				fileName = targetLine.match( /at .+\[(.*)\:\d+\]/)[1];
			} else {
				// ファイル名だけ
				fileName = targetLine.match( /at .+\[\/.+\/(.*)\:\d+\]/)[1];
			}
			methodName = targetLine.match( /at (.+)\[.+[\.|\\]as\:\d+\]/)[1].replace("/", "#");
			lineNumber = targetLine.match( /at .+\[.+[\.|\\]as\:(\d+)\]/)[1];
			debugInfo  = fileName + ":" + lineNumber + "@" + methodName;
		} catch(e:Error) {
			debugInfo = targetLine.match( /at (.+)/)[1].replace("/", "#");
		}

		return debugInfo;
	}

	/**
	 * 現在時刻を文字列表現にする
	 * @param Date オブジェクト
	 * @return YYYY/MM/DDThh:mm:ss フォーマットの文字列表現
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
	 * 文字列表現に戻します。
	 * @param obj なんでも良いよ
	 * @return "文字列表現<クラス名>"の文字列
	 */
	private static function parseObject(obj:*):String {
		var className:String = getQualifiedClassName(obj);
		var result:Array = [];
		var resultMessage:String = "";
		
		if(className === "Object" || className === "Dictionary") {
			for (var key:* in obj) {
				result.push(parseObject(key) + ":" + parseObject(obj[key]));
			}
			resultMessage = "[" + result.join(",") + "]";
		} else if(className === "Array") {
			for each(var a:* in obj) {
				result.push(parseObject(a));
			}
			resultMessage = "[" + result.join(",") + "]";
		} else {
			if(obj.toString().match(/\[object /)) { // [object hoge] の場合
				if(obj.name) {
					resultMessage = obj.name;
				}
			}
			if(resultMessage == "") {
				resultMessage = obj.toString();
			}
		}

		return resultMessage + "<" + className + ">";
	}

	/**
	 * 実際にどのアウトプット先に出力するかを決定する
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
	 * トレースログへの出力
	 */
	private static function writeTrace(message:String):void {
		trace(message);
	}

	/**
	 * JS でのconsoleへのログ出力。
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
			ExternalInterface.call(script, message);
		}
	}

  }
}
