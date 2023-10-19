extends Morton
class_name Morton3

## Return a 64 bits Morton code, with x, y, z bits interleaved like this:
## 0b 0 z20 y20 x20 _ z19 y19 x19 z18 _ ... y0 x0
## The first bit is always left out
## Can't encode value > 2097151 (0x1FFFFF, 21 bits)
static func encode64(x: int, y: int, z: int) -> int:
	assert(not ((x|y|z) & (~0x1FFFFF)), "ERROR: Morton3 encoding values of more than 21 bits")
	return _encodeMB64(x) | (_encodeMB64(y)<<1) | (_encodeMB64(z)<<2)

## Return @code decoded into an int64 "zyx"
## 21 least significant bits are x
## 21 next significant bits are y
## The rest is z
## Pass this value to x(), y() and z() functions
## to extract their values
static func decode64(code: int) -> int:
	return _decodeMB64(code & _INTERPOSITION)\
			| (_decodeMB64((code >> 1) & _INTERPOSITION) << 21)\
			| (_decodeMB64((code >> 2) & _INTERPOSITION) << 42)

static func x(decoded: int) -> int:
	return decoded & 0x1FFFFF

static func y(decoded: int) -> int:
	return (decoded >> 21) & 0x1FFFFF
	
static func z(decoded: int) -> int:
	return decoded >> 42

## Encode a value using Magic Bits algorithm
static func _encodeMB64(x: int) -> int:
	
	x = ((x & 0b00000000_00000000_00000000_00000000_00000000_00011111_00000000_00000000) << 32 | x) \
			& 0b00000000_00011111_00000000_00000000_00000000_00000000_11111111_11111111
			
	x = ((x & 0b00000000_00000000_00000000_00000000_00000000_00000000_11111111_00000000) << 16 | x) \
			& 0b00000000_00011111_00000000_00000000_11111111_00000000_00000000_11111111
			
	x = ((x & 0b00000000_00010000_00000000_00000000_11110000_00000000_00000000_11110000) << 8 | x) \
			& 0b00010000_00001111_00000000_11110000_00001111_00000000_11110000_00001111
			
	x = ((x & 0b00000000_00001100_00000000_11000000_00001100_00000000_11000000_00001100) << 4 | x)\
			& 0b00010000_11000011_00001100_00110000_11000011_00001100_00110000_11000011
			
	x = ((x & 0b00010000_10000010_00001000_00100000_10000010_00001000_00100000_10000010) << 2 | x)\
			& 0b00010010_01001001_00100100_10010010_01001001_00100100_10010010_01001001
	
	return x


## Decode a value using Magic Bits algorithm
static func _decodeMB64(x: int) -> int:
	x = ((x & 0b0000_001000_001000_001000_001000_001000_001000_001000_001000_001000_001000) >> 2 | x)\
			& 0b0001_000011_000011_000011_000011_000011_000011_000011_000011_000011_000011
			
	x = ((x & 0b0000_000011_000000_000011_000000_000011_000000_000011_000000_000011_000000) >> 4 | x)\
			& 0b0001_000000_001111_000000_001111_000000_001111_000000_001111_000000_001111

	x = ((x & 0b00010000_00000000_00000000_11110000_00000000_00000000_11110000_00000000) >> 8 | x)\
			& 0b00000000_00011111_00000000_00000000_11111111_00000000_00000000_11111111

	x = ((x & 0b00000000_00000000_00000000_00000000_11111111_00000000_00000000_00000000) >> 16 | x)\
			& 0b00000000_00011111_00000000_00000000_00000000_00000000_11111111_11111111
	
	x = ((x & 0b00000000_00011111_00000000_00000000_00000000_00000000_00000000_00000000) >> 32 | x)\
			& 0b00000000_00000000_00000000_00000000_00000000_00011111_11111111_11111111
	
	return x
	
const _INTERPOSITION = 0b001_001_001_001_001_001_001_001_001_001_001_001_001_001_001_001_001_001_001_001_001


static func automated_test():
	var no_error = true
	for i in range(0, floor(64.0/3)):
		var value = 1 << i
		var encode_value = Morton3.encode64(value, 0, 0)
		var expected_value = 1 << (i*3)
		var decode_value = Morton3.x(Morton3.decode64(expected_value))
		#print("Value:\t%s\nEncode:\t%s\nExpect:\t%s\nDecode:\t%s\n" % \
		#		[int_to_bin(value, 64),
		#		int_to_bin(encode_value, 64),
		#		int_to_bin(expected_value, 64),
		#		int_to_bin(decode_value, 64)])
				
		if encode_value != expected_value:
			no_error = false
			printerr("Encoding %d got %d but expected %d!" % [value, encode_value, expected_value])
			printerr("Value:\t'%s'\nEncoded:\t%s\nExpected:\t%s" \
					% [int_to_bin(value, 64),\
						int_to_bin(expected_value, 64),\
						int_to_bin(encode_value, 64)])
		
		if decode_value != value:
			no_error = false
			printerr("Decoding %d got %d but expected %d!" % [expected_value, decode_value, value])
			printerr("Value:\t%s\nDecoded:\t%s\nExpected:\t%s" \
					% [int_to_bin(expected_value, 64),\
						int_to_bin(decode_value, 64),\
						int_to_bin(value, 64)])
						
	if no_error:
		print("All Morton3 tests passed.")
