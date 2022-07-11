const mongoose = require("mongoose");
const { Schema } = mongoose;




const MeetingUserSchema = new Schema({
    socketId:
    {
        type: String,
    },
    meetingId:
    {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Meeting"
    },
    userId:
    {
        type: String,
        required: true
    },
    joined:
    {
        type: Boolean,
        required: true
    },
    name:
    {
        type: String,
        required: true
    },
    isAlive:
    {
        type: Boolean,
        required: true
    },
},
    { timessteps: true });
const MeetingUser = mongoose.model("MeetingUser", MeetingUserSchema);
module.exports = MeetingUser;




