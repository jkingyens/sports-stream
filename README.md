# sports-stream
Redefine viewing live sports on tvOS and iOS

# Running in development

If you want to develop on sports stream client locally, then you can spin up a mock server. to do this:

install node.js, then run:

    cd SportsStreamServer
    npm install
    npm start

You are now runnning a local server.
When you launch the client, connect with the local development server (type: `http://localhost:31337` for endpoint)

# Running in production

Get an API key from your sports streaming provider, then:

    cp SportsStreamClient/AppConfig.plist.template SportsStreamClient/AppConfig.plist

Now paste your API key into this config file. Build and deploy to your Apple TV device or simulator!
When you run the client this time, be sure to enter the production server endpoint you are connecting to.

# limitations

* limited to playing live streams only (no on demand)
* testing with the simulator and not on real apple tv hardware

# Community & Devleopment

We are on freenode IRC at #sports-stream
We we have a [trello board with user stories](https://trello.com/b/HhgNUqIS/user-stories)
