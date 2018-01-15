# ComicBookKit
Display [comic book documents](https://en.wikipedia.org/wiki/Comic_book_archive) in your applications.
This framework does not unpack to temporary directory, that Images will be unpacked on memory as requested.

## Support Format
* cbz(zip)
* cbr(rar)

## Usage
### CBZ Document
```swift
import ComicBookKit

guard let document = CBZDocument(url: zipURL) else {
    // invalid zip file
    return
}

let image = document.image(at: 0)
// Show document image
```

### CBR Document
```swift
import ComicBookKit

guard let document = CBRDocument(url: rarURL) else {
    // invalid rar file
    return
}

let image = document.image(at: 0)
// Show document image
```

## Requirements
* Swift 4
* iOS 8

## Installation
* **Using [Carthage](https://github.com/Carthage/Carthage)**:
    ```
    github "Jaesung-Jung/ComicBookKit"
    ```
    ```
    $ carthage update
    ```

## License
ComicBookKit is under MIT license. See the [LICENSE](https://github.com/Jaesung-Jung/ComicBookKit/blob/master/LICENSE) for more info.
