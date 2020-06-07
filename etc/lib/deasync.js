/*********************************************************************
 * Copyright (c) 2020 Red Hat, Inc.
 *
 * This program and the accompanying materials are made
 * available under the terms of the Eclipse Public License 2.0
 * which is available at https://www.eclipse.org/legal/epl-2.0/
 *
 * SPDX-License-Identifier: EPL-2.0
 **********************************************************************/

 /**
  * This module has been rewritten to use process.binding('deasync')
  * to load the binding as it's there an internal module pre-compiled
  * in the nodejs library.
  */

/*
 * deasync
 * https://github.com/abbr/deasync
 *
 * Copyright 2014-present Abbr
 * Released under the MIT license
 */

const binding = internalBinding('deasync');

function deasync(fn) {
	return function () {
		var done = false
		var args = Array.prototype.slice.apply(arguments).concat(cb)
		var err
		var res

		fn.apply(this, args)
		module.exports.loopWhile(function () {
			return !done
		})
		if (err)
			throw err

		return res

		function cb(e, r) {
			err = e
			res = r
			done = true
		}
	}
}

module.exports = deasync

module.exports.sleep = deasync(function (timeout, done) {
	setTimeout(done, timeout)
})

module.exports.runLoopOnce = function () {
	process._tickCallback()
	binding.run()
}

module.exports.loopWhile = function (pred) {
	while (pred()) {
		process._tickCallback()
		if (pred()) binding.run()
	}
}