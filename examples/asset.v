import hunam6.voak

fn main() {
	mut app := voak.App{}

	app.use(fn (mut ctx voak.Ctx) {
		ctx.send('/assets', '/my/files', index: 'index.html')
	})

	app.listen(port: 8080)?
}
