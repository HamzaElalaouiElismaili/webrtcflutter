const express = require('express');
const app = express();
const configation = require("./api/config/app.config");
const bodyParser = require('body-parser');
const http = require('http');
const server = http.createServer(app);
const mongoose = require('mongoose');
const MeetingServer = require("./api/servers/meeting-server");
const socketIO = require('socket.io');
const io = socketIO(server,
    {
        reconnectionDelay: 1000,
        reconnection: true,
        reconnectionAttemps: 10,
        transports: ['websocket'],
        agent: false,
        upgrade: false,
        rejectUnauthorized: false
    });



mongoose.Promise = global.Promise;

mongoose.connect(configation.MONGO_DB_CONFIG.DB, configation.option).then(() => {
    console.log("Database Connected");
}).catch((error) => {
    console.log(error);
    console.log("DataBase not Connected ");
});


app.use(bodyParser.urlencoded({ extended: false }));
app.use(express.json());
app.use(bodyParser.json());








io.on("connection", socket => {
    const meetingId = socket.handshake.query.id;
    console.log(meetingId);
    MeetingServer.listenMessage(meetingId, socket, io);
})


app.use("/api/meeting", require('./api/routes/webrtcRoute'));

server.listen(5000);

// Server WebRTC initialize
//initMeetingServer(server);




// Server initialize
app.listen(configation.port, () => {
    console.log(' RESTful API server started on: ' + configation.port);
});

module.exports = app;
