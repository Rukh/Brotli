# Brotli
This package is a wrapper around C lib from https://github.com/google/brotli.git for Swift.

## Usage
For encode / decode use static function from `Brotli` class.
Data size must be equal or bigger than block size (16 byte). It means
```
let data = "Hello World!".data(using: .utf8)!
let encoded = try Brotli.encode(data, mode: .text)
```
This code throws error: data is too small to be encoded. Size must be >= 16.
The correct way - use Brotli for large data, then compressing will make sense.
```
let data = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam quis velit sed tellus fringilla pretium ac sed erat. Nullam tempus a nulla a aliquam. Etiam in enim dolor. Mauris at auctor justo, non laoreet turpis. Integer varius luctus odio id accumsan. Donec convallis faucibus diam ut congue. Nunc a aliquam nulla. Sed laoreet turpis quis velit mattis, vitae finibus elit aliquam. In at purus dui. Ut eu nisl sem. Pellentesque quam orci, placerat id urna a, condimentum blandit odio. Proin feugiat libero a finibus pellentesque. Etiam volutpat non augue ut posuere.".data(using: .utf8)!

let encoded = try Brotli.encode(data, mode: .text)
let decoded = try Brotli.decode(encoded)
```
