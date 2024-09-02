extends ResourcePreloader


# Math
func get_byte(num: int, pos: int):
	for i in range (1, pos):
		num = num % 10
	return posmod(num, 10)


func sum(arr:Array):
	var result = 0
	for i in arr:
		result+=i
	return result
	
	
func med(arr:Array) -> float:
	return sum(arr)/arr.size()


func div(a, b) -> float:
	a = float(a)
	b = float(b)
	if b!=0: return a/b
	else: return 0
	
	
func half_chunk(chunk_size: int) -> int:
	return int(float(chunk_size)/2)


func quarter_chunk(chunk_size: int) -> int:
	return int(float(chunk_size)/4)
	

func positive(i) -> int:
	if i < 0: return -1
	else: return 1
