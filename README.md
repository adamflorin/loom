## Loom v0.5 alpha

**Loom** is a modular generative music platform for Ableton Live.

It is currently an alpha, pushing beta.

http://adamflorin.com/loom

### Requirements

For users:

* [Ableton Live 9](http://www.ableton.com/live-8)
* [Max for Live](http://www.ableton.com/maxforlive)

For developers:

* All of the above
* [MaxMSP 6.1](http://cycling74.com/products/max/)
* [Node.js](http://nodejs.org/)

### Developing

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

### Distributing

To create a Live Pack containing all devices and demo content:

- `cake build-distribution`
- Open **Loom.als**
- Create a **MIDI Effect Rack** in any MIDI track
- Point Browser to **Current Project**
- One at a time, drag all devices from **Modules** into rack
- One at a time, **Edit** then **Freeze** each device
- Delete rack
- Delete .als from **Current Project**
- Right click in Browser pane, select **Manage Project**
- **Packing** > **Create Pack**
- `git reset --hard HEAD`

### Installing Live Pack

When you open **Loom.alp**, you must decide where to install the Loom Project.
A good place would be next to the 
[User Library](https://www.ableton.com/en/articles/where-are-my-user-presets-saved/)
(as Live will not allow you to install _inside_ of it).

Then immediately **Add Folder...** in Live's Browser to point to Loom Project.

The Players are MIDI Effect Rack presets which use the devices in Modules.
Start with the Players to get a feel for how Loom operates, and then start
building your own with the Modules!

### Usage

Loom devices may be dropped into a MIDI track as with any other Live device.

However, Loom devices are all "modules" which bind together to form "players".

For this reason, Loom devices should always be dropped into MIDI Effect Racks.
Each rack becomes a Loom "player" when it contains one or more Loom devices.

A given track may contain multiple Loom players, each in their own racks.

Loom "player" racks should not contain any non-Loom devices.
