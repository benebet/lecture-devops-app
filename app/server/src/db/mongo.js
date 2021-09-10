const mongoose = require('mongoose');
require('dotenv').config()
// utilize event emitter to indicate connection retries in logs
// DOCS: https://mongoosejs.com/docs/connections.html#connection-events
const CONNECTION_EVENTS = [
    'connecting', 'connected', 'disconnecting', 'disconnected',
    'close', 'reconnectFailed', 'reconnected', 'error'
]

if( process.env.NODE_ENV === 'production' ){
    CONNECTION_EVENTS.forEach(( eventName )=>{
        return mongoose.connection.on( eventName, ()=>{
            console.log( `Connection state changed to: ${ eventName }` );
        });
    });
}
console.log(`${ process.env.JWT_SECRET }`)
const mongoAtlasUri = "mongodb+srv://dbUser:DuHRSa9Xp8suxFsz@cluster0.scali.mongodb.net/myFirstDatabase?retryWrites=true&w=majority";
const mongooseInstance_ = mongoose.connect(mongoAtlasUri, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
    authSource:"admin",
    ssl: true
});

mongooseInstance_
    .then(()=>{
        process.env.NODE_ENV !== 'test' && console.log( `Connect established to database: ${mongoAtlasUri}` );
    })
    .catch(( err )=>{
        console.error( `Cannot connect to database: ${mongoAtlasUri}, err: ${err}` );
    });


process.on( 'exit', async ()=>{
    const dbClient = await mongooseInstance_;
    dbClient.disconnect();
});


module.exports = mongooseInstance_;
