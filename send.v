module voak

import os

[params]
pub struct SendOpt {
	default   string
	immutable bool // TODO: support
}

// serve static file(s)
pub fn (mut ctx Ctx) send(dir_path string, mount_path string, opt SendOpt) {
	if ctx.req.url.starts_with(mount_path) {
		real_path := os.resource_abs_path(dir_path + ctx.req.url[mount_path.len..])
		if os.is_file(real_path) {
			ctx.res = file_res(real_path)
		} else if opt.default.len > 0 {
			default_real_path := os.resource_abs_path('$dir_path/$opt.default')
			if os.is_file(default_real_path) {
				ctx.res = file_res(default_real_path)
			}
		}
	}
}
