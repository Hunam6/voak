import hunam6.voak

fn main() {
	mut app := voak.App{}
	mut router := voak.Router{}

	router.get('/', fn (mut ctx voak.Ctx) {
		ctx.res.body = 'home'
	})
	router.get('/complex/:name/*path*', fn (mut ctx voak.Ctx) {
		// test with `http://localhost:8080/complex/abc/apathfs?q=minecraft&sure=yes&name=john`
		params := ctx.get_query()
		ctx.res.body = params.str()
	})

	app.use(router.get_routes)
	app.listen(port: 8080)?
}
