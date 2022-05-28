module voak

import net
import net.http
import net.urllib
import time
import io
import os

[heap]
pub struct App {
pub mut:
	ctx         Ctx
	middlewares []HandlerFn
mut:
	tcp_listener &net.TcpListener = 0
}

pub struct Ctx {
pub mut:
	app     &App = 0
	req     http.Request
	res     http.Response
	params  map[string][]string
	cookies voidptr // TODO: cookies support
	socket  voidptr // TODO: WebSockets support
}

[params]
pub struct Config {
	host   string = 'localhost'
	port   int    = 8080
	secure bool // TODO HTTPS
	silent bool
}

[params]
pub struct RedirectConfig {
	status http.Status = .found
}

[params]
pub struct SendOpt {
	index string // file served at `/`
}

type HandlerFn = fn (mut ctx Ctx)

// listen and serve
pub fn (mut app App) listen(cfg Config) ? {
	app.tcp_listener = net.listen_tcp(.ip6, '$cfg.host:$cfg.port') or {
		return error('Failed to listen to port $cfg.port')
	}
	if !cfg.silent {
		// TODO: detect HTTPS
		println('Voak is listening on http://$cfg.host:$cfg.port')
	}

	for {
		mut conn := app.tcp_listener.accept() or {
			// server closed
			break
		}
		handle_conn(mut app, mut conn)?
	}
}

// close the server
pub fn (mut app App) abort() {
	app.tcp_listener.close() or { eprintln('Failed to close the server') }
	eprintln('Voak is shutting down')
}

// handle a connection
fn handle_conn(mut app App, mut conn net.TcpConn) ? {
	conn.set_read_timeout(1 * time.second)
	defer {
		conn.close() or { eprintln('Failed to close connection: $err.msg()') }
	}
	mut reader := io.new_buffered_reader(reader: conn)

	app.ctx = Ctx{
		app: &app
		req: http.parse_request(mut reader) or {
			return error('Failed to parse request: $err.msg()')
		}
	}

	for middleware in app.middlewares {
		middleware(mut app.ctx)
	}

	// TODO: maybe replace with `res.done`
	if app.ctx.res == http.Response{} {
		app.ctx.res = default_res(.not_found)
	}

	conn.write(app.ctx.res.bytes()) or { return error('Failed to write response: $err.msg()') }
}

// add middleware(s)
pub fn (mut app App) use(middleware ...HandlerFn) {
	for m in middleware {
		app.middlewares << m
	}
}

// add middleware(s)
pub fn (mut ctx Ctx) redirect(path string, cfg RedirectConfig) {
	ctx.res.set_status(cfg.status)
	ctx.res.header.add(.location, path)
}

// serve static file(s)
pub fn (mut ctx Ctx) send(dir_path string, mount_path string, opt SendOpt) {
	if ctx.req.url.starts_with(mount_path) {
		req_path := ctx.req.url[mount_path.len..].trim_right('/')
		real_path := os.resource_abs_path(dir_path + req_path)
		if os.is_file(real_path) {
			ctx.res = file_res(real_path)
		} else if req_path.len == 0 && opt.index.len > 0 {
			index_real_path := os.resource_abs_path('$dir_path/$opt.index')
			if os.is_file(index_real_path) {
				ctx.res = file_res(index_real_path)
			}
		}
	}
}

// helper to get the queries
pub fn (ctx Ctx) get_query() map[string]string {
	mut out := map[string]string{}

	// params queries
	for key, val in ctx.params {
		out[key] = val[0]
	}

	// URL queries
	if url := urllib.parse(ctx.req.url) {
		if raw_query := urllib.parse_query(url.raw_query) {
			for data in raw_query.data {
				out[data.key] = data.value
			}
		}
	}

	return out
}
