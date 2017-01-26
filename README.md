# Arranged.StackView

<p align="left">
<img src="https://img.shields.io/cocoapods/v/Arranged.svg?label=version">
<a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"></a>
<a href="http://cocoadocs.org/docsets/Arranged"><img src="https://img.shields.io/cocoapods/p/Arranged.svg?style=flat)"></a>
</p>

Open source replacement of [UIStackView](https://developer.apple.com/library/prerelease/ios/documentation/UIKit/Reference/UIStackView_Class_Reference/) for iOS 8 (100% layouts supported)

<img src="https://cloud.githubusercontent.com/assets/1567433/13573981/364b2946-e493-11e5-9d02-893a5dc11a8c.png" width="50%"/>

- Supports all `alignments` and `distributions`, `spacing`, `baselineRelativeArrangement`, `layoutMarginsRelativeArrangement`, `axis`
- Unit tested, thousands of layouts covered
- Supports animations
- Generates exactly the same sets of constraints as `UIStackView`:

**UIStackView** (`Alignment.Leading`, `Distribution.FillEqually`)
```
<'UISV-alignment' content-view-1.top == content-view-2.top>
<'UISV-canvas-connection' UIStackView:0x7f9cf4816930.leading == content-view-1.leading>
<'UISV-canvas-connection' H:[content-view-2]-(0)-|>
<'UISV-canvas-connection' UIStackView:0x7f9cf4816930.top == content-view-1.top>
<'UISV-canvas-connection' V:[_UILayoutSpacer:0x7f9cf4849f80'UISV-alignment-spanner']-(0)-|>
<'UISV-fill-equally' content-view-2.width == content-view-1.width>
<'UISV-spacing' H:[content-view-1]-(10)-[content-view-2]>
<'UISV-spanning-boundary' _UILayoutSpacer:0x7f9cf4849f80'UISV-alignment-spanner'.top == content-view-1.top priority:999.5>
<'UISV-spanning-boundary' _UILayoutSpacer:0x7f9cf4849f80'UISV-alignment-spanner'.bottom >= content-view-1.bottom>
<'UISV-spanning-boundary' _UILayoutSpacer:0x7f9cf4849f80'UISV-alignment-spanner'.top == content-view-2.top priority:999.5>
<'UISV-spanning-boundary' _UILayoutSpacer:0x7f9cf4849f80'UISV-alignment-spanner'.bottom >= content-view-2.bottom>
<'UISV-spanning-fit' V:[_UILayoutSpacer:0x7f9cf4849f80'UISV-alignment-spanner'(0@51)] priority:51>
<'UISV-ambiguity-suppression' V:[content-view-1(0@25)] priority:25>
<'UISV-ambiguity-suppression' V:[content-view-2(0@25)] priority:25>
```

**Arranged** (`Alignment.Leading`, `Distribution.FillEqually`)
```
<'ASV-alignment' content-view-1.top == content-view-2.top>
<'ASV-canvas-connection' Arranged.StackView:0x7f9cf4822c90.leading == content-view-1.leading>
<'ASV-canvas-connection' H:[content-view-2]-(0)-|>
<'ASV-canvas-connection' Arranged.StackView:0x7f9cf4822c90.top == content-view-1.top>
<'ASV-canvas-connection' V:[Arranged.LayoutSpacer:0x7f9cf2c4f3f0]-(0)-|>
<'ASV-fill-equally' content-view-1.width == content-view-2.width>
<'ASV-spacing' H:[content-view-1]-(10)-[content-view-2]>
<'ASV-spanning-boundary' Arranged.LayoutSpacer:0x7f9cf2c4f3f0.top == content-view-1.top priority:999.5>
<'ASV-spanning-boundary' Arranged.LayoutSpacer:0x7f9cf2c4f3f0.bottom >= content-view-1.bottom>
<'ASV-spanning-boundary' Arranged.LayoutSpacer:0x7f9cf2c4f3f0.top == content-view-2.top priority:999.5>
<'ASV-spanning-boundary' Arranged.LayoutSpacer:0x7f9cf2c4f3f0.bottom >= content-view-2.bottom>
<'ASV-spanning-fit' V:[Arranged.LayoutSpacer:0x7f9cf2c4f3f0(0@51)] priority:51>
<'ASV-ambiguity-suppression' V:[content-view-1(0@25)] priority:25>
<'ASV-ambiguity-suppression' V:[content-view-2(0@25)] priority:25>
```

## Usage

`Arranged.StackView` is used the same way `UIStackView` is:

```swift
let stackView = StackView(arrangedSubviews: [view1, view2, view3])
stackView.alignment = .leading
stackView.distribution = .fillEqually
stackView.spacing = 20
stackView.axis = .vertical
stackView.isLayoutMarginsRelativeArrangement = true
```

The only difference is hiding items:

```swift
UIView.animateWithDuration(0.33) {
    stackView.setArrangedView(view, hidden: true)
    stackView.layoutIfNeeded()
}
```

## Requirements

- iOS 8.0, tvOS 9.0
- Xcode 8 
- Swift 3

## Getting Started

- Get a demo project using `pod try Arranged` command
- [Install](#installation), `import Arranged` and enjoy!

## Differences

- `UIStackView` observes `hidden` property of arranged views, delays its effect if called inside animation block, and updates constraints accordingly. I believe this behavior is confusing and impractical to implement. `Arranged.StackView` provides a straightforward method `setArrangedView(_:hidden:)` which updates constraints exactly the same way as `UIStackView` does, but it doesn't affect `hidden` property.
- Animations require you to call `view.layoutIfNeeded()` - just like with any regular layout
- `StackViewDistribution.FillProportionally` doesn't update its constrains when `intrinsicContentSize` of arranged views changes due to the fact that `UIStackView` uses private API (`_intrinsicContentSizeInvalidatedForChildView`) to achieve that
- `UISV-text-width-disambiguation` constraints are not implemented because they are not documented (and you probably should disambiguate text views the way that fits your app anyway)

## Installation<a name="installation"></a>

### [CocoaPods](http://cocoapods.org)

To install Arranged add a dependency to your Podfile:

```ruby
# source 'https://github.com/CocoaPods/Specs.git'
# use_frameworks!
# platform :ios, "8.0"

pod "Arranged"
```

### [Carthage](https://github.com/Carthage/Carthage)

To install Arranged add a dependency to your Cartfile:

```
github "kean/Arranged"
```

### Import

Import installed modules in your source files

```swift
import Arranged
```

## License

Arranged is available under the MIT license. See the LICENSE file for more info.
