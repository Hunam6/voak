<div align="center">
  <h1>Voak</h1>
  <b>Web framework *aiming* at being the best for V</b>
</div>

## Installation

⚠️ Voak make use of the `net.http.mime` module which isn't currently merged to V master. Consequently you must temporally checkout your V installation to https://github.com/Hunam6/v/tree/mime using:
```
cd <v_dir>
git remote add mime https://github.com/hunam6/v
git checkout mime
```

```
v install Hunam6.Voak
```

## Usage

For now refer to the `/examples` directory.

## About

Voak's design (and name) is strongly inspired by [Oak](https://github.com/oakserver/oak), the most popular web framework for [Deno](https://github.com/denoland/deno). [Oak](https://github.com/oakserver/oak) is itself inspired by [Koa](https://github.com/koajs/koa)/[Koa Router](https://github.com/koajs/router), a popular web framework for [Node](https://github.com/nodejs/node). [Koa](https://github.com/koajs/koa)/[Koa Router](https://github.com/koajs/router) are themselves made by the team that made [Express](https://github.com/expressjs/express), the most popular web framework for [Node](https://github.com/nodejs/node).

Because of this strong web framework design experience I decided to strongly imitate Oak's API.

For the code itself, `server.v` logic was inspired by [Vweb](https://github.com/vlang/v/tree/master/vlib/vweb) and [Vex](https://github.com/nedpals/vex), big thanks.
