package;

@:forward
abstract AStateMachine<T1,T2>(Machine) from Machine {
	public inline function new(o) this = o;

	public inline function rule(params:{event:T1, src:T2, dst:T2}):AStateMachine<T1,T2> {
		this.rule(params.event + "",untyped params.src,untyped params.dst);
		return this;
	}

}
