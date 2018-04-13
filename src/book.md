# Kha's First Game Jam

This guide is intended to give you a "real-world" introduction to problems and techniques found in game programming, as well as the Kha APIs and how to use them in games. A simple but finished 2D game is presented with its full source code at each stage of development, from the early drawing routines to the final polish.

Its intended audience is existing programmers who don't necessarily know game programming or the Haxe language, and experienced game programmers who would like to see a whole project workflow in action.

### Table of Contents
- [About Kha and Haxe](#about-kha-and-haxe)
  - [What is Haxe?](#what-is-haxe)
  - [What is Kha?](#what-is-kha)
    - [I don't understand what that means?](#i-dont-understand-what-that-means)
    - [Where does Kha come from?](#where-does-kha-come-from)
  - [What is the benefit?](#what-is-the-benefit)
  - [What weaknesses does Haxe have?](#what-weaknesses-does-haxe-have)
  - [Why is Kha special?](#why-is-kha-special)
  - [Kha versus OpenFL and Unity3D](#kha-versus-openfl-and-unity3d)
    - [Is Kha related to OpenFL or NME? Will one give me better performance? Will I be locked in?](#is-kha-related-to-openfl-or-nme-will-one-give-me-better-performance-will-i-be-locked-in)
    - [Is Kha better than Unity3D?](#is-kha-better-than-unity3d)
- [Project Setup](#project-setup)
  - [Project Setup](#project-setup-1)
    - [How should I get started with Kha?](#how-should-i-get-started-with-kha)
  - [Build Options](#build-options)
  - [Updating Kha](#updating-kha)
  - [Kode Studio](#kode-studio)
  - [HaxeDevelop](#haxedevelop)
  - [IntelliJ](#intellij)
  - [Getting around in Haxe](#getting-around-in-haxe)
- [Kha API 1: Main class, System](#kha-api-1-main-class-system)
  - [Main.hx](#mainhx)
  - [Empty.hx](#emptyhx)
  - [System](#system)
  - [Scheduler](#scheduler)
  - [Framebuffer](#framebuffer)
- [Testing and Publishing the Project](#testing-and-publishing-the-project)
  - [Testing the Project](#testing-the-project)
  - [Publishing the Project](#publishing-the-project)
    - [HTML5](#html5)
    - [Desktop](#desktop)
    - [Flash](#flash)
    - [Build Details](#build-details)
- [Kha API 2: Display](#kha-api-2-display)
  - [Empty.hx](#emptyhx-1)
  - [What is "backbuffer.g1"?](#what-is-backbufferg1)
  - [Why is there a begin() and end()?](#why-is-there-a-begin-and-end)
- [API: Graphics2, Scheduler, and Moving Rectangles](#api-graphics2-scheduler-and-moving-rectangles)
  - [Timing in Kha](#timing-in-kha)
    - [Period vs. Duration](#period-vs-duration)
    - [realTime() and time()](#realtime-and-time)
    - [Why atomic timing is useful](#why-atomic-timing-is-useful)
  - [Drawing rectangles](#drawing-rectangles)
  - [Scaling](#scaling)
  - [The plane's data structure and algorithms](#the-planes-data-structure-and-algorithms)
    - [Empty.hx](#emptyhx-2)
- [Bombs Away!](#bombs-away)
  - [Empty.hx](#emptyhx-3)
- [Drawing a Canyon](#drawing-a-canyon)
  - [Tilemap.hx](#tilemaphx)
  - [Empty.hx](#emptyhx-4)
- [Bomb-Canyon Collision](#bomb-canyon-collision)
  - [Empty.hx](#emptyhx-5)
- [Rock Fall Behavior](#rock-fall-behavior)
  - [Empty.hx](#emptyhx-6)
- [API 5: Text and khafile.js](#api-5-text-and-khafilejs)
  - [khafile.js](#khafilejs)
  - [Code changes](#code-changes)
    - [Empty.hx](#emptyhx-7)
- [Completing the game loop](#completing-the-game-loop)
  - [Empty.hx](#emptyhx-8)
- [API 6: Sprite Assets](#api-6-sprite-assets)
  - [BoundsData.hx](#boundsdatahx)
  - [Drawing Plane, Blimp, and Bomb](#drawing-plane-blimp-and-bomb)
  - [Smoothing the Walls](#smoothing-the-walls)
  - [Add a Particle](#add-a-particle)
  - [Bitmap Font](#bitmap-font)
  - [Why use a single image for many sprites?](#why-use-a-single-image-for-many-sprites)
  - [What if I want to upgrade to Graphics4 later?](#what-if-i-want-to-upgrade-to-graphics4-later)
  - [Empty.hx](#emptyhx-9)
- [API 7: Sound Effects](#api-7-sound-effects)
  - [Sound](#sound)
  - [audio1.Audio](#audio1audio)
  - [audio1.AudioChannel](#audio1audiochannel)
  - [Empty.hx](#emptyhx-10)
- [Last Thoughts](#last-thoughts)
- [Troubleshooting](#troubleshooting)
  - [I got an error, but who should I ask about it?](#i-got-an-error-but-who-should-i-ask-about-it)
  - [Debugging Performance Issues](#debugging-performance-issues)
  - [Build and Asset Problems](#build-and-asset-problems)
  - [HTML5 Builds](#html5-builds)
- [Contributing to the Kha Guide](#contributing-to-the-kha-guide)
  - [Common Technical Writing Practices](#common-technical-writing-practices)
  - [Style](#style)

# About Kha and Haxe

## What is Haxe?

Haxe is an ECMAScript-like source code language. It compiles to many different source and binary targets, including JS, C++, Java, Python, Flash, PHP... It eases portability difficulties by providing a single source language, with low-level access to the idioms of each target platform.

## What is Kha?

Kha is a low-level framework that builds on the Haxe compiler technology. Like Haxe itself, it abstracts the details of different platforms to ease portability concerns. Kha builds on Haxe to offer a framework suitable for real-time multimedia applications, particularly games.

### I don't understand what that means?

Write code in Haxe. The Kha build process produces an appropriate build for the target platform.

Then work with the toolchain of the target platform to debug it.

### Where does Kha come from?

Kha is one of a series of portability frameworks Robert Konrad wrote. It is directly based on "Kje", a Java framework, and has been developed since 2012. The "ha" stands for Haxe, of course.

## What is the benefit?

Haxe is designed for high compatibility. It is a easy language to get started with if you are familiar with popular scripting languages like Javascript, Lua, Python, or Ruby. It has many features that those languages do not have, and a fast, powerful compiler that will catch many errors for you and perform optimizations that would be out of reach otherwise.

Haxe is also excellent at allowing you to defer final technology choices until later. The same codebase can compile to many different targets, and also many different APIs. If you discover, for example, that Kha does not work out, you have many options to migrate the code to a different API - either native APIs or another framework. You will not have to rewrite the entire codebase in another language.

Lastly, by working in Haxe you will learn techniques for writing reliable, highly portable code - not just in Haxe, but in all the environments Haxe targets. The Haxe ecosystem is designed around making sure all targets have *viable solutions*. This means that for any given problem you encounter, there is some way to access the native functionality of the target to resolve that problem, while still working with Haxe abstractions for the majority of the code. You gain the possibility of using the debugging tools of more than one target, which improves your chances of quickly resolving a difficult bug.

Many Haxe users claim higher overall productivity with Haxe than in other environments.

## What weaknesses does Haxe have?

Although Haxe is mostly familiar for a former Actionscript or Javascript programmer, some aspects may be new and challenging. The compiler's type inference engine will catch many of your minor mistakes quickly, but typing time is higher. Haxe style encourages full use of static types, and many of the tricks based on dynamic typing that are used in, for example, Ruby, are poor style in Haxe because they do not leverage the type system efficiently. There are plenty of new static-typed tricks to learn instead :)

You will also encounter more friction within the toolchain because it is not exactly designed around the native tools of the target environment. Debugging problems buried in the toolchain may require domain knowledge that "bridges the gap" from the framework into the target. Because crossplatform frameworks have multiple implementations of their APIs, behaviors may change slightly across targets, leading to "write once debug everywhere". Good frameworks like Kha will also get out of the way and ease the process of writing things in a cross-platform way.

Haxe expects a garbage-collected environment, and builds itself on a relatively high-level runtime. This limits its utility for the most demanding games that need low-level control over memory allocation behaviors. In the average case, garbage collection problems can be overcome by eliminating spurious allocations and reusing more data, through, for example, object pooling. Memory allocation only becomes a serious concern as your project becomes more likely to allocate memory. Simpler scenes and simulations will make garbage collections both smaller and less frequent, limiting any potential impact on framerates.

Now you may still be wondering, "how do I know how demanding my project will be?" and the answer is, for pretty much any game or media project on the planet: *as much or as little as you want.* The data sets are fixed. You can always find a way to dial down the level of detail presented. So the most legitimate answer is that you only want a lower level solution if you are explicitly aiming to push the boundaries of the machine and make it process as much as possible - for anything less than that, modern devices allow you to make tradeoffs, and nobody can tell you what that translates to in useful high-level terms like "scene complexity" or "quality of AI". Benchmarks are mostly informative to system bottlenecks, and those bottlenecks may not be relevant to your design after all features are added. To quote a friend of mine, working on a little C++ project a few years ago:

> *I am leaking megabytes every second and not even noticing.*

So to make useful benchmarks for yourself, always design towards some maximums, and make sure the framework can handle those maximums with some headroom to spare. Design limits build creative spaces - don't think of them as settling for less. If you can achieve an effect with less, that's usually better. That goes for limits that aren't based in technical constraints, too!

## Why is Kha special?

Kha aims for a new standard of crossplatform games technology, with a graphics and sound API that can successfully span many different environments and accommodate major variations in features exposed.

## Kha versus OpenFL and Unity3D

### Is Kha related to OpenFL or NME? Will one give me better performance? Will I be locked in?

OpenFL is another project that uses the Haxe technology to create a cross-platform framework. The goals of the projects are different:

-   OpenFL is best for programmers who wish to continue to work with the Flash APIs, and primarily in 2D. It aims to provide a Flash-like experience everywhere, but also provides certain low-level features that are not native to Flash.

-   NME is a variant on OpenFL that has at various times been the same project, sharing similar goals. It presently aims to be a purely "native platform" target, supporting more low-level access.

-   Kha is a purely low-level cross-platform framework, and supports 2D and 3D. It provides fewer and simpler APIs, but has strong provisions for graphics rendering, including fonts and shaders.

The featuresets of each of these frameworks overlap, but all are capable of decent to great performance, depending on what you do and how you do it. Because they use the same language, you will also enjoy a less costly migration if you discover you need to switch frameworks.

### Is Kha better than Unity3D?

Many core capabilities are already available in Kha, but Unity is much more fleshed out and tested as a game engine. The difference is in whether you are aiming to implement "engine bits" like collision detection and physics, or if you can use an off-the-shelf solution effectively. Unity provides the latter, more complete solution, and, assuming you're already familiar with it, is better for rapid prototyping of typical scenes. Kha is better at being the underpinning of a game engine. Game engines such as Khapunk have already been ported to work on Kha. UI toolkits like HaxeUI also support Kha as a display layer target.

If you want to mix Kha and Unity, or Haxe and Unity, that is also an option: Kha has a Unity3D export target, and there are several bindings to Unity APIs from Haxe, ensuring that your codebase can be migrated if necessary.

# Project Setup

## Project Setup

### How should I get started with Kha?

There are standalone way to work with Kha. This allows a project's whole environment to be maintained without accidentially losing important dependencies, and so it is less dependent on the "Haxe ecosystem".

So, your workflow after installation is:

1.  Run khamake to compile the assets and project metadata for a target platform(html5, windows, etc.)

2.  Test and debug using additional compilers and IDEs appropriate to your target(e.g. Visual Studio, Unity editor, browser).

Installation requires [git](https://git-scm.com/) and [node](https://nodejs.org/). Use this git line:

    git clone --recursive https://github.com/Kha-Samples/Empty.git

This will download lots of stuff, since it's including all of Kha. When it's done, the project root is in Empty:

    cd Empty

**To run khamake type:**

    node Kha/make

The remainder of this guide will alias this line as "khamake". You can add targets and options to it. You may need to update the submodules(see Updating Kha) before continuing.

Alternate method, using a script that runs khamake:

**From Windows cmd type:**

    cd build
    build

**From bash type:**

    cd build
    ./build

This script brings up a prompt for target and options like this, and then runs khamake:

    ___________________________________
    khamake builder
    type q to quit.
    ___________________________________
    Specify target:html5
    Specify options:

## Build Options

    khamake
        -> visual studio solution (uncompiled)
            
    khamake --compile
        -> visual studio solution (run compiler after)
            
    khamake --compile --visualstudio vs2013
        -> visual studio solution (run visual studio 2013 instead of other versions)
            
    khamake html5
        -> html/js
            
    khamake flash
        -> flash swf

    For more commands:
        khamake --help

The resulting project or binary will live somewhere in the "/build" directory and when run should give you a blank screen. For more on builds:

[Testing and Publishing the Project](#testing-and-publishing-the-project)

## Updating Kha

    git submodule foreach --recursive git pull origin master
    git commit -m "update Kha"

In a standalone project we recommend making a copy of dependencies within the project.

## Kode Studio

Kode Studio is a customized, cross-platform IDE for working with Kha projects. It's based on VS Code. Working with Kode is recommended as it is integrated with a special Kha runtime based on the Electron JS platform, simplifying development workflow.

1.  To use Kode Studio with your Kha project, launch code. From the File dropdown, select Open Folder, then select the root path of your Kha project. No additional project file is needed!

2.  F5 is your "test build" button. It will run a complete build, including assets, and launch the project in Electron.

## HaxeDevelop

HaxeDevelop is one of the most popular IDEs for Haxe on the Windows platform. Being based on FlashDevelop, it was extended to support Haxe many years ago. Kha can generate HaxeDevelop project files.

1.  To work with Kha and HaxeDevelop, visit the /build directory to notice a project file for your build target. Open this to get full IDE integration.

2.  F5 is your "test build" button. It will run Haxe and emit new code. If you want new targets or a complete build including assets, run khamake again.

## IntelliJ

IntelliJ contains a Haxe plugin, available from its internal plugin browser, and Kha generates project files for it. Make sure the plugin is installed. Then visit the /build directory and open the project file for your build target.

1.  IntelliJ will complain about the Git repository settings, but you can safely ignore this or replace the settings with your own if you wish to fix the Git integration.

2.  You must also set up the project's SDK. IntelliJ will pop up the "Project Structure" dialog and prompt you to add a correct SDK when you first try to build the project. You can add it by clicking the "New" button adjacent to "Module SDK". This will point to the appropriate Haxe compiler, set "<project>/Tools/haxe".

1.  Finally, in the "Project Structure" dialog, under the "Haxe" tab, make sure that the "Skip compilation" checkbox is unchecked.

2.  Ctrl+F9 is your "test build" button. It will run Haxe and emit new code. If you want new targets or a complete build including assets, run khamake again.

## Getting around in Haxe

Here is a quick example to familiarize yourself:

```haxe
$$include(projects/HaxeExample.hx)
```

Also visit [Try Haxe](https://try.haxe.org/) for some more basic examples.

# Kha API 1: Main class, System

The Empty project already has Kha configure some things about the display and update timing, so let's review. For laziness and simplicity reasons, we're going to stick with the "Empty" naming convention throughout this guide, although you may want to pick a cuter name for your project's title and main class.

## Main.hx

```haxe
$$include(projects/1-Empty/Main.hx)
```

## Empty.hx

```haxe
$$include(projects/1-Empty/Empty.hx)
```

Running this should still give you a blank screen. We have three Kha classes to look at:

## System

This class is the "global state" of your Kha app: It holds the render callback, it says how big the screen is and how fast it refreshes, etc. We use it here to initialize the screen, and then to set up the rendering callback. System also contains:

-   callbacks for various OS/windowing-level events, like being minimized or shutdown

-   a global "time" value (since startup, measured in seconds)

-   vsync control

-   systemID - what target you are on, e.g. "HTML5".

## Scheduler

This class governs all the interesting timing information in Kha. We'll discuss it in depth later. For now, just know that it lets you set up recurring tasks like updates to your gameplay, independently of the render callback. Although System has a "time", Scheduler has a "framerate-corrected" time, so consider using it first if the time is used for gameplay.

## Framebuffer

This is a class that represents the display we're drawing to from the rendering callback. This will get more attention shortly, as our next API chapter is about simple drawing.

# Testing and Publishing the Project

## Testing the Project

The preferred targets for Kha development are Flash and HTML5. Debugging functionality and test iteration times are best on these targets. For these targets you may use either your web browser or the standalone Flash Projector.

For a Windows build the most straightforward option is Visual Studio. Khamake will try to autodetect the version you are running and generate a VS solution file for you. Then open the solution in the IDE, select Debug or Release and do debugging and profiling from within VS.

## Publishing the Project

You are ready to show your game to somebody, but you need to get it running on their device. This section will depend on your target, but Kha has kept the process simple.

Robert summarizes:

> *For some targets (Windows, Linux,...) you put the executable in the windows/linux/... directory, for other targets (Android, iOS, OSX,...) the IDE does everything for you.*

> *No target has any additional dependencies.*

### HTML5

The result is stored in "build/html5".

1.  Upload the directory to a web host and point your users at the appropriate URL.

2.  The build is complete.

### Desktop

The result is stored in the appropriate platform target, e.g. "build/windows" for example.

1.  Copy the executable from "windows-build/Release" to "build/windows".

2.  Package "build/windows" as suits you and send the result to your users.

3.  The build is complete.

### Flash

The result is stored in "build/flash" as "kha.swf". Choose your distribution type:

-   *Multi-file distribution*: This is the default build mode. The entire folder, including "Assets", must be uploaded as Kha will load these assets at runtime.

-   *Single-file distribution*: Use the option *--embedflashassets* in khamake.

After deciding on multi-file or single file:

1.  Upload either kha.swf or the whole directory to your hosting.

2.  You must provide your own web page for Flash embedding.

### Build Details

The generated HaxeDevelop project or hxml file contains the flag "kha" which can be used in an #if block to detect whether the project was built with Kha.

# Kha API 2: Display

Now we will render a very simple "strobe the screen with different colors". **Caution: this may be seizure-inducing.** (lower the display size if you're worried)

## Empty.hx

```haxe
$$include(projects/2-Empty-g1/Empty.hx)
```

## What is "backbuffer.g1"?

Kha contains different numbered "levels" of its graphics API. Graphics1 is the simplest possible system: it can plot pixels only.

Here is a replacement of that block using Graphics2:

```haxe
var g = framebuffer.g2;
g.begin();
g.clear(nextcolor);
g.end();
```

Graphics2 adds more "standard" functionality, including clearing the screen, drawing shapes and blitting images. It's for general-case 2D applications, and its routines can be counted on to be faster than plotting individual pixels. We'll expand on Graphics2 in later chapters.

There is also a Graphics4, which exposes the full shading pipeline. In theory Graphics3 represents fixed-function GPU pipelines, but it does not exist at this time. We will not venture into Graphics4 in this guide, and focus instead on fleshing out a game in Graphics2.

## Why is there a begin() and end()?

Kha batches the graphics operations internally and processes the actual drawing commands when it reaches end(). This lets you code your own rendering logic more freely, while letting Kha optimize the commands to whatever works best in the target environment.

# API: Graphics2, Scheduler, and Moving Rectangles

We will make a clone of the 70's Atari game "Canyon Bomber". In this game, a plane flies over a canyon in side view and drops bombs, trying to clear away all the rocks on the board without missing. It's one of the earliest "one-button games" and presents a well-rounded exercise for Kha's toolset.

In this passage we'll work on moving a rectangle across the screen over time, introducing timing and simple animation. The rectangle will later become the "bomber plane" in our game.

## Timing in Kha

Kha contains a sophisticated timing and scheduling system, but also lets you dig into raw timing data.

    Scheduler.addTimeTask(game.simulate, 0, 1 / 60);

This uses the Scheduler API to call game.simulate 60 times a second(every ~16.6 ms), indefinitely.

### Period vs. Duration

Period is the total length of a scheduled task. Duration is the frequency at which the task is repeated.

For example, if you wish to call an event 30 times a second, but for only 2 seconds, you would add a task with a duration of 1/30 and a period of 2.

### realTime() and time()

To get the current time since start, use:

    Scheduler.time();

and

    Scheduler.realTime();

Scheduler will automatically apply smoothing, limiting, and atomization to timing data so that the average-case experience is as jitter and pause-free as possible.

-   Scheduler.time() is the time that has passed after these adjustments.

-   Scheduler.realTime() is the system global time, or "wall clock" time. Use this one for performance data, or if you want to do your own timing from scratch.

### Why atomic timing is useful

It is tempting to plug in a delta time into your physics equations, tweens, etc. and allow the time to float freely. Sometimes this is even a correct approach.

However, there are two reasons not to do this. One is that it makes physics simulations inconsistent - often wildly so. Jump heights will be unpredictable, people will go flying at strange velocities, etc. The other is that it hurts reproducability otherwise, for example if you are recording a demo for playback.

Therefore, the most flexible approach is to chop up delta times into regular "atoms" of time, and play through them one at a time. This is what Kha does inside its Scheduler API. It is even designed to support complex use-cases where timers get called in a certain order, or are paused or cancelled while active.

## Drawing rectangles

We use Graphics2.fillRect() to draw some rectangles. In doing so, we also make use of the "color" attribute on Graphics2. We already used some color to do our full-screen strobe, but here we can see more clearly what is going on.

Graphics2 uses a "finite state" model of rendering, where we describe a configuration for drawing, and then issue a command that updates the state of the framebuffer we are drawing to. So when we change color, that changes the color of the drawing commands we issue after that change.

## Scaling

Oh, how inconvenient! We aren't always going to get the resolution we request returned in System.windowWidth and System.windowHeight. After all, the system can't always give you what you ask for. When we get those values, what's returned is the current size of window 0. We might have more than one window, or the user might change the window size, e.g. because their phone went from portrait to landscape.

That also means that if we want to force a certain pixel resolution - and this is the type of game where that happens - we're going to have to think about scaling.

There are two ways we can approach this.

1.  The more "pixel-perfect" way would be to have a "*back buffer*". Instance an Image at our ideal resolution, draw the gameplay on that, then draw that, scaled, to the display buffer. That guarantees that everything stays on the same pixel grid, no matter what we do.

2.  But we'll go the other route of adding a *scaling transform* using a FastMatrix3 before our drawing calls. This will give us the correct proportions, and it avoids an additional trip through the GPU, so it may be somewhat faster, but it means that objects may look "wrong" if they are scaled, rotated, or placed on subpixel coordinates.

It's very easy to swap between these two methods if you prefer one or the other. Variations like only scaling to integer factors of the original, cropping the image, etc. are also possible.

## The plane's data structure and algorithms

I decided to make the plane a Haxe Typedef with an x and y position, x and y velocity, and a width and height. Although we don't have to define a width and height as a *variable* on the plane - it's never going to change during gameplay - it's convenient for us, so I splurged.

The screen space and the physics space in Canyon Bomber are 1:1, and the camera is locked in one position, so no coordinate conversions have to take place during rendering - I just enter the position and size directly. If I wanted to scroll the screen or zoom in and out, this part would become more complex.

Then I wrote a routine to move it across the screen each update, and make it wrap around as it runs off the edge. This routine will get more complex later(and so will the plane's data).

### Empty.hx

```haxe
$$include(projects/3-Empty-events/Empty.hx)
```

# Bombs Away!

Here we add the interaction where the player can drop a bomb by pressing a button, and get rid of the input debug stuff now that we have a "real" input response.

I am running all the input through the update loop as a way to finely control the process of synchronizing the game logic. If we had more substantial state changes on the keypress events, it would be harder to follow the flow of the logic, and we might make a mistake like trying to manipulate a game object when it's not available. The result is the "*straight-line*" style of coding: Instead of organizing code to maximize potential for indirection, we deliberately couple it in a top-to-bottom, heavily inlined fashion, and use simple organization and commenting to understand it.

Because our game design encompasses a final product specification, writing a large straight-line main loop is our most cost-efficient option for maintenance: many features are minor variations on other features, but need new programming, not new parameters. Parameterization will only increase the ways in which a code path can fail. But don't take my word for it — [John Carmack also agrees:](http://number-none.com/blow/john_carmack_on_inlined_code.html)

> *The real enemy addressed by inlining is unexpected dependency and mutation of state, which functional programming solves more directly and completely. However, if you are going to make a lot of state changes, having them all happen inline does have advantages; you should be made constantly aware of the full horror of what you are doing. When it gets to be too much to take, figure out how to factor blocks out into pure functions (and don't let them slide back into impurity!).*

## Empty.hx

```haxe
$$include(projects/4-BombsAway/Empty.hx)
```

# Drawing a Canyon

Here we add some simple tilemap rendering to present a canyon filled with rocks. I compile the generic tilemap manipulation stuff into a new file and class named Tilemap.hx for convenience. Most of the interesting parts will always remain custom to the game, and I put those in Empty.

We also add a level start, and some constants to specify the size of the level, and some procedural terrain. The bomb doesn't interact with the terrain yet, but we'll get there soon!

You may notice that I use a one-dimensional array to describe the tiles. This is a convention I adopted some years ago because it turned out to be simpler for any task that involved the whole map: I could iterate over one array, instead of an array of arrays.

It is also straightforward to convert between a single "tile index" integer and an (x, y) pair.

To go from the pair to the index:

```haxe
    y * MAP_W + x
```

To extract the x position:

```haxe
    idx % MAP_W
```

To extract the y position:

```haxe
    Std.int(idx / MAP_W)
```

The most challenging aspect of tilemaps is always with their boundaries. Either fallbacks to accommodate edges and out-of-bounds always have to be included, or the map has to have some kind of built-in padding in its data so that the out-of-bounds case is functionally impossible.

The canyon is generated with a procedural technique, converting a sequence of heights to a 2D tilemap. To give it the feeling of having a "dip" in the middle, I took samples of one half of a sine wave cycle. Then I added noise to each sample. Finally, I added a smoothing process so that the gaps were not too narrow, making an impossible configuration less likely. (A "real" game might strive to find a more rigorous way of doing this.)

## Tilemap.hx

```haxe
$$include(projects/5-BombsAway-tilemap/Tilemap.hx)
```

## Empty.hx

```haxe
$$include(projects/5-BombsAway-tilemap/Empty.hx)
```

# Bomb-Canyon Collision

Most action games use a collision simulation for the basic "feel" of the game - or to put it another way, "collision is gameplay". This also means that collision is customized to each game.

For Canyon Bomber, we have a simple case: we want the bombs to clear away rocks until they touch a wall or go offscreen.

To do this we sample each corner of the bomb each frame and translate that into a tile coordinate. Then we modify the tile if it's a rock, and tell the bomb whether or not it has died. As we proceed through the rest of the guide, we'll refine this collision behavior some more so that the bomb "feels" correct.

One of the common mathematics challenges that appears during game coding is conversion between coordinate systems. Any time you have a tile grid, you will encounter some reason to convert between the screen coordinates and the grid coordinates. Maybe you are picking a tile with mouse or touchscreen input, or you want to find the boundaries of a rectangle on the tile grid, or you are trying to collide an actor against terrain described through the tilemap(the case we have with the bomb).

I already built the conversions we need into Tilemap.hx, fortunately, so we will be using those. The most important part, since we're working on a one-dimensional array, is that the i() and p2i() methods automatically detect invalid coordinates and return a correspondingly invalid tile index.

## Empty.hx

```haxe
$$include(projects/6-BombsAway-collision/Empty.hx)
```

# Rock Fall Behavior

The other part of Canyon Bomber's collision is for the rocks to fall down after the bomb clears underlying areas.

To do this we scan upwards from the bottom of the tile grid. We don't have any cascading behavior where the rocks fall to the sides (e.g. *Boulder Dash*), they just fall and stack up in a vertical column. So all we have to do is trigger it on the update() and give it a delay timer so that the fall rate is believable. (I could use Scheduler for this, but prefer having a clear flow through the simulation.)

I added some speed to the plane so that we can see the effect more clearly.

## Empty.hx

```haxe
$$include(projects/7-BombsAway-rockfall/Empty.hx)
```

# API 5: Text and khafile.js

Let's render some text so that we can start displaying score and lives.

Now, if we wanted to do bitmap text like what was in the original game, we could start using Graphic2's sprite functionality to do so. But we are still in a prototyping mode and it'll be simpler to explore the Font API.

First of all, we need to include a font asset in the project. Kha fonts are standard TTF files. The framework does all the behind-the-scenes work of rendering the text, and provides basic size and positioning information.

Recall that khamake uses node.js. This extends into how we script builds; rather than use a "plain old data" configuration file, we write a little bit of Javascript in a file called "khafile.js". This file appears in the root of the project.

## khafile.js

```javascript
$$include(projects/khafile.js)
```

Empty project doesn't have "Assets" by default. The path expression takes either "*" (add all files in directory) or "**". (add all files in directory and subdirectories)

1.  Add the addAssets line.

2.  Make an "Assets" directory, and drop [arial.ttf](https://github.com/RblSb/khaguide/blob/master/projects/Assets/arial.ttf) into Assets.

3.  Run khamake again.

The Project API also lets you add compiler defines and external libraries. The relevant khamake source code can be viewed in "Kha/Tools/khamake/src/khamake.ts".

## Code changes

Now that we have an asset, we also have to manage loading.

-   Kha gives you a simple, blunt instrument to load things with: "Assets.loadEverything()". The argument to loadEverything is a callback function for when the load is finished.

> Assets also has other, more refined methods that let you pick and choose, but in a simple game that loads everything into memory once, this is the right solution. For the more complex case, each asset also has an unload() method, allowing you to move them in and out of memory as needed.

-   Once everything is loaded, we turn on a flag that lets the update and render callbacks progress.

-   To actually display the text, set "font" and "fontSize" state on Graphics2, and then issue a drawString() command:

    drawString(s : String, x : Float, y : Float);

The string draws with the specified pixel at top-left. You can use the font.width(), font.height(), and font.baseline() attributes as building blocks for text formatting. Each of those sizing methods takes the font size as a parameter.

> The text colors differently when the bomb is dropped. This is a fun side-effect bug that I decided to leave in.

### Empty.hx

```haxe
$$include(projects/8-BombsAway-font/Empty.hx)
```

# Completing the game loop

Now we add the scoring, lives, level progression, and game over state. A lot of meat gets added to the game logic in this section, but API calls do not really change. Review this section if you are interested in gameplay code, or if you need to compare against the later steps where more assets come in.

To make the rocks score different values I introduce a parameter to MTRock. This changes our comparison code slightly, and opens up some options for rendering.

> Parameterization may change the performance characteristics of Enum values. If they have no parameters, you may typically consider them as integer constants - otherwise, think of the implementation as being similar to full object instances underneath. These details may change depending on the target you are working with.

I made some adjustments to the plane motion so that it is more randomized, and at varying heights on each pass. The speed gradually ramps up over time now. (In the original game this is represented by switching from balloons to planes - maybe the wind picked up or something?) The bombs also now have a time/damage counter on them that limits their progress through the boulders.

As I made these additions I also decided to model the game's entities with named Typedefs instead of anonymous objects, and iterate over an array of players instead of just one. This moves it a little bit more towards a final data model and will help if, for example, the original game's two-player mode were implemented(it isn't). It is not a flexible entity system and doesn't try to decouple the data(e.g. a collision structure used by both plane and bombs), but for this simple game it is sufficient.

A "real" HUD now appears, since we're tracking scores and lives. One of the numerous challenges of adding multiplayer is the additional UI elements needed, and in this case I evade the problem by only looking at Player 1.

## Empty.hx

```haxe
$$include(projects/9-BombsAway-complete/Empty.hx)
```

# API 6: Sprite Assets

Sprites are bitmap images that can be moved around the screen; they replace the rectangles we've been using up until this point. Adding sprites will make the game feel a lot less prototype-y. This is a big step and walks us through the asset creation process as well as code.

First of all, we need to have some assets to work with.

[sprites.png](https://github.com/RblSb/khaguide/blob/master/projects/Assets/sprites.png)

I drew up a mockup with some simple sprites and tiles, based on the original game, but adding a little more detail.

Now, we have a few options for turning this mockup into usable assets. Kha will take care of converting and packaging the image when we run khamake. But we still need to assign "meanings" to the assets that make them equivalent to the rectangles we've been using up until now.

-   We could split it into one image for each asset, and refer to different files.

-   We could realign them in a simple tile pattern, and then index by the tile number.

-   Or we could define bounding boxes on the original image.

I'm going to take this last approach, using my own tool, [Pixelbound](http://triplefox.itch.io/pixelbound). It's free(or pay what you want) and comes with source code. Pixelbound makes it very simple to define bounding boxes on mockups. This also has the benefit of letting me specify collision boxes independently of the sprite, if I want.

The output of Pixelbound is a JSON file containing some coordinates:

[spritedata.json](https://github.com/RblSb/khaguide/blob/master/projects/Assets/spritedata.json)
-   Now I take both of these files and add them to "Assets".

-   Since we populated khafile.js when we added the font, we can run khamake now to add them to the project build.

Finally, we write some library code to parse the JSON into easily-accessed assets, and build some drawing functionality that lets us easily swap out our existing code:

## BoundsData.hx

```haxe
$$include(projects/10-BombsAway-graphics/BoundsData.hx)
```

In the main code, we replace the sprite calls, add some branching to switch between plane/blimp and mirror them for the correct direction, add a "smoothing" process to the walls so that the diagonals look nicer, add an explosion "particle", and replace the Kha font calls with our cool bitmapped font. Whew! Adding graphics sure does require a lot of code!

Let's break each of those things down:

## Drawing Plane, Blimp, and Bomb

This is the simplest kind of sprite drawing: take some coordinates and throw an image up on the screen. It's only different from the rectangle drawing in that we're going to conform to the size of the sprite (and we don't even have to do that, necessarily, if we scale the sprite).

We also mirror the plane and blimp. This is done by scaling the sprite with a negative X value.

We can reuse all of our coloring code because I had the foresight to design the sprites to be grayscale, meaning we have a very colorful game without much effort!

> As explained in the Graphics2 API section, if you find the look of the scaling to be "wrong," try switching from using transforms on FastMatrix3 to using a backbuffer at your preferred resolution.

To access spritedata.json we use the Blob API. Khamake appends the file extension to these assets as an underscore, so the field name is "spritedata_json".

## Smoothing the Walls

Now we have more of a "real" tilemap situation, where some tiles look different from others but share the same behaviors. One way we could approach the problem is to separate the visuals from the collision entirely - this is done by most games. But the simpler way for our game is to add a few more values to the Enum, and then update the corresponding switch statements to either behave the same way or render something different.

Then the only thing left to do is to actually populate the walls correctly, which is done in an additional pass after the original canyon generation process finishes.

## Add a Particle

Real particle effects tend to involve some kind of particle simulation that can produce fluid-like effects like smoke, flames, bubbles, etc. Again, we can simplify to "basic" particle programs whose instances hold a position and velocity state. We only use one type here to add little puffs when the rocks are broken, but more are certainly possible! And because we are using Haxe's enums, we can pass parameters into the program so that each instance of the particles may behave a bit differently.

The way in which I spawn particles is also interesting and relevant to any case in a game where there is a "more than one" in the world. I assume that we will only ever have 64 particles at most, and allocate all of them. Then I process all of them each frame, using their timer value to determine liveness. This is a crude technique to avoid triggering garbage collection - just instance a pool of our maximum number, and never add to or remove from the pool. This limits what happens if the system is pressured with a lot of particles - it'll just stop spawning more. It also gives me a realistic measure of maximium system throughput. If I'm already iterating on my maximum quantity, then I can't be fooled into thinking I have "room to waste."

## Bitmap Font

The font data is the most complex part of this whole rendering operation. The font rendering pipeline builds on top of the sprite rendering pipeline, but it has the complication of needing to map each character of the string to a sprite. It works by mapping a given set of characters such as "ABCDEF..." to sprite indexes, starting from a certain named sprite.

I decided, after I had created them, to combine the "alphabet" and "number" groups into one continuous set each, which led to some manual rearrangement of the rectangles Pixelbound auto-generates so that they were in the proper order. Pixelbound doesn't have a group offset feature, but I was able to make the change by editing the JSON text.

After doing all that work to configure the data, the rest is a matter of computing widths for each character based on the sprite data, and then adding some spacing. A more complex font engine can extend to additional layout, effects, more precise spacing and kerning, etc. The game includes some basic layout features in string() and centerString() - it uses the two "alphabets" to make a shadow offset effect.

## Why use a single image for many sprites?

One of the benefits of using a single image for all the sprites, if you aren't aware, is that GPU drawing can be optimized. In the jargon of GPU programming, a "texture" is referenced before beginning a "draw call". During a draw call, you send a "batch" of geometry data - coordinates, offsets, etc. If you don't have to switch textures, the only unique thing the GPU has to process is geometry. Draw calls are a major bottleneck because they cause the GPU to idle, and the stop-start of frequent draw calls will kill performance.

Therefore, the use of sprite sheets is one of the first optimizations encountered in 2D GPU drawing, and well-optimized 2D games will "pack" their sprites tightly in sheets so as to minimize draw calls. (This can be done by hand or by algorithm.)

Graphics2 will do the behind-the-scenes work of optimizing your draw calls when you use drawSubImage() and its variants, so you don't have to know any more than that basic outline to get most of the benefit when working with Kha for 2D games.

## What if I want to upgrade to Graphics4 later?

Direct quote from Robert:

> *g2 runs on g4 and can be mixed with g4 if your target supports g4 (most important exceptions are browsers that don't support webgl or don't activate it because of black-listed drivers).*

> *But g4 is a completely different thing than g2 and needs a much bigger skillset. There are [Lubos' tutorials](https://github.com/luboslenco/kha3d_examples/wiki) though.*

> *Oh and don't expect any speed improvements from d3d12. d3d12 (and vulkan) is about low level control, not about magic speed improvements.*

> *For mixing g2 and g4 have a closer look at kha.graphics4.Graphics2. Mostly it's important to call g2.flush at the right times.*

## Empty.hx

```haxe
$$include(projects/10-BombsAway-graphics/Empty.hx)
```

# API 7: Sound Effects

As with graphics, Kha has multiple "levels" of audio API. Unlike graphics, they don't exactly build on each other. Audio1 is a simplified "recorded sound and music playback" routine, while Audio2 is a "write your own sample data" low-level system. We'll stick with Audio1 here.

First, I figured out a rough asset list and recruited my friend, [Stevie Hryciw](s.hryx.net), to make some sound effects and music. I initially targeted these:

-   drop - when you trigger a bomb drop

-   hit - the bomb succeeded

-   miss - the bomb missed (or you lost a life)

-   break - a rock is broken

-   music - a background soundtrack

Before I had these assets I made a simple sine wave sample using Audacity and copied that as a placeholder.

After our first session, we had changed and expanded the asset list considerably to accommodate variations of similar sounds like the dropping and breaking noises. As tends to happen, the filenames also drifted away from my original scheme, so I updated the project to match. The final files(along with the other assets) are [here](https://github.com/RblSb/khaguide/tree/master/projects/Assets).

Integrating audio into the project can be time-consuming, just like graphical effects. Most of the fancy usage of Audio1 here revolves around cancelling sounds so that they cut off(the bomb falling) or aren't doubling up(the rock breaking sounds). The plane and blimp have a sound loop with volume that is modulated over time, so that they get louder as they get near the center of the screen.

FIXME TODO try to use the right API calls everywhere and not my cheap hacks

## Sound

This is the asset type you use - you normally don't need to deal with it directly since the assets are baked into "Assets.sound".

## audio1.Audio

    Audio.play(sound : Sound, loop : Bool, stream : Bool) : AudioChannel;

Usually call Audio.play(Assets.sound.mysound) for a basic one-shot sound.

-   If the sound is meant to loop, set "loop" to true.

-   If the sound is a very large asset like music, set "stream" to true so that you aren't loading the whole thing into memory at once.

## audio1.AudioChannel

AudioChannel is returned after you start playing a Sound and contains some useful information about the state of the sound's playback: its volume, current sample position, length, and whether it's finished. If you care about these things, keep the instance around to monitor and modulate its parameters. The instances of AudioChannel in Canyon Bomber are used to keep track of loops and sounds that will need to be cancelled.

## Empty.hx

```haxe
$$include(projects/11-BombsAway-sounds/Empty.hx)
```

# Last Thoughts

This guide presents a working game, but that doesn't mean it's "finished". There are bugs, features, and design changes to think about.

There is a minor but slightly annoying bug: If you hold the button down after the plane flies offscreen, it will repeatedly drop useless bombs until all lives are lost.

Sometimes, the bomb hits a single rock, but two different rock breaking sounds play.

The game has no title screen, it simply says "GAME OVER" when the gameplay hasn't started. This is authentic to the original, but not up to modern standards - it could present GAME OVER temporarily, then go to a high scores screen, show instructions, present an attract-mode demo, etc.

Multiplayer is part of the original Canyon Bomber game, but it's not included here. Fixing this will require some changes to the UI, graphics, and sound routines.

The game is unforgivingly strict in a way that is typical of 1970's arcade games; a modern version might consider alternatives to "lives", end the level before clearing every last rock, or change some aspects of the bomb drop and how it's lined up.

The gameplay works on the small scale, but doesn't expand or unfold. It could use a longer-term focus like upgrading your plane, pre-designed puzzles with ingenious solutions, a second phase which uses the cleared canyon in a different way, different scenarios for bombing, etc.

And, of course, the graphics and sound could always be done with more detail.

# Troubleshooting

## I got an error, but who should I ask about it?

-   If you encounter *language or code generation errors*, it is probably a Haxe issue.

-   If you encounter *API, asset import, or build problems*, it is probably a Kha issue.

    At this time, the fastest way to get responses to Kha questions is through the IRC channel:

    > irc.ktxsoftware.com #kha

## Debugging Performance Issues

If you are testing in the browser, make sure it's a clean environment. In Firefox 42.0, for example, old open tabs will share garbage collection pauses with your game.

Make sure you are using appropriate timing mechanisms. Most simulation code runs best as a Scheduler TimeTask. You can divide up the simulation into multiple tasks running on different intervals if necessary; the framework will do its best to run your tasks in the correct order given the intervals and priorities you set. If the hotspot code is related to rendering, then it should probably be a FrameTask.

## Build and Asset Problems

Make sure there aren't file locking issues. Disable any automatic sync programs, reopen the project if it's been regerated, close and reopen editors and command consoles, reboot if you're feeling particularly paranoid.

Make sure you've tried to load your assets before using them - if you aren't using loadEverything(), make sure you've loaded the *right* assets.

## HTML5 Builds

When targeting the Web, security and networking considerations come into play as part of loading your game. In many cases pointing your browser at the generated index.html will run the game.

You can also force your khamake process to run a server with the --server parameter. It defaults to <http://localhost:8080>.

# Contributing to the Kha Guide

The goal of this guide is provide a narrative of game development, as a way of familiarizing readers with Kha and also with broader processes involved in game development.

To do this, the guide provides complete code examples, allowing the reader to bring them into a "real" environment as soon as possible by copy-pasting example code. The API is introduced gradually and naturally, in the way it would appear in a real project.

The guide opts, where reasonable, to be brave. It presents genuine challenges that put the framework to the test, rather than small synthetic examples.

The guide's format is [Github-flavored Markdown](https://help.github.com/categories/writing-on-github/). (Should the needs of the guide change, format conversion may be considered in the future.)

External editors are recommended to ease the pain of syntax and organization. @Triplefox uses a mix of [Twine 2](http://twinery.org/) (hypertext design) and [MdCharm](http://www.mdcharm.com/) (body text formatting).

## Common Technical Writing Practices

-   Lead with the "what" and "why" of each item: What is this, and why do I need it?

-   Follow up with the "when" and "where": in which situation is it needed?

-   Do not use "should", "may", "can", or "when" to describe a task.

-   Prefer "shall", "must", "will" or "shall not", "must not", "will not".

-   Break tasks into 7 steps, plus or minus two.

-   If more steps are required, use subheadings and group the steps into logical categories.

## Style

Quotes and asides are written using blockquote syntax:

According to Plato,

> *The beginning is the most important part of the work.*

Source should be kept inline with the document where possible, using the appropriate syntax highlighting hint:

```haxe
class HelloWorld {
    public function new() {
        trace("hello world");
    }
}
```
