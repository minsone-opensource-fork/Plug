[![Build Status](https://travis-ci.org/lewandowskit93/Plug.svg?branch=master)](https://travis-ci.org/lewandowskit93/Plug)
[![codecov](https://codecov.io/gh/lewandowskit93/Plug/branch/master/graph/badge.svg)](https://codecov.io/gh/lewandowskit93/Plug)
[![Carthage compatible](https://img.shields.io/badge/Carthage-Compatible-brightgreen.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Cocoapods](https://img.shields.io/cocoapods/v/Plug.svg?style=flat)](https://cocoapods.org/pods/Plug)
[![Platform](https://img.shields.io/cocoapods/p/Plug.svg?style=flat)](https://cocoapods.org/pods/Plug)
[![Platform](https://img.shields.io/badge/Platform-linux-brightgreen.svg)](#)
[![License](https://img.shields.io/cocoapods/l/Plug.svg?style=flat)](https://cocoapods.org/pods/Plug)

Plug is a multi-platform plugin architecture micro-framework and plugin manager written in pure Swift. It allows to define rules that has to be met to activate plugins at given plugin point.

## Requirements

### Development
Project uses following tools for development
1. [XCodeGen](https://github.com/yonaskolb/XcodeGen)
2. [Cocoapods](https://cocoapods.org)
3. [SwiftLint](https://github.com/realm/SwiftLint)

## Installation

To get started with the **Plug** you first have to decide how you will integrate it with your project. Plug supports following tools:

### Cocoapods

To install Plug using Cocoapods go through following steps:

1. Add the following entry in your **Podfile**:
```
pod 'Plug'
```
2. Then run `pod install`.


### Carthage

To install Plug using Carthage go through following steps:

1. Add the following entry to your **Cartfile**

```
github "lewandowskit93/Plug"
```

2. Then run ```carthage update```

### Swift Package Manager

To install Plug using **Swift Package Manager** go through following steps:

1. Add following package dependency in you **Package.swift** ``` .package(url: "https://github.com/lewandowskit93/Plug.git", from: "0.4.0") ```
2. Add following target dependency in your **Package.swift** ``` dependencies: ["Plug"]) ```

For instance this is how it might look like:
```swift
import PackageDescription

let package = Package(
    name: "YourLibrary",
    products: [
        .library(
            name: "YourLibrary",
            targets: ["YourLibrary"])
    ],
    dependencies: [
        .package(url: "https://github.com/lewandowskit93/Plug.git", from: "0.4.0")
    ],
    targets: [
        .target(
            name: "YourLibrary",
            dependencies: ["Plug"])
    ]
)
```

## Overview

Here is a quick overview of functionalities and concepts used in **Plug**.

<p align="center">
  <img src="Resources/Plug.png" alt="Plug example"/>
</p>

### Plugin

**Plugin** is anything that implements **PPlugin** protocol. You can define what your plugins are and what they do.

As an example here you can see *ViewPlugin* which can return single SwiftUI view:
```swift
public final class ViewPlugin<V: View>: PPlugin {
    private let builder: () -> V
    
    public init(builder: @escaping () -> V) {
        self.builder = builder
    }
    
    public var view: some View {
        return builder()
    }
}
```

### RuleResolvingContext

**RuleResolvingContext** is anything that implements **PRuleResolvingContext**. Everything in the Plug is generic over PRuleResolvingContext. It can provide additional information to decide if the plugins are enabled.

### Rule

**Rule** decides whether plugins should be returned or not depending on the context. You can define your own rules by implementing **PRule** protocol.
There are a few rules available for you: *AtomRule*, *EnabledRule*, *DisabledRule*, *InvertedRule*, *AllOfRule*, *AnyOfRule*, *NoneOfRule*, *AnyRule*.

### PluginPoint

**PluginPoint** defines a single slot to which plugins can be attached. Single plugin point can have multiple plugins and rules that describes them.
It has a hierarchical structure meaning that a plugin point can have *children* plugin points.
The rules applied to a plugin point are also applied to it's children. Plugin points can be built with **PluginPointBuilder**

### DSL
Plug defines some operators and DSL to shorten building of plugin points. Available operators are:
- Adding plugin with operator: *Builder <+ Plugin*
- Removign plugin with operator: *Builder <- Plugin*
- Adding rule with operator: *Builder §+ Rule*
- Removing rule with operator: *Builder §- Rule*
- Adding child with operator: *Builder |+ PluginPoint*
- Removing child with operator: *Builder |- PluginPoint*
- Finalize building with operator: *Builder^*

There are also operators available for rules building:
- Inverting a rule: *!AnyRule*
- AllOfRule: *&&[AnyRule]*
- NoneOfRule: *~~[AnyRule]*
- AnyOfRule: *||[AnyRule]*


## Example

This is an example definition of plugin point which allows two plugin features to exist if they are enabled in FooContext.

```swift
var pluginPoint = PluginPointBuilder()
    .add(child: PluginPointBuilder()
        .add(plugin: pluginFactory.feature1Plugin())
        .add(rule: FeatureEnabledRule(id: "feature_1").any())
        .build()
    )
    .add(child: PluginPointBuilder()
        .add(plugin: pluginFactory.feature2Plugin())
        .add(rule: FeatureEnabledRule(id: "feature_2").any())
        .build()
    ).build()
var availablePlugins = pluginPoint.getAvailablePlugins(context: FooContext())
```

The same plugin point could be defined using operators as follows:


```swift
var pluginPoint = (
        PluginPointBuilder()
        |+ (
            PluginPointBuilder()
            <+ pluginFactory.feature1Plugin()
            §+ FeatureEnabledRule(id: "feature_1").any()
           )^
        |+ (
            PluginPointBuilder()
            <+ pluginFactory.feature2Plugin()
            §+ FeatureEnabledRule(id: "feature_2").any()
           )^
    )^
var availablePlugins = pluginPoint.getAvailablePlugins(context: FooContext())
```

or using DSL as follows:

```swift
var pluginPoint = PluginPoint {
    child {
        PluginPoint {
            plugin(contextType: Context.self) { pluginFactory.feature1Plugin() }
            rule(pluginType: Plugin.self) { FeatureEnabledRule(id: "feature_1").any() }
        }
    }
    child {
        PluginPoint {
            plugin(contextType: Context.self) { pluginFactory.feature2Plugin() }
            rule(pluginType: Plugin.self) { FeatureEnabledRule(id: "feature_2").any() }
        }
    }
}
```

For more detailed example please see the source code.

## Contribution

Project is created and maintained by **Tomasz Lewandowski**.

If you created some new feature or fixed a bug you can create a pull request. Please feel free to submit your feature requests if you have any.

## License

Plug is released under an MIT license. See [License.md](LICENSE.md) for more information.
