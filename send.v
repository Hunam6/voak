module voak

import os

[params]
pub struct SendOpt {
	index string // file served at `/`
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
