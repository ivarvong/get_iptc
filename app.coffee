request = require('request')
spawn = require('child_process').spawn
express = require('express')

app = express()
server = app.listen process.env.PORT || 5000

app.configure ->
	app.set 'views', __dirname + '/views'  
	app.use app.router
	app.use express.static(__dirname + '/public')

get_iptc = (url, callback) ->
	identify = spawn('identify', ['-verbose', '-'])
	request.get(url).pipe(identify.stdin)

	identify.stdout.on 'data', (data) ->
		callback null, data.toString().split("\n").map (line) ->
			line.trim()

	identify.stdout.on 'error', (data) ->		
		callback data, null

app.get '/', (req, res) ->
	res.render 'index.ejs'

app.get '/:url', (req, res) ->	
	get_iptc req.params.url, (err, data) ->
		if err
			res.send 500, err
		else
			res.json data

app.get '/caption/:url', (req, res) ->
	get_iptc req.params.url, (err, data) ->
		if err
			res.send 500, err
		else		
			caption_array = data.filter (line) ->
				line.indexOf("Caption[2,120]") >= 0
			if caption_array.length > 0
				caption_parts = caption_array[0].split(":")
				caption_parts.shift()
				caption = caption_parts.join(":").trim()				
				res.send 200, caption
			else
				res.send 200, "(no caption)"