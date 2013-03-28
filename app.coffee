request = require('request')
spawn = require('child_process').spawn
express = require('express')

app = express()
server = app.listen process.env.PORT || 5000

app.configure ->
	app.set 'views', __dirname + '/views'  
	app.use app.router
	app.use express.static(__dirname + '/public')

app.get '/', (req, res) ->
	res.render 'index.ejs'

app.get '/:url', (req, res) ->	
	identify = spawn('identify', ['-verbose', '-'])
	request.get(req.params.url).pipe(identify.stdin)

	identify.stdout.on 'data', (data) ->
		res.json data.toString().split("\n").map (line) ->
			line.trim()

	identify.stdout.on 'error', (data) ->		
		res.send 500, data.toString()