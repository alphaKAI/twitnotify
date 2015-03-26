#TwitNotify
##About this
The Twitter Notification tool.  
Written in D.  
Using my Twitter API wrapper [Twitter4D](https://github.com/alphaKAI/twitter4d)  
  
  
##Support
* Linux with libnotify
* OSX Yosemite with terminal-notifier
  
  
##How to use
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
  
  
##Requirements
* dmd(v2.066)
* rdmd
  
####If you want to use on Linux  
* [libnotify](http://ftp.gnome.org/pub/GNOME/sources/libnotify/0.7/)
  
####If you want to use on OSX
* [terminal-notifier](https://github.com/alloy/terminal-notifier)
  
  
##Disclaimer
unstable  
  
  
##LICENSE
The MIT License  
Copyright (C) 2014 - 2015 alphaKAI http://alpha-kai-net.info  
  
  
##Author
alphaKAI  
Twitter:[@alpha_kai_NET](https://twitter.com/alpha_kai_net)  
