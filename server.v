module voak

import net
import net.http
import time
import io

[heap]
pub struct App {
pub mut:
	ctx         Ctx
	middlewares []HandlerFn
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

type HandlerFn = fn (mut ctx Ctx)

// listen and serve
pub fn (mut app App) listen(cfg Config) ? {
	mut listener := net.listen_tcp(.ip6, '$cfg.host:$cfg.port') or {
		return error('Failed to listen to port $cfg.port')
	}
	if !cfg.silent {
		// TODO: detect HTTPS
		println('Voak is listening on http://$cfg.host:$cfg.port')
	}

	for {
		mut conn := listener.accept() or {
			eprintln('Failed to accept connection: $err.msg()')
			continue
		}
		handle_conn(mut app, mut conn)?
	}
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
