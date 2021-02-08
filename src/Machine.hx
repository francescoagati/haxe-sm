// https://gist.github.com/jdpalmer/0b86621c82062e7a4dac
using EnumValue;
using haxe.EnumTools;
using haxe.EnumTools.EnumValueTools;

class Machine<E, T:String> {
	static inline final splitter = "###";

	public var currentState:T;

	var transitions:Map<String, T>;
	var actions:Map<String, Void->Void>;
	var pendingEvent:String;
	var processingEvent:Bool;
	var cancellable:Bool;
	var cancelled:Bool;

	public var src:String;
	public var dst:String;
	public var evt:String;

	public var currentEvt:E;

	inline public function reset() {
		processingEvent = false;
		cancellable = false;
		cancelled = false;
		pendingEvent = "";
		src = "";
		dst = "";
		evt = "";
	}

	// Create a new Machine with the specified initial state.
	inline public function new(initial:T) {
		transitions = new Map<String, T>();
		actions = new Map<String, Void->Void>();
		currentState = initial;
		reset();
	}

	// Attach fn to the transition described in specifier.
	//
	// Specifiers use a special prefix minilanguage to annotate how the
	// function should be attached to a transition.  Specifically:
	//
	//   >myState  - Evaluate the action as the machine enters myState.
	//   <myState  - Evaluate the action as the machine leaves myState.
	//   >*        - Evaluate the action before entering any state.
	//   <*        - Evaluate the action after leaving any state.
	//   >>myEvent - Evaluate the action before myEvent.
	//   <<myEvent - Evaluate the action after myEvent.
	//   >>*       - Evaluate the action before responding to any event.
	//   <<*       - Evaluate the action after responding to any event.
	//   !myState  - Evaluate the action if the machine is in myState when
	//               an event is not matched.
	//   !!myEvent - Evaluate the action if myEvent is not matched.
	//   !*        - Evaluate the action for all states where an event is not
	//               matched.
	//   !!!       - Evaluate the action if and only if the match failed
	//               and no other error handling code would be evaluated.
	inline public function action(specifier:String, fn:Void->Void) {
		actions[specifier] = fn;
	}

	// Attempts to cancel an executing event.  If successful the function
	// returns true and false otherwise.
	inline public function cancel():Bool {
		if (!cancellable) {
			return false;
		}
		cancelled = true;
		return true;
	}

	// Fire an event which may cause the machine to change state.
	public function send(event:String) {
		if (cancelled) {
			return;
		}

		if (processingEvent) {
			pendingEvent = event;
			return;
		}

		src = currentState;
		evt = event;
		var ok = transitions.exists(event + splitter + currentState);
		processingEvent = true;

		if (ok) {
			var nextState = transitions[event + splitter + currentState];
			dst = nextState;
			cancellable = true;

			var f = actions[">>" + event];
			if (f != null) {
				f();
			}
			if (cancelled) {
				reset();
				return;
			}
			f = actions[">>*"];
			if (f != null) {
				f();
			}
			if (cancelled) {
				reset();
				return;
			}
			f = actions["<" + currentState];
			if (f != null) {
				f();
			}
			if (cancelled) {
				reset();
				return;
			}
			f = actions["<*"];
			if (f != null) {
				f();
			}
			if (cancelled) {
				reset();
				return;
			}

			currentState = nextState;
			cancellable = false;

			f = actions[">" + currentState];
			if (f != null) {
				f();
			}
			f = actions[">*"];
			if (f != null) {
				f();
			}
			f = actions["<<" + event];
			if (f != null) {
				f();
			}
			f = actions["<<*"];
			if (f != null) {
				f();
			}

			dst = "";
		} else {
			var cnt = 0;
			var f = actions["!!" + event];
			if (f != null) {
				f();
				cnt += 1;
			}
			f = actions["!" + currentState];
			if (f != null) {
				f();
				cnt += 1;
			}
			f = actions["!*"];
			if (f != null) {
				f();
				cnt += 1;
			}
			if (cnt == 0) {
				f = actions["!!!"];
				if (f != null) {
					f();
				}
			}
		}
		src = "";
		evt = "";

		processingEvent = false;

		if (pendingEvent != "") {
			var e = pendingEvent;
			pendingEvent = "";
			send(e);
		}
	}

	public inline function send2(evt:EnumValue) {
		currentEvt = untyped evt;
		send(evt.getName());
	}

	// Return a string with a Graphviz DOT representation of the machine.
	inline public function export():String {
		var export_str = '# dot -Tpng myfile.dot >myfile.png
digraph g {
rankdir="LR";
node[style="rounded",shape="box"]
edge[splines="curved"]';
		export_str += "\n  " + currentState + " [style=\"rounded,filled\",fillcolor=\"gray\"]";
		for (k in transitions.keys()) {
			var dst = transitions[k];
			var a = k.split(splitter);
			var event = a[0];
			var src = a[1];
			export_str += src + " -> " + dst + " [label=\"" + event + "\"];\n";
		}
		export_str += "}";
		return export_str;
	}

	// Returns true if state is the current state
	inline public function isState(state:String):Bool {
		if (currentState == state) {
			return true;
		}
		return false;
	}

	// Returns true if event is a valid event from the current state
	inline public function isEvent(event:String):Bool {
		if (transitions.exists(event + splitter + currentState)) {
			return true;
		}
		return false;
	}

	// Add a transition connecting an event (i.e., an arc or transition)
	// between a pair of src and dst states.
	inline public function rule(event:String, src:T, dst:T) {
		transitions.set(event + splitter + src, dst);
	}
}
