module voak

import net.http
import net.http.mime
import os
import crypto.sha1
import time

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

// craft the response of file located in the given file path
fn file_res(file_path string) http.Response {
	mut res := http.Response{}

	// body
	res.text = os.read_file(file_path) or {
		eprintln('Failed to read a file: $err.msg()')
		return default_res(.internal_server_error)
	}
	// MIME type
	if mime_type := mime.get_mime_type(os.file_ext(file_path)[1..]) {
		res.header.set(.content_type, mime.get_content_type(mime_type) or { '' }) // note: it'll never fallback to `or`
	}
	// ETag
	res.header.set(.etag, sha1.hexhash(res.text))
	// Last-Modified
	last_mod_date := time.unix(os.file_last_mod_unix(file_path)).custom_format('ddd, DD MMM YYYY HH:mm:ss')
	res.header.set(.last_modified, '$last_mod_date GMT')

	return res
}
