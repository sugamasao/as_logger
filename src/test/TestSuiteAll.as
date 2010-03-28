package test {
	import org.flexunit.Assert;
	import test.com.github.sugamasao.as_logger.*;
	import com.github.sugamasao.as_logger.Logger;

	[Suite]
	[RunWith("org.flexunit.runners.Suite")]   
	public class TestSuiteAll {
		public var t1:LoggerBasicTest;
		public var t2:LoggerFlexTest;
		public var t3:LoggerPPTest;

	}
}
