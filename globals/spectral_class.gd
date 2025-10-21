extends Node

func _ready() -> void:
	var sc = calculate_spectral_class(5779)
	print(sc)

func calculate_spectral_class(temperature:float):
	if temperature >= 2320 and temperature < 3820:
		return "M" + calculate_spectral_number(temperature, 2320, 3820)
	elif temperature >= 3820 and temperature < 5220:
		return "K" + calculate_spectral_number(temperature, 3820, 5220)
	elif temperature >= 5220 and temperature < 6020:
		return "G" + calculate_spectral_number(temperature, 5220, 6020)
	elif temperature >= 6020 and temperature < 7520:
		return "F" + calculate_spectral_number(temperature, 6020, 7520)
	elif temperature >= 7520 and temperature < 10120:
		return "A" + calculate_spectral_number(temperature, 7520, 10120)
	elif temperature >= 10120 and temperature < 33120:
		return "B" + calculate_spectral_number(temperature, 10120, 33120)
	elif temperature >= 33120 and temperature < 52470:
		return "O" + calculate_spectral_number(temperature, 33120, 52470)
	elif temperature >= 52470:
		return "O0.0"
	else: # temperatures too cold
		return "Brown dwarf"
		
func calculate_spectral_number(temperature:float, lower:float, upper:float):
	var diff:float = (upper - lower) / 10
	var spec_number_array:Array = [upper]
	for i in 10:
		upper -= diff
		spec_number_array.append(upper)
	
	for idx in spec_number_array.size():
		if temperature >= spec_number_array[idx] and temperature < spec_number_array[idx - 1]:
			return str(idx - 1) + "." + calculate_subnumber(temperature, spec_number_array[idx - 1], spec_number_array[idx])

func calculate_subnumber(temperature:float, lower:float, upper:float):
	var diff:float = (upper - lower) / 10
	var spec_number_array:Array = [upper]
	for i in 10:
		upper -= diff
		spec_number_array.append(upper)
		
	spec_number_array.reverse()
	
	for idx in spec_number_array.size():
		if temperature >= spec_number_array[idx] and temperature < spec_number_array[idx - 1]:
			return str(idx - 1)
