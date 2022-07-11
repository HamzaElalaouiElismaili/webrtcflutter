const express = require("express");
const route = express.Router();
var meetingController = require("../controllers/meeting.controller.js");

route.post("/start", meetingController.startMeeting);
route.get("/join", meetingController.checkMeetingExisits);
route.get("/get", meetingController.getAllMeetingUsers);

module.exports = route;