import voak

fn main() {
	mut app := voak.App{}

	app.use(fn (mut ctx voak.Ctx) {
		ctx.res.text = 'Hello Voak'
	})

	app.listen(port: 8080)?
}
