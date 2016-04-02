# Razer Build Light

A simple Mac application to turn your Razer Chroma device into a build light.

__Note:__ At present only the Mamba (Wireless) is officially supported, but pull requests are welcome.

## Build Prerequisites

After cloning the main repo you must also clone the submodules:

    git submodule update --init --recursive

Octokit requires additional dependencies/setup:

    cd octokit.objc/
    ./script/bootstrap
    cd ..

You may then open the XCode workspace in XCode or AppCode and build the RazerBuildLight target.

