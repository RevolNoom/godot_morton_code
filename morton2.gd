extends Morton
class_name Morton2

## Return a 64 bits Morton code, with x, y bits interleaved like this:
## 0b 0 0 y19 x19 ... y0 x0
## Can't encode value > 4294967295 (0x7FFF_FFFF, 32 bits)
static func encode64(x: int, y: int) -> int:
	assert(not ((x|y) & (~0xFFFF_FFFF)), "ERROR: Morton2 encoding values of more than 32 bits")
	return _encodeMB64(x) | (_encodeMB64(y)<<1)

## Return @code decoded into a int64 "yx"
## 32 least significant bits are x, the rest is y
## Pass this value to x() and y() functions
## to extract their values
static func decode64(code: int) -> int:
	return _decodeMB64(code & _INTERPOSITION)\
			| ((_decodeMB64(code >> 1) & _INTERPOSITION) << 32)
			
static func x(decoded: int) -> int:
	return decoded & 0xFFFF_FFFF
	
static func y(decoded: int) -> int:
	return decoded >> 32


	
## Encode a value using Magic Bits algorithm
## NOTE: Godot v4.2.dev6.official.57a6813bb has problem parsing
## hex number, so I'm resorting to bits instead
static func _encodeMB64(x: int) -> int:
	x = ((x & 0b00000000_00000000_00000000_00000000_11111111_11111111_00000000_00000000) << 16 | x) \
			& 0b00000000_00000000_11111111_11111111_00000000_00000000_11111111_11111111
	
	x = ((x & 0b00000000_00000000_11111111_00000000_00000000_00000000_11111111_00000000) << 8 | x) \
			& 0b00000000_11111111_00000000_11111111_00000000_11111111_00000000_11111111

	x = ((x & 0b00000000_11110000_00000000_11110000_00000000_11110000_00000000_11110000) << 4 | x) \
			& 0b00001111_00001111_00001111_00001111_00001111_00001111_00001111_00001111
			
	x = ((x & 0b00001100_00001100_00001100_00001100_00001100_00001100_00001100_00001100) << 2 | x) \
			& 0b00110011_00110011_00110011_00110011_00110011_00110011_00110011_00110011
			
	x = ((x & 0b00100010_00100010_00100010_00100010_00100010_00100010_00100010_00100010) << 1 | x) \
			& 0b01010101_01010101_01010101_01010101_01010101_01010101_01010101_01010101
			
	return x


## Decode a value using Magic Bits algorithm
static func _decodeMB64(x: int) -> int:
	x = ((x & 0b01000100_01000100_01000100_01000100_01000100_01000100_01000100_01000100) >> 1 | x) \
			& 0b00110011_00110011_00110011_00110011_00110011_00110011_00110011_00110011

	x = ((x & 0b00110000_00110000_00110000_00110000_00110000_00110000_00110000_00110000) >> 2 | x) \
			& 0b00001111_00001111_00001111_00001111_00001111_00001111_00001111_00001111
			
	x = ((x & 0b00001111_00000000_00001111_00000000_00001111_00000000_00001111_00000000) >> 4 | x) \
			& 0b00000000_11111111_00000000_11111111_00000000_11111111_00000000_11111111
			
	x = ((x & 0b00000000_11111111_00000000_00000000_00000000_11111111_00000000_00000000) >> 8 | x) \
			& 0b00000000_00000000_11111111_11111111_00000000_00000000_11111111_11111111

	x = ((x & 0b00000000_00000000_11111111_11111111_00000000_00000000_00000000_00000000) >> 16 | x) \
			& 0b00000000_00000000_00000000_00000000_11111111_11111111_11111111_11111111
	
	return x
	

static func automated_test():
	var no_error = true
	for i in range(0, 32):
		var value = 1 << i
		var encode_value = encode64(value, 0)
		var expected_value = 1 << (i*2)
		var decode_value = Morton2.x(decode64(expected_value))
		#print("Value:\t%s\nEncode:\t%s\nExpect:\t%s\nDecode:\t%s\n" % \
		#		[int_to_bin(value, 64),
		#		int_to_bin(encode_value, 64),
		#		int_to_bin(expected_value, 64),
		#		int_to_bin(decode_value, 64)])
				
		if encode_value != expected_value:
			no_error = false
			printerr("Encoding %d got %d but expected %d!" % [value, encode_value, expected_value])
			printerr("Value:\t'%s'\nEncoded:\t%s\nExpected:\t%s" \
					% [int_to_bin(value, 32),\
						int_to_bin(expected_value, 32),\
						int_to_bin(encode_value, 32)])
		
		if decode_value != value:
			no_error = false
			printerr("Decoding %d got %d but expected %d!" % [expected_value, decode_value, value])
			printerr("Value:\t%s\nDecoded:\t%s\nExpected:\t%s" \
					% [int_to_bin(expected_value, 32),\
						int_to_bin(decode_value, 32),\
						int_to_bin(value, 32)])
						
	if no_error:
		print("All Morton2 tests passed.")
		
const _INTERPOSITION = 0b01010101_01010101_01010101_01010101_01010101_01010101_01010101_01010101
const _X_MASK = _INTERPOSITION
