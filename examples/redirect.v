import hunam6.voak

fn main() {
	mut app := voak.App{}
	mut router := voak.Router{}

	router.get('/', fn (mut ctx voak.Ctx) {
		ctx.res.body = 'hello'
	})
	router.get('/redirect', fn (mut ctx voak.Ctx) {
		ctx.redirect('https://github.com/hunam6/voak')
	})

	app.use(router.get_routes)
	app.listen(port: 8080)?
}
