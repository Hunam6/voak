module voak

import net.http
import net.urllib

enum PathCond {
	ignore
	same
	contains
	starts
	ends
}

type ParsedRoute = map[PathCond]string
type Params = map[string][]string

[heap]
pub struct Router {
mut:
	routes map[string]Route
}

pub struct Route {
mut:
	parsed   ParsedRoute
	params   Params
	methods  []http.Method
	handlers map[http.Method]HandlerFn
}

// register the router middleware
pub fn (mut r Router) get_routes(mut ctx Ctx) {
	url := urllib.parse(ctx.req.url) or {
		ctx.res = default_res(.internal_server_error)
		eprintln('Failed to parse URL: $err.msg()')
		return
	}

	if route := r.get_route(url.path) {
		if ctx.req.method in route.methods || route.methods.len == 0 {
			ctx.params = route.params
			route.handlers[ctx.req.method](mut ctx)
		} else {
			ctx.res = default_res(.method_not_allowed)
		}
	}
}

// get the route for the given path
fn (r Router) get_route(path string) ?Route {
	routes: for _, route in r.routes {
		parts := path.split('/')[1..]
		mut idx := 0
		mut last_cond := PathCond.ignore
		mut params := route.params

		for cond, val in route.parsed {
			part := parts[idx]
			last_cond = cond

			if cond == .ignore || (cond == .same && part != val)
				|| (cond == .starts && !part.starts_with(val))
				|| (cond == .ends && !part.ends_with(val))
				|| (cond == .contains && !part.contains(val)) {
				continue routes // skip the route as soon as it doesn't match
			} else if cond in [.ignore, .starts, .ends, .contains] {
				params[val] = [part]
			}

			idx++
		}

		if idx == parts.len || last_cond in [.starts, .contains] {
			return route
		}
	}
	return none
}

// register a new route
fn (mut r Router) add_route(method http.Method, path string, cb HandlerFn) {
	parsed_path, params := parse_path(path)
	if path in r.routes {
		r.routes[path].methods << method
		r.routes[path].handlers[method] = cb
	} else {
		r.routes[path] = Route{
			parsed: parsed_path
			methods: [method]
			handlers: {
				method: cb
			}
			params: params
		}
	}
}

// register a new route with multiple methods
pub fn (mut r Router) all(path string, cb HandlerFn) {
	parsed_path, params := parse_path(path)
	r.routes[path] = Route{
		parsed: parsed_path
		methods: [] // use an empty array to indicate all methods
		handlers: {
			.get: cb,
		}
		params: params
	}
}

// register a new route listening for the GET method
pub fn (mut r Router) get(path string, cb HandlerFn) {
	r.add_route(.get, path, cb)
}

// register a new route listening for the POST method
pub fn (mut r Router) post(path string, cb HandlerFn) {
	r.add_route(.post, path, cb)
}

// register a new route listening for the PUT method
pub fn (mut r Router) put(path string, cb HandlerFn) {
	r.add_route(.put, path, cb)
}

// register a new route listening for the HEAD method
pub fn (mut r Router) head(path string, cb HandlerFn) {
	r.add_route(.head, path, cb)
}

// register a new route listening for the DELETE method
pub fn (mut r Router) delete(path string, cb HandlerFn) {
	r.add_route(.delete, path, cb)
}

// register a new route listening for the OPTIONS method
pub fn (mut r Router) options(path string, cb HandlerFn) {
	r.add_route(.options, path, cb)
}

// register a new route listening for the TRACE method
pub fn (mut r Router) trace(path string, cb HandlerFn) {
	r.add_route(.trace, path, cb)
}

// register a new route listening for the CONNECT method
pub fn (mut r Router) connect(path string, cb HandlerFn) {
	r.add_route(.connect, path, cb)
}

// register a new route listening for the PATH method
pub fn (mut r Router) patch(path string, cb HandlerFn) {
	r.add_route(.patch, path, cb)
}

// parse a path into a parsed route and params
fn parse_path(path string) (ParsedRoute, Params) {
	mut parsed_route := ParsedRoute(map[PathCond]string{})
	mut params := Params(map[string][]string{})

	for part in path.split('/')[1..] {
		if part.len < 1 {
			parsed_route[.same] = ''
		} else if part[0] == `:` {
			name := part[1..]
			parsed_route[.ignore] = name
			params[name] = []string{}
		} else if part[0] == `*` && part[part.len - 1] == `*` {
			name := part#[1..-1]
			parsed_route[.contains] = name
			params[name] = []string{}
		} else if part[0] == `*` {
			name := part[1..]
			parsed_route[.ends] = name
			params[name] = []string{}
		} else if part[part.len - 1] == `*` {
			name := part#[..-1]
			parsed_route[.starts] = name
			params[name] = []string{}
		} else {
			parsed_route[.same] = part
		}
	}

	return parsed_route, params
}
