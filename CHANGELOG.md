[Changelog](https://github.com/kean/Arranged/releases) for all versions

## Arranged 2.1

- Updated to Swift 4

## Arranged 2.0
 
- Updated to Swift 3

## Arranged 1.0.4

- Activate constraints using `activate` property instead of manually adding them to the view
- `StackView` now returns true in `requiresConstraintBasedLayout`
- `LayoutGuides` are now hidden by default
- `LayoutGuides` now have `translatesAutoresizingMaskIntoConstraints` set to false be default

## Arranged 1.0.3
 
- `insertArrangedSubview(_:atIndex:)` method now updates the stack index (but not the subview index) of the arranged subview if it's already in the `arrangedSubviews` list.
- Add app extensions support
- Add tvOS support (useful if you share code between iOS 8.0 and tvOS)

## Arranged 1.0.2

- Make _viewForFirstBaselineLayout private (was made public by mistake)
- Update documentation

## Arranged 1.0.1

- More efficient constraint deactivation on updateConstraints()
- Cleaner arrangements implementation

## Arranged 1.0

- Initial release
