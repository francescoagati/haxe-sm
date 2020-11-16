import sys.io.File;
import js.html.FileSystem;
import Machine;

using MachineTools;

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

class Main {
	static function main() {
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

		File.saveContent('myfile.dot', machine.export());
	}
}
