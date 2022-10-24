const MongoClient = require('mongodb').MongoClient;
const ObjectId = require('mongodb').ObjectID;

const url = "mongodb://172.26.11.22:27055/";

const client = new MongoClient(url);
const taskflows = client.db("sc-datastore").collection("taskflows");
const devices = client.db("sc-datastore").collection("devices");

/////////////////////////////////////////////////////////////////////////////////////
// Slices the prefix (project ID) for a taskflow

async function slicePrefix() {
  try {
    
	let query = { displayName: /^WEN-01/ }; // Regex for starting with
	let doc = await taskflows.findOne(query); // Tis method returns the matched document, not a cursor
    
	if(doc == null) console.log("ERROR: No result matches the query: ", query);
	
	while(doc !== null){
	
		let displayName = doc.displayName;
		let _id = doc._id.toString()
		console.log("id: ", _id);
		console.log("current displayName: ", displayName);
		displayName = displayName.slice(displayName.indexOf("-") + 1); // slices "WEN-"
		console.log("new displayName: ", displayName, '\n');
		
		await taskflows.updateOne( {_id: ObjectId(_id) }, { $set: { displayName: displayName, internalName: displayName } } );
		
		doc = await taskflows.findOne(query);	
	}
	
  } finally {
    await client.close();
  }
}

/////////////////////////////////////////////////////////////////////////////////////
// Replaces the hostname prefix (project ID) for all devices

async function replacePrefix() {
  try {
    
	let oldPrefix = "ANK";
	let newPrefix = "FVR";
	
	let regex = new RegExp("^" + oldPrefix); // "^" means "starting with"
	
	let query = { deviceName: regex };
	let doc = await devices.findOne(query); // This method returns the matched document, not a cursor
    
	if(doc == null) console.log("ERROR: No result matches the query: ", query);
	
	while(doc !== null){
	
		let deviceName = doc.deviceName;
		let _id = doc._id.toString()
		console.log("id: ", _id);
		console.log("current deviceName: ", deviceName);
		deviceName = deviceName.replace(oldPrefix, newPrefix);
		console.log("new deviceName: ", deviceName, '\n');
		
		await devices.updateOne( {_id: ObjectId(_id) }, { $set: { deviceName: deviceName } } );
		
		doc = await devices.findOne(query);
	}
	
  } finally {
    await client.close();
  }
}

/////////////////////////////////////////////////////////////////////////////////////
// Deletes all taskflows starting with...

async function deleteTaskflows() {
  try {
    
	let query = { displayName: /^Z0/ }; //Regex for starting with
	
	let obj = await taskflows.deleteMany(query);
	
	console.log(obj);
	
  } finally {
    await client.close();
  }
}

//Uncomment the function to execute

//slicePrefix().catch(console.dir);
replacePrefix().catch(console.dir);
//deleteTaskflows().catch(console.dir);

console.log("END");