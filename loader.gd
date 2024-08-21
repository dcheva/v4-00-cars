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
	
	
func med(arr:Array):
	return sum(arr)/arr.size()
