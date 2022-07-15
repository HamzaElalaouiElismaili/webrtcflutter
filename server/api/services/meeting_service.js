const meeting = require("../models/meeting.model");
const meetingUser = require("../models/meeting-user.model");

async function getAllMeetingUsers(meetId, callback) {
    meetingUser.find({ meetingId: meetId }).then((response) => {
        return callback(null, response);
    }).catch((error) => {
        return callback(error);
    });
}
async function startMeeting(params, callback) {
    const meetingSchema = new meeting(params);
    meetingSchema
        .save()
        .then((response) => {
            return callback(null, response);
        })
        .catch((error) => {
            return callback(error);
        });
}

async function joinMeeting(params, callback) {
    const meetingUserModel = new meetingUser(params);
    meetingUserModel
        .save()
        .then(async (response) => {
            console.log(params.meetingId);
            await meeting.findByIdAndUpdate(params.meetingId, { $addToSet: { "meetingUsers": meetingUserModel } });
            return callback(null, response);
        }).catch((error) => {
            return callback(error);
        });
}

async function isMeetingPresent(meetingId, callback) {
    meeting
        .findById(meetingId)
        .populate("meetingUsers")
        .then((response) => {
            if (!response) { callback("Invalide Meeting ID"); }
            else { callback(null, true); }
        }).catch(() => {
            return callback(error, false);
        });
}



async function checkMeetingExisits(meetingId, callback) {

    meeting.findById(meetingId)
        .populate("meetingUsers", "MeetingUser")
        .then((response) => {
            if (!response) callback("Invalide Meeting ID");
            else callback(null, response);
        }).catch(() => {
            return callback(null, false);
        });
}

async function getMeetingUser(params, callback) {
    const { meetingId, userId } = params;

    meetingUser.find({ meetingId, userId }).then((response) => {
        console.log("===========");
        console.log(response);
        return callback(null, response[0]);
    }).catch((error) => {
        return callback(error);
    });
}

async function updateMeetingUser(params, callback) {
    meetingUser.updateOne(
        { userId: params.userId },
        { $set: params },
        { new: true })
        .then((response) => {
            return callback(null, response);
        }).catch((error) => {
            return callback(error);
        })
}

async function getUserBySocketId(params, callback) {
    const { meetingId, socketId } = params;
    meetingUser
        .find({ meetingId, socketId })
        .limit(1)
        .then((response) => {
            return callback(null, response);
        }).catch((error) => {
            return callback(error);
        });
}

module.exports =
{
    startMeeting, joinMeeting, getAllMeetingUsers, isMeetingPresent, checkMeetingExisits, getUserBySocketId, updateMeetingUser, getMeetingUser
}