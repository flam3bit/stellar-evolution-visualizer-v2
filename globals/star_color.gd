extends Node

# Based on https://tannerhelland.com/2012/09/18/convert-temperature-rgb-algorithm-code.html

# Another color temperature function but in GDScript!!!!!!

## Takes temperature in K, returns color.
## Algorithm a GDScript translation of the algorithm: https://tannerhelland.com/2012/09/18/convert-temperature-rgb-algorithm-code.html
func convert_k_to_rgb(temperature:float):

	# doesn't support temperatures under 1000 or above 40000
	# but let's see with a copy of this function
	
	#temperature = clamp(temperature, 1000, 40000)

	# setting up the color variables
	var r:float = 0
	var g:float = 0
	var b:float = 0
	
	var calc_temp:float = temperature / 100.0
	
	# calculating r
	if calc_temp <= 66:
		r = 255
	else:
		r = calc_temp - 60
		r = 329.698727446 * (r ** -0.1332047592)
		r = clamp(r, 0, 255)
			
	# calculating g
	if calc_temp <= 66:
		g = calc_temp
		g = (99.4708025861 * log(g)) - 161.1195681611
		g = clamp(g ,0 ,255)
	else:
		g = calc_temp - 60
		g = 288.1221695283 * (g ** -0.0755148492)
		g = clamp(g, 0, 255)
	
	# calculating b
	if calc_temp >= 66:
		b = 255
	else:
		if calc_temp <= 19:
			b = 0
		else:
			b = calc_temp - 10
			b = 138.5177312231 * log(b) - 305.0447927307
			b = clamp(b, 0, 255)
	
	return Color(r / 255, g / 255, b / 255)
