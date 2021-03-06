module voak

import net.http
import net.http.mime
import crypto.sha1
import time
import os

// default response for a given status code
fn default_res(status http.Status) http.Response {
	return http.new_response(
		status: status
		body: '$status.int() - $status.str()' // eg: "404 - Not Found"
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
	res.body = os.read_file(file_path) or {
		eprintln('Failed to read a file: $err.msg()')
		return default_res(.internal_server_error)
	}
	// MIME type
	res.header.set(.content_type, mime.get_content_type(mime.get_mime_type(os.file_ext(file_path)[1..])))
	// ETag
	res.header.set(.etag, sha1.hexhash(res.body))
	// Last-Modified
	last_mod_date := time.unix(os.file_last_mod_unix(file_path)).custom_format('ddd, DD MMM YYYY HH:mm:ss')
	res.header.set(.last_modified, '$last_mod_date GMT')

	return res
}
