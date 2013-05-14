# Loom v0.5 alpha

**Loom** is a modular generative music platform for Ableton Live.

It is currently an alpha, pushing beta.

http://adamflorin.com/loom

## Requirements

For users:

* [Ableton Live 9](http://www.ableton.com/live-8)
* [Max for Live](http://www.ableton.com/maxforlive)

For developers:

* All of the above
* [MaxMSP 6.1](http://cycling74.com/products/max/)
* [Node.js](http://nodejs.org/)

## Developing

Once you've downloaded Node.js, you can install all dependencies by running
`npm install` in the Loom directory.

To build the JS from CoffeeScript, run `cake build` in the root directory (or
`cake build-ui` for [jsui] source). Or you can simply hit cmd-B if you use
[Sublime Text 2](http://www.sublimetext.com/2).

In Max, add the Loom directory to your Max search path using
`Options > File Preferences...` and restart Max.

You should then be able to use the *.amxd devices in Live.

The default (sparing) development logs are written to `log/loom.log`. The Max
[`setmirrortoconsole`](http://cycling74.com/docs/max6/dynamic/c74_docs.html#messages_to_max)
flag is set, so you may check for Max logs in your OS-appropriate location
(Console.app on Mac OS).

## Usage

Loom devices may be dropped into a MIDI track as with any other Live device.

However, Loom devices are all "modules" which bind together to form "players".

For this reason, Loom devices should always be dropped into MIDI Effect Racks.
Each rack becomes a Loom "player" when it contains one or more Loom devices.

A given track may contain multiple Loom players, each in their own racks.

Loom "player" racks should not contain any non-Loom devices.
