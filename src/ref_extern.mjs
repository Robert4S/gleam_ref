export class RefCell {
	constructor(init) {
		this.state = init;
	}
}

export function cell(val) {
	return new RefCell(val);
}

export function get(ref) {
	return ref.state;
}

export function set(ref, fun) {
	ref.state = fun(ref.state);
}

export function dummy(_b, _a) { }
