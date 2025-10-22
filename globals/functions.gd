extends Node

# copid from starpasta + my rewrite

# https://iopscience.iop.org/article/10.1088/2041-8205/787/2/L29/meta
func _find_hz_bound(l, teff, ssol, c_a, c_b, c_c, c_d):
	var tstar = teff - 5780
	var Seff = ssol + (c_a * tstar) + (c_b * (tstar ** 2)) + (c_c * (tstar ** 3)) + (c_d * (tstar ** 4))
	var d = (l / Seff) ** 0.5	# square root?
	return d

func find_habitable_zone(temperature:float, luminosity:float, optimistic:bool=true):
	var l = luminosity
	var t = clamp(temperature, 2600, 7200)
	
	if optimistic:
		var in_bound = _find_hz_bound(l, t, 1.776, 2.136e-4, 2.533e-8, -1.332e-11, -3.097e-15)
		var out_bound = _find_hz_bound(l, t, 0.32, 5.547e-5, 1.526e-9, -2.874e-12, -5.011e-16)
		return [in_bound,out_bound]
	else: # conservative HZ
		var in_bound = _find_hz_bound(l, t, 1.107, 1.332e-4, 1.58e-8, -8.308e-12, -1.931e-15)
		var out_bound = _find_hz_bound(l, t, 0.356, 6.171e-5, 1.698e-9, -3.198e-12, -5.575e-16)
		return [in_bound,out_bound]

func log10(value:float):
	return log(value) / log(10)
	
func calc_lum_from_radius_and_teff(r:float, t:float):
	#conversion to meters
	r *= 695700000
	
	# Stefan-Boltzmann constant (in W / (m^2 * K^4))
	var σ:float = 5.67037442e-08
	
	var l:float = (4 * PI * (r ** 2)) * σ * (t ** 4)
	return l / 3.828e+26

func calc_temp_from_radius_and_lum(r:float, l:float):
	r *= 695700000.0
	l *= 3.828e+26
	var σ:float = 5.67037442e-08
	
	var teff:float = l / (4.0 * PI * (r ** 2) * σ)
	teff **= (1./4)
	return teff

func add_or_subtract_by_percentage(value:float, percentage:float):
	return value + (value * percentage)
