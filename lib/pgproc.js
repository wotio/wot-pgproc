pg = require('pg');

module.exports = function(database, schema, target, emitter) {
	if (!target) {
		target = global;
	}

	pg.connect(database, function(err, client, done) {
		if (!client)  {
			console.error('Failed to connect to database');
			process.exit(1);
		}

		client.query("create or replace function help() returns json as $$ declare _json json; begin select into _json array_to_json(array_agg(array_to_json(array_prepend(proname::text, proargnames::text[])))) as methods from pg_proc proc join pg_namespace namesp on proc.pronamespace = namesp.oid where namesp.nspname = '" + schema + "'; return _json; end $$ language plpgsql;", function(err, result) {
			if (err) {
				return console.error('Failed to create help method', err);
			}
		});

		client.query("select proc.proname::text from pg_proc proc join pg_namespace namesp on proc.pronamespace = namesp.oid where namesp.nspname = '" + schema + "'", function(err, result) {
			if (err) {
				return console.error('Failed to read methods from database ' + database);
			}

			for (var i = 0; i < result.rows.length; ++i) {
				(function(fun) {
					target[fun] = function() {
						var args = Array.prototype.slice.apply(arguments, [0]);
						var callback = args.pop();
						var query = "select " + fun + "(";
						var vars = [];

						for (var i = 0; i < args.length; ++i) {
							vars.push("$" + (i+1));
						}

						query += vars.join(',') + ")";

						client.query(query, args, function(err, result) {
							results = [];

							if (!err) {
								err = null;
								results = result.rows;
							} else {
								console.error(query, err);
							}

							// Older callbacks did not expect the error to be
							// passed back as an argument -- newer ones bubble
							// up the error.
							if (callback.length > 1) {
								results.unshift(err);
							}

							return callback.apply(target, results);
						});
					}
				})(result.rows[i].proname);
			}

			if (!emitter) {
				return;
			}

			if (typeof(emitter) == 'function') {
				emitter();
			} else if (typeof(emitter['emit']) == 'function') {
				emitter.emit('ready');
			}
		});
	});
}
