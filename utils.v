module voak

import net.http
import net.http.mime
import os

// default response for a given status code
fn default_res(status http.Status) http.Response {
	return http.new_response(
		status: status
		text: '$status.int() - $status.str()' // eg: "404 - Not Found"
		header: http.new_header(
			key: .content_type
			value: 'text/plain'
		)
	)
}

fn file_res(file_path string) http.Response {
	mut res := http.Response{}

	res.text = os.read_file(file_path) or {
		eprintln('Failed to read a file: $err.msg()')
		return default_res(.internal_server_error)
	}
	if mime_type := mime.get_mime_type(os.file_ext(file_path)[1..]) {
		res.header.set(.content_type, mime.get_content_type(mime_type) or { '' }) // note: it'll never fallback to `or`
	}

	return res
}
