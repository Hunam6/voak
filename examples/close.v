import hunam6.voak

fn main() {
	mut app := voak.App{}
	mut router := voak.Router{}

	router.get('/', fn (mut ctx voak.Ctx) {
		ctx.res.text = 'hello'
	})
	router.get('/close', fn (mut ctx voak.Ctx) {
		ctx.app.abort()
	})

	app.use(router.get_routes)
	app.listen(port: 8080)?
}
