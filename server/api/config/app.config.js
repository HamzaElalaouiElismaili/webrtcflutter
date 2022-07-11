const MONGO_DB_CONFIG =
{
    DB: "mongodb://localhost:27017/newdb"
};

const option = {
    maxPoolSize: 50,
    wtimeoutMS: 2500,
    useNewUrlParser: true
};

const port = process.env.PORT || 6000;

module.exports =
{
    MONGO_DB_CONFIG,

    option,
    port
};
