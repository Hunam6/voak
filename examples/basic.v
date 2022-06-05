import hunam6.voak

fn main() {
	mut app := voak.App{}

	app.use(fn (mut ctx voak.Ctx) {
		ctx.res.body = 'Hello Voak'
	})

	app.listen(port: 8080)?
}
