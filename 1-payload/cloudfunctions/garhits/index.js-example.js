/**
 * Copyright 2021 Gabriele Baldassarre
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

const projectId = 'CHANGEME';
const topicName = 'garhits';

// Imports the Google Cloud client library
const {PubSub} = require('@google-cloud/pubsub');

// Creates a client; cache this for further use
const pubSubClient = new PubSub();

exports.GA_Raw_Hits = (req, res) => {
  try {
    // allow access controll for the domain
   res.set('Access-Control-Allow-Origin', '*');
  if (req.method === 'OPTIONS') {
    // Send response to OPTIONS requests
    res.set('Access-Control-Allow-Methods', 'POST');
    res.set('Access-Control-Allow-Headers', 'Content-Type');
    res.set('Access-Control-Max-Age', '3600');
    res.status(204).send('');
  }
  
  //check if body is not null of response
  if(req.body!==null){
    //storing body as hit variable.
    var hit = req.body;
    
    //adding the hit timestamp so that we can get data and time of the hit in our data set
    //hit['hit_timestamp'] = new Date().getTime();
    
    try {
      hit.payload=decodeURIComponent(hit.payload)
      //send the raw hit recieved from GTM to PubSub topic
      const messageId = publishMessage(hit)
      console.log(`Message ${messageId} published.`);
    } catch (error) {
    console.error(`Received error while publishing: ${error.message}`);
    //process.exitCode = 1;
    }
    
    }
  }
  
    res.status(200).send('acknowledged');
  };

async function publishMessage(data) {
  const dataBuffer = Buffer.from(JSON.stringify(data));
  return await pubSubClient.topic(topicName).publish(dataBuffer);
  //process.exitCode = 1;
}
