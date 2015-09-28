
var express = require('express');
var bodyParser = require('body-parser');
var http = require('http');

var app = express();

app.get('/Login', function (req, res) {

  res.status(406);
  res.end();

});

app.post('/Login', bodyParser.urlencoded({extended: false}), function (req, res) {

  // must provide the following params
  if (!req.body.username || !req.body.password || !req.body.key) {
    res.status(400);
    return res.json({
      msg: 'must provide correct params'
    });
  }

  // hard code some edge cases
  if (req.body.password == 'badpassword') {
    res.status(400);
    return res.json({
      msg: 'password is incorrect'
    });
  }

  // not a premium member
  if (req.body.username == 'freeloader') {
    res.status(200);
    return res.json({
      username: 'freeloader',
      uid: 1,
      status: 'Success',
      membership: 'Regular',
      favteam: 'Toronto Maple Leafs',
      token: '1234'
    });
  }

  // assume credentials are okay for mock
  res.status(200);
  res.json({
    username: req.body.username,
    uid: 0,
    status: 'Success',
    membership: 'Premium',
    favteam: 'Toronto Maple Leafs',
    token: '1234'
  });

});

app.get('/GetLive', function (req, res) {

  if (req.query.date) {
    // date provided
  }

  if (!req.query.token) {
    res.status(400);
    return res.json({
      msg: 'token not provided'
    });
  }

  if (req.query.token === 'badtoken') {
    res.status(400);
    return res.json({
      msg: 'token is not valid'
    });
  }

  res.json({
    status: 'Success',
    schedule: [
      {
        id: 1234,
        event: 'NHL',
        homeTeam: 'Toronto Maple Leafs',
        homeScore: 0,
        awayTeam: 'San Jose Sharks',
        awayScore: 5,
        startTime: new Date(), // ?
        period: 1,
        isHd: 1,
        isMd: 1,
        isiStream: 1,
        feedType: 'Home Feed'
      }
    ]
  });

});

app.get('/GetLiveStream', function (req, res) {

  if (!req.query.token) {
    res.status(400);
    return res.json({
      msg: 'token not provided'
    });
  }

  if (!req.query.id) {
    res.status(400);
    return res.json({
      msg: 'must provide a stream id'
    });
  }

  // handle passing location
  if (req.query.location) {

  }

  res.json({
    status: 'Success',
    id: 1234,
    event: 'NHL',
    homeTeam: 'Toronto Maple Leafs',
    homeScore: 0,
    awayTeam: 'San Jose Sharks',
    awayScore: 5,
    startTime: new Date(), // ?
    period: 1,
    isHd: 1,
    isMd: 1,
    isiStream: 1,
    feedType: 'Home Feed',
    logos:[
      {
        homeSmall: null,
        homeLarge: null,
        awaySmall: null,
        awayLarge: null
      }
    ],
    HDstreams: [
      {
        type: 'iStream',
        src: 'http://qthttp.apple.com.edgesuite.net/1010qwoeiuryfg/sl.m3u8',
        location: 'somewhere!'
      }
    ]
  });

});

var server = http.createServer(app);
server.listen(31337);

