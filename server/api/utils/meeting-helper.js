const meetingServices = require("../services/meeting_service");
const { MeetingPayloadEnum } = require("./meeting-payload-enum");

async function joinMeeting(meetingId, socket, meetingServer, payload) {
    const { userId, name } = payload.data;
    meetingServices.isMeetingPresent(meetingId, async (error, results) => {
        if (error && !results) {
            sendMessage(socket,
                {
                    type: MeetingPayloadEnum.NOT_FOUND
                });
        }
        if (results) {
            addUser(socket, { meetingId, userId, name }).then((result) => {
                if (result) {
                    sendMessage(socket, { type: MeetingPayloadEnum.JOINED_MEETING, data: { userId } });
                    broadcastUsers(meetingId, socket, meetingServer,
                        {
                            type: MeetingPayloadEnum.USER_JOINED,
                            data:
                            {
                                userId,
                                name,
                                ...payload.data,
                            }
                        });
                }
            }, (error) => {
                console.log(error);
            });
        }
    });
}



function forwardConnectionRequest(meetingId, meetingServer, payload) {
    const { userId, otherUserId, name } = payload.data;
    var model =
    {
        meetingId: meetingId,
        userId: otherUserId
    };
    meetingServices.getMeetingUser(model, (error, results) => {
        if (results) {
            var sendPayload = JSON.stringify({
                type: MeetingPayloadEnum.CONNECTION_REQUEST,
                data:
                {
                    userId,
                    name,
                    ...payload.data,
                }
            });

            meetingServer.to(results.socketId).emit('message', sendPayload);
        }
    })
}

function forwardIceCandidate(meetingId, meetingServer, payload) {
    const { userId, otherUserId, candidate } = payload.data;
    var model =
    {
        meetingId: meetingId,
        userId: otherUserId
    };
    meetingServices.getMeetingUser(model, (error, results) => {
        if (results) {
            console.log("forwardIceCandidate");
            var sendPayload = JSON.stringify({
                type: MeetingPayloadEnum.ICECANDIDATE,
                data:
                {
                    userId,
                    candidate
                }
            });

            meetingServer.to(results.socketId).emit('message', sendPayload);
        }
    })
}

function forwardOfferSDP(meetingId, meetingServer, payload) {
    const { userId, otherUserId, sdp } = payload.data;
    var model =
    {
        meetingId: meetingId,
        userId: otherUserId
    };
    meetingServices.getMeetingUser(model, (error, results) => {
        if (results) {
            var sendPayload = JSON.stringify({
                type: MeetingPayloadEnum.OFFER_SDP,
                data:
                {
                    userId,
                    sdp
                }
            });

            meetingServer.to(results.socketId).emit('message', sendPayload);
        }
    })
}

function forwardAnswerSDP(meetingId, socket, meetingServer, payload) {
    const { userId, otherUserId, sdp } = payload.data;
    var model =
    {
        meetingId: meetingId,
        userId: otherUserId
    };
    meetingServices.getMeetingUser(model, (error, results) => {
        if (results) {
            var sendPayload = JSON.stringify({
                type: MeetingPayloadEnum.ANSWER_SDP,
                data:
                {
                    userId,
                    sdp
                }
            });

            meetingServer.to(results.socketId).emit('message', sendPayload);
        }
    })
}

function userLeft(meetingId, socket, meetingServer, payload) {
    const { userId } = payload.data;
    broadcastUsers(meetingId, socket, meetingServer,
        {
            type: MeetingPayloadEnum.USER_LEFT,
            data:
            {
                userId: userId,
            }
        });
}


//forwardEvent

function endMeeting(meetingId, socket, meetingServer, payload) {
    const { userId } = payload.data;
    broadcastUsers(meetingId, socket, meetingServer,
        {
            type: MeetingPayloadEnum.END_MEETING,
            data:
            {
                userId: userId,
            }
        });


    meetingServices.getAllMeetingUsers(meetingId, (error, results) => {
        for (let i = 0; i < results.length; i++) {
            const meetingUser = results[i];
            meetingServer.sockets.connected[meetingUser.socketId].disconnect();
        }
    });
}

function forwardEvent(meetingId, socket, meetingServer, payload) {
    const { userId } = payload.data;
    broadcastUsers(meetingId, socket, meetingServer,
        {
            type: payload.type,
            data:
            {
                userId: userId,
                ...payload.data,
            }
        });
}


function addUser(socket, { meetingId, userId, name }) {
    let promis = new Promise(function (resolve, reject) {
        meetingServices.getMeetingUser({ meetingId, userId }, (error, results) => {
            if (!results) {
                var model =
                {
                    socketId: socket.id,
                    meetingId: meetingId,
                    userId: userId,
                    joined: true,
                    name: name,
                    isAlive: true,
                };

                meetingServices.joinMeeting(model, (error, results) => {
                    if (results) {
                        resolve(true);
                    }
                    if (error) {
                        reject(error);
                    }
                });
            }
            else {
                meetingServices.updateMeetingUser({
                    userId: userId,
                    socketId: socket.id,
                }, (error, results) => {
                    if (results) {
                        resolve(true);
                    }

                    if (error) {
                        reject(error)
                    }
                });
            }

        });
    });

    return promis;
}

function sendMessage(socket, payload) {

    console.log(payload);
    socket.send(JSON.stringify(payload));
}

function broadcastUsers(meetingId, socket, meetingServer, payload) {

    socket.broadcast.emit("message", JSON.stringify(payload));
}

module.exports =
{
    joinMeeting,
    forwardConnectionRequest,
    forwardIceCandidate,
    forwardOfferSDP,
    forwardAnswerSDP,
    userLeft,
    endMeeting,
    forwardEvent
}