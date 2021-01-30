module base58

const(
	btc_alphabet = new_alphabet('123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz')
	flickr_alphabet = new_alphabet('123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ')
)

struct Alphabet {
mut:
	decode []i8 = []i8{len: 128}
	encode []byte = []byte{len: 58}
}

fn (alphabet Alphabet) str() string {
	return alphabet.encode.str()
}

fn new_alphabet(str string) &Alphabet {
	if str.len != 58 {
		panic('base58 > new_alphabet(string): string must be 58 characters in length')
	}

	mut ret := &Alphabet{}
	copy(ret.encode, str.bytes())
	for i, _ in ret.decode {
		ret.decode[i] = -1
	}

	mut distinct := 0
	for i, b in ret.encode {
		if ret.decode[b] == -1 {
			distinct++
		}
		ret.decode[b] = i8(i)
	}

	if distinct != 58 {
		panic('base58 > new_alphabet(string): string must not contain repeating characters')
	}

	return ret
}