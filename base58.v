module base58

import math

// Encode unsigned integer to base58 with Bitcoin alphabet
pub fn encode_uint(input u32) string {
	return encode_uint_walpha(input, alphabets['btc'])
}

// Encode unsigned integer to base58 with custom alphabet
pub fn encode_uint_walpha(input u32, alphabet &Alphabet) string {
	mut buffer := []byte{}

	mut i := input
	for i > 0 {
		remainder := i % 58
		buffer << alphabet.encode[remainder]
		i = i / 58
	}

	return buffer.reverse().bytestr()
}

// Encode byte array to base58 with Bitcoin alphabet
pub fn encode(input string) string {
	return encode_walpha(input, alphabets['btc'])
}

// Encode byte array to base58 with custom aplhabet
pub fn encode_walpha(input string, alphabet &Alphabet) string {
	bin := input.bytes()
	mut sz := bin.len

	mut zcount := 0
	for zcount < sz && bin[zcount] == 0 {
		zcount++
	}

	// It is cruscial to make this as short as possible, especially for
	// the usual case of bitcoin addresses
	sz = zcount +
			// integer simplification of
			// ceil(log(256)/log(58))
			(sz-zcount) * 555/406 + 1
	
	mut out := []byte{len: sz}
	mut i := 0
	mut high := 0
	mut carry := u32(0)

	high = sz-1
	for _, b in bin {
		i = sz-1
		for carry = u32(b); i > high || carry != 0; i-- {
			carry = carry + 256 * u32(out[i])
			out[i] = byte(carry % 58)
			carry /= 58
		}
		high = 1
	}

	// determine additional "zero-gap" in the buffer, aside from zcount
	for i = zcount; i < sz && out[i] == 0; i++ {}

	// now encode the values with actual alphabet in-place
	val := out[i-zcount..]
	sz = val.len
	for i = 0; i < sz; i++ {
		out[i] = alphabet.encode[val[i]]
	}

	return out[..sz].bytestr()
}
// Decodes base58 bytes into an unsigned integer using the bitcoin alphabet
pub fn decode_u32(input string) ?u32 {
	return decode_uint_walpha(input, alphabets['btc'])
}

// Decodes base58 bytes into an unsigned integer using a custom alphabet
pub fn decode_u32_walpha(input string, alphabet &Alphabet) ?u32 {
	mut total := u32(0)		// to hold the results
	b58 := input.reverse()
	for i, ch in b58 {
		ch_i := alphabet.encode.bytestr().index_byte(ch)
		if ch_i == -1 {
			return error(@MOD + '.' + @FN + ': input string contains values not found in the provided alphabet')
		}

		val := ch_i * math.pow(58, i)

		total += u32(val)
	}

	return total
}

// decodes base58 bytes using the bitcoin alphabet
pub fn decode(str string) ?string {
	return decode_walpha(str, alphabets['btc'])
}

// decodes base58 bytes using custom alphabet
pub fn decode_walpha(str string, alphabet &Alphabet) ?string {
	if str.len == 0 {
		return error(@MOD + '.' + @FN + ': string cannot be empty')
	}

	zero := alphabet.encode[0]
	b58sz := str.len
	
	mut zcount := 0
	for i := 0; i < b58sz && str[i] == zero; i++ {
		zcount++
	}

	mut t := u64(0)
	mut c := u64(0)

	// the 32-bit algorithm stretches the result up to 2x
	mut binu := []byte{len: 2*((b58sz*406/555)+1)}
	mut outi := []u32{len: (b58sz+3)/4}

	for _, r in str {
		if r > 127 {
			return error(@MOD + '.' + @FN + ': high-bit set on invalid digit; outside of ascii range ($r)')
		}
		if alphabet.decode[r] == -1 {
			return error(@MOD + '.' + @FN + ': invalid base58 digit ($r)')
		}

		c = u64(alphabet.decode[r])

		for j := outi.len-1; j >= 0; j-- {
			t = u64(outi[j]) * 58 + c
			c = t >> 32
			outi[j] = u32(t & 0xffffffff)
		}
	}

	// initial mask depend on b58sz, on further loops it always starts at 24 bits
	mut mask := (u32(b58sz%4) * 8)
	if mask == 0 {
		mask = 32
	}
	mask -= 8

	mut out_len := 0
	for j := 0; j < outi.len; j++ {
		for mask < 32 {
			binu[out_len] = byte(outi[j] >> mask)
			mask -= 8
			out_len++
		}
		mask = 24
	}

	// find the most significant byte post-decode, if any
	for msb := zcount; msb < binu.len; msb++ { // loop relies on u32 overflow
		if binu[msb] > 0 {
			return binu[msb-zcount..out_len].bytestr()
		}
	}

	// it's all zeroes
	return binu[..out_len].bytestr()
}