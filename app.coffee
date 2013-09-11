#!/usr/bin/env coffee

connect  = require('connect')
http     = require('http')
socketio = require('socket.io')
fs       = require('fs')
chokidar = require("chokidar")
path     = require("path")
spawn    = require("child_process").spawn

cwd = process.cwd()

try
  config   = require(path.join(cwd, ".live.json"))
catch e
  console.error "please create a .live.json in your project path."
  console.error e
  process.exit(0)


livejs = (file) ->
  (req, res, next) ->
    if req.originalUrl == '/live.js'
      res.writeHead(200, {"Content-type": 'application/javascript'})
      rs = fs.createReadStream(path.join(__dirname, "live.js"))
      rs.pipe(res)
    else  
      next()

app = connect()
  .use(connect.favicon())
  # .use(connect.logger('dev'))
  .use(connect.static(cwd))
  .use(connect.directory(cwd))
  .use(connect.cookieParser())
  .use(connect.session({
    secret: 'my secret here'
    }))
  .use(livejs('live.js'))
  .use (req, res)->
    res.end('Hello from Connect!\n')

server = http.createServer(app)
io = socketio.listen(server)
server.listen(3002)

watcher = chokidar.watch(cwd,  
  ignored: /^\./
  persistent: true
)

g_socket = null


system = (cmd, args) ->
  ls = spawn(cmd, args)
  ls.stdout.on "data", (data) ->
    console.log "stdout: " + data

  ls.stderr.on "data", (data) ->
    console.log "stderr: " + data

  ls.on "close", (code) ->
    console.log cmd, args

compile_condition = config.compile_condition #[ {from: "coffee\/.+\.coffee$", to: "js/"},
            # {from: ".+\.scss$", to: "css/"} ]
reload_condition  = config.reload_condition #[".css", ".js", ".html"]

watcher.on("change", (changed_path,stats) ->
    console.log "changed", changed_path
    i = 0
 
    # 触发编译
    while i < compile_condition.length
      regexp = new RegExp(compile_condition[i].from)
      if regexp.exec(changed_path)
        if path.extname(changed_path) is ".coffee"
          system "coffee", [ "-c", "-o", compile_condition[i].to, changed_path ]
        if path.extname(changed_path) is ".scss"
          system "scss", [ changed_path, compile_condition[i].to + path.basename(changed_path, ".scss") + ".css" ]  
      i++

    if path.extname(changed_path) in reload_condition
      if g_socket
        g_socket.broadcast.emit "change", changed_path
        g_socket.emit "change", changed_path
  ).on "error", (error)->
    console.error "Error happended",error


io.set('log level', 1)

master = io.of '/livereload'

master.on 'connection', (socket)->
  console.log 'connection'
  g_socket = socket
  
