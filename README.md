# Razer Build Light

A simple Mac application to turn your Razer Chroma device into a build light.

## How it works

Razer Build Light will prompt you to login to your Github account, you can then add the projects (repository & branch) you'd like to monitor. The app automatically sets up an appropriate web hook for each Github respository that you add. Razer Build Light uses web sockets to monitor build statuses; as such it will function behind a firewall and update in real time (no polling delays). The web hook added to your project points to [a simple server](https://github.com/Benjamin-Dobell/websockethook) that forwards web hook data over web socket connections to each of the clients monitoring the relevant project.

When you login to Github, you will need to authorize Razer Build Light's access to your Github repositories. You'll note that this app does *not* require source reading privileges, just build status access and the web hook admin (to automatically configure the web hooks for you).

There is no official Razer SDK for OS X, so we're using our own, [GERazerKit](https://github.com/Benjamin-Dobell/GERazerKit).

__Note:__ At present only the Mamba (Wireless) is officially supported, but pull requests are welcome.

## Build Prerequisites

After cloning the main repo you must also clone the submodules:

    git submodule update --init --recursive

Octokit requires additional dependencies/setup:

    cd octokit.objc/
    ./script/bootstrap
    cd ..

You may then open the XCode workspace in XCode or AppCode and build the RazerBuildLight target.

