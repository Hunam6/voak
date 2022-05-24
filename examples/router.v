import voak

fn main() {
	mut app := voak.App{}
	mut router := voak.Router{}

	router.get('/', fn (mut ctx voak.Ctx) {
		ctx.res.text = '$ctx.params.str()\n/'
	})
	router.get('/public', fn (mut ctx voak.Ctx) {
		ctx.res.text = '$ctx.params.str()\n/public'
	})
	router.get('/public/*abc', fn (mut ctx voak.Ctx) {
		ctx.res.text = '$ctx.params.str()\n/public/*path'
	})
	router.get('/path/:name', fn (mut ctx voak.Ctx) {
		ctx.res.text = '$ctx.params.str()\n/path/:name'
	})
	router.get('/complex/:name/*path*', fn (mut ctx voak.Ctx) {
		ctx.res.text = '$ctx.params.str()\n/complex/:name/*path*'
	})

	app.use(router.get_routes)
	app.listen(port: 8080)?
}
