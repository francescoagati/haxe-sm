package;

import haxe.macro.Expr;

class MachineTools {
	public static macro function _rule<T1, T2>(machine:ExprOf<AStateMachine<T1, T2>>, params:ExprOf<{event:T1, src:T2, dest:T2}>) {
		return macro null;
	}
}
