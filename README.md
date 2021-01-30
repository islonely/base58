# Fast Implementation Base58 encoding/decoding
Fast implementation of Base58 encoding and decoding in V.

Base algorithm is adapted from [mr-tron/base58](https://github.com/mr-tron/base58)

## Installation
V must first be installed on your machine. You can get that from [vlang/v](https://github.com/vlang/v). After installing V execute this command to install this module to your system. And that's it!
```bash
$ v install base58
```
Or alternatively, inside the root directory of your V project execut this:
```bash
$ mkdir modules
$ cd modules
$ git clone https://github.com/is-lonely/base58
```
## Usage
The default base58 alphabet is the same as the Bitcoin alphabet.
```v
import base58

fn main() {
    input_string := 'placeholder'
    encoded := base58.encode(input_string)
    decoded := base58.decode(encoded) or {
        println(err)
        exit(0)
    }
                                        // Output
	println('Input:\t\t$input_string')  // placeholder
	println('Encoded:\t$encoded')       // UswB5kJAjqsX6JM
	println('Decoded:\t$decoded')       // placeholder
}
```

For use with custom alphabets:
```v
import base58

fn main() {
    custom_alphabet := base58.new_alphabet(r'`~!@#$%^&*()_-+={[}]|\;:"?/>.<,Uwu1029384756qmWnebrvtycxhP')

    input_string := 'I did you know what with ur mom. *maniacal laugh*'
    encoded := base58.encode_walpha(input_string, custom_alphabet)
    decoded := base58.decode_walpha(encoded, custom_alphabet) or {
        println(err)
        exit(0)
    }
                                        // Output
	println('Input:\t\t$input_string')  // I did you know what with ur mom. *maniacal laugh*
	println('Encoded:\t$encoded')       // )e7_|32m%{5W`)~$U=|`">&cw`!q^~c4{]P<7}>7r?8|`n2:67h61h3\|!e8(^m/89_
	println('Decoded:\t$decoded')       // I did you know what with ur mom. *maniacal laugh*
}
```