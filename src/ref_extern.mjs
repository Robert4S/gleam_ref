import { Ok, Error } from "../prelude.mjs"

export class RefCell {
	constructor(init) {
		this.state = init;
		this.killed = false;
	}
}

export function cell(val) {
	return new RefCell(val);
}

export function get(ref) {
	return ref.state;
}

export function try_get(ref) {
	if (!ref.killed) {
		return new Ok(ref.state);
	} else {
		return new Error("Is this ok");
	}
}

export function set(ref, fun) {
	ref.state = fun(ref.state);
	return get(ref);
}

export function dummy(_b, _a) { }

export function kill_ref(a) {
	a.killed = true;
}
