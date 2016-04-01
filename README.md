# Pop-Up Collection View


<p align="center">
<img src="/Assets/preview.gif" />
</p>

Pop-Up Collection View is a replacement for the traditional
navigation collection view style and is written in Swift 2.0.


[![CI Status](http://img.shields.io/travis/Lawrence Tran/PopUpCollectionView.svg?style=flat)](https://travis-ci.org/Lawrence Tran/PopUpCollectionView)
[![Version](https://img.shields.io/cocoapods/v/PopUpCollectionView.svg?style=flat)](http://cocoapods.org/pods/PopUpCollectionView)
[![License](https://img.shields.io/cocoapods/l/PopUpCollectionView.svg?style=flat)](http://cocoapods.org/pods/PopUpCollectionView)
[![Platform](https://img.shields.io/cocoapods/p/PopUpCollectionView.svg?style=flat)](http://cocoapods.org/pods/PopUpCollectionView)


## Features
* Coolness
* Fast and lightweight
* Preserves content animations (see below)

## Usage

Pop-Up Collection View mimics the behavior of a normal collection view. Instantiate via code or in the interface builder. Do not forget to set the delegate and data source.

```swift
// Init Pop-Up Collection View
let popUpCollectionView = PopUpCollectionView(frame: CGRectZero)
popUpCollectionView.delegate = self
popUpCollectionView.dataSource = self
```

## Documentation

#### Variables

```swift
var delegate: PopUpCollectionViewDelegate
var dataSource: PopUpCollectionViewDataSource
```

#### Methods

```swift
func reloadData()
```
Refreshes Pop-Up Collection View.

#### Delegate

```swift
func popUpCollectionView(popUpCollectionView: PopUpCollectionView, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
```
Pop-Up Collection View dynamically sets its cells. This method asks the delegate for the size of the content at the given index path. Put in any size, and Pop-Up Collection View will automatically scale it to fit its layout.  

```swift
func setStatusBarHidden(hidden: Bool)
```
Implement this method to hide/reveal the status bar. (See the demo for implementation)

#### Data Source

```swift
func popUpCollectionView(popUpCollectionView: PopUpCollectionView, numberOfItemsInSection section: Int) -> Int
```
Set the number of items in each section. Note that Pop-Up Collection View works best when there is only one section as section headers are currently not supported.

```swift
func popUpCollectionView(popUpCollectionView: PopUpCollectionView, contentViewAtIndexPath indexPath: NSIndexPath) -> UIView
```
Asks the data source for the content view for a given index path. This can be any implementation of a UIView.

```swift
func popUpCollectionView(popUpCollectionView: PopUpCollectionView, infoViewForItemAtIndexPath indexPath: NSIndexPath) -> UIView
```
Asks the data source for the info view for the given index path. Set the view's frame to the size for when it is displayed. Pop-Up Collection View will automatically handle scaling.

## Preserving Animations

Pop-Up Collection View preserves content animations during transitions. This was tested using [FLAnimatedImage](https://github.com/Flipboard/FLAnimatedImage).

<p align="center">
<img src="/Assets/preserve.gif" />
</p>

Note, this does not work with an UIImage extension such as [SwiftGif](https://github.com/bahlo/SwiftGif).

## Demo

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
* Swift 2.0+
* iOS 8.0+

## Installation

PopUpCollectionView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "PopUpCollectionView"
```
## Roadmap
Pop-Up Collection View is still in beta and should not be considered stable.

## Author

Lawrence Tran, lawrence@tran.com

## License

PopUpCollectionView is available under the MIT license. See the LICENSE file for more info.
