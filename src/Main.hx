import sys.io.File;
import js.html.FileSystem;
import Machine;

using MachineTools;
using EnumValue;
using haxe.EnumTools;
using haxe.EnumTools.EnumValueTools;
using Std;

enum abstract Events(String) from String to String {
	var go;
	var insert;
	var update;
	var goTolist;
	var eDelete;
	var eError;
	var eList;
	var eValidate;
}

enum abstract States(String) from String to String {
	var list;
	var insertData;
	var insertDataRetry;
	var validateInsert;
	var create;
	var createError;
	var created;
	var updateData;
	var validateUpdate;
	var update;
	var updateError;
	var updated;
	var delete;
	var deleted;
}

enum EventsTest {
	E1(params:{a:Int});
	E2(params:{a:Int});
	E3(params:{a:Int});
}

class Main {
	static function main() {
		var machine =  new Machine("init");

		machine.rule("E1".string(), "init", "e1");
		machine.send(E1({
			a: 1
		}).getName());

		trace(machine.currentState);
	}

	static function _main() {
		trace("Hello, world!");

		var machine:AStateMachine<Events, States> = new Machine(list);

		machine.rule({
			event: insert,
			src: list,
			dst: insertData
		})

			.rule({
				event: insert,
				src: insertData,
				dst: validateInsert
			})

			.rule({
				event: insert,
				src: validateInsert,
				dst: create
			})

			.rule({
				event: eValidate,
				src: validateInsert,
				dst: insertData
			})

			.rule({
				event: eError,
				src: create,
				dst: createError
			})

			.rule({
				event: insert,
				src: createError,
				dst: insertData
			})

			.rule({
				event: eList,
				src: insertData,
				dst: list
			})

			.rule({
				event: insert,
				src: create,
				dst: created
			})

			.rule({
				event: goTolist,
				src: created,
				dst: list
			})

			.rule({
				event: update,
				src: created,
				dst: updateData
			})

			.rule({
				event: update,
				src: updateData,
				dst: validateUpdate
			})

			.rule({
				event: update,
				src: validateUpdate,
				dst: update
			})

			.rule({
				event: update,
				src: update,
				dst: updated
			})

			.rule({
				event: eError,
				src: update,
				dst: updateError
			})

			.rule({
				event: update,
				src: updateError,
				dst: updateData
			})

			.rule({
				event: eValidate,
				src: validateUpdate,
				dst: updateData
			})

			.rule({
				event: eList,
				src: updateData,
				dst: list
			})

			.rule({
				event: eDelete,
				src: updateData,
				dst: delete
			})

			.rule({
				event: goTolist,
				src: updated,
				dst: list
			})

			.rule({
				event: update,
				src: updated,
				dst: updateData
			})

			.rule({
				event: update,
				src: list,
				dst: updateData
			})

			.rule({
				event: eDelete,
				src: list,
				dst: delete
			})

			.rule({
				event: eDelete,
				src: delete,
				dst: deleted
			})

			.rule({
				event: goTolist,
				src: deleted,
				dst: list
			});

		machine.on_enter_any(() -> {
			trace(machine.currentState);
			File.saveContent('myfile-${machine.currentState}.dot', machine.export());
		});

		machine.send(insert);
		machine.send(insert);
		machine.send(insert);
		machine.send(insert);
		machine.send(insert);
		machine.send(insert);
		machine.send(insert);
		machine.send(insert);
		machine.send(insert);
		machine.send(insert);

		machine.send(update);
		machine.send(update);
		machine.send(update);
		machine.send(update);
		machine.send(update);
	}
}
