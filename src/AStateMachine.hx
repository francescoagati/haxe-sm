package;

@:forward
abstract AStateMachine<T1,T2>(Machine) from Machine {
	public inline function new(o) this = o;

	public inline function rule(params:{event:T1, src:T2, dst:T2}):AStateMachine<T1,T2> {
		this.rule(params.event + "",untyped params.src,untyped params.dst);
		return this;
	}

	public inline function on_enter_any(fn) {
		this.action('>*',fn);
	}

	public inline function on_exit_any(fn) {
		this.action('<*',fn);
	}

	public inline function on_enter(s:T2,fn) {
		this.action('>' + s,fn);
	}

	public inline function on_exit(s:T2,fn) {
		this.action('<' + s,fn);
	}

	public inline function send(e:T1) 
		this.send(e + "");


}
