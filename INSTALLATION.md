# Loom Installation

Loom has only been tested on Mac OS (10.6+).

Requirements:

* [Ableton Live 8.1+](http://www.ableton.com/live-8)
* [MaxMSP 5.1+](http://cycling74.com/products/max/)
* [Max for Live](http://www.ableton.com/maxforlive)
* [JRuby for Max](https://github.com/adamjmurray/jruby_for_max)
* Java (should be preloaded on Mac OS--?)

To install on Mac OS:

* Download the source from GitHub at the command line:

    `git clone git://github.com/adamflorin/loom.git`
    
* In Max, create a search path for the `loom` directory in *Options > File Preferences...*
* In Live, point a file browser to the `loom/m4l` directory.
* Quit & restart Max and Live.
* See the [README](/loom) for usage instructions!

NOTE: On Mac OS, Max and Ruby will both log to Console.app, so check there first to troubleshoot.
