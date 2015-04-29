#TwitNotify
## About this
The Twitter Notification tool.  
Written in D.  
Using my Twitter API wrapper [Twitter4D](https://github.com/alphaKAI/twitter4d)  
  
  
## Support
* Linux with libnotify
* OSX Yosemite with terminal-notifier
  
  
## How to use
1. Clone this repository  
`$ git clone https://github.com/alphaKAI/twitnotify.git`
2. Change current directory  
`$ cd twitnotify`
3. Exec build.d with rdmd  
`$ rdmd build.d`  
4. Configure your consumer & access tokens  
`$ (any editor) setting.json`  
5. Exec TwitNotify binary  
`$ dub` or `$ ./twitnotify`
  
  
## Single Account Mode
If you use twitnotify as singleAccount mode, you must configure your setting.json as bellow.
```json
//setting.json
{
  "consumerKey"       : "Your consumerKey",
  "consumerSecret"    : "Your consumerSecret",
  "accessToken"       : "Your accessToken",
  "accessTokenSecret" : "Your accessTokenSecret"
}
```
  
  
## MultiAccount Support
You can use twitnotify for your some accounts.  
If you use twitnotify as multiaccount mode, you must configure your setting.json as bellow.  
```json
//setting.json
{
  "accounts":{
    "Your Account 1" : {
      "consumerKey"       : "Your consumerKey",
      "consumerSecret"    : "Your consumerSecret",
      "accessToken"       : "accessToken for Account 1",
      "accessTokenSecret" : "accessTokenSecret for Account 1"
    },
    "Your Account 2" : {
      "consumerKey"       : "Your consumerKey",
      "consumerSecret"    : "Your consumerSecret",
      "accessToken"       : "accessToken for Account 2",
      "accessTokenSecret" : "accessTokenSecret for Account 2"
    }
  }
}
```
  
  
## Requirements
* dmd(v2.067)
* rdmd
* dub
  
  
#### If you want to use on Linux  
* [libnotify](http://ftp.gnome.org/pub/GNOME/sources/libnotify/0.7/)
  
  
#### If you want to use on OSX
* [terminal-notifier](https://github.com/alloy/terminal-notifier)
  
  
## Disclaimer
unstable  
  
  
## LICENSE
The MIT License  
Copyright (C) 2014 - 2015 alphaKAI http://alpha-kai-net.info  
  
  
## Author
alphaKAI  
Twitter:[@alpha_kai_NET](https://twitter.com/alpha_kai_net)  
