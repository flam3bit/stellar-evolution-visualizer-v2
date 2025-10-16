class_name Simulation extends Node

var age_sim_data:Array
var mass_sim_data:Array
var teff_sim_data:Array
var radius_sim_data:Array
var lum_sim_data:Array
var stage_sim_data:Array
var hz_sim_data:Array

var hz_in_data:Array
var hz_out_data:Array

var star:Star
var habitable_zone:HabitableZone

var cur_index:int = -90000
var init_diff:float
var frac:float
var multiplier:float = 1
var star_name:String

func reset():
	set_process(false)
	cur_index = -90000
	multiplier = 1
	init_diff = 0
	frac = 1
	#get_tree().reload_current_scene()

func _ready() -> void:
	
	set_process(false)
	pass
func _process(delta: float) -> void:
	advance_age(delta)
	advance_temp(delta)
	advance_radius(delta)
	advance_mass(delta)
	advance_luminosity(delta)
	
	advance_hz_in(delta)
	advance_hz_out(delta)
	
	if cur_index == age_sim_data.size() - 1:
		set_process(false)

# opens a CSV file
func load_sim_data(path_to_file:String):
	var pp = path_to_file.split("/")
	pp.reverse()
	star_name = pp[0]
	if path_to_file.ends_with(".stp"):
		var error = load_sim_data_starpasta(path_to_file)
		habitable_zone.star = star
		return error
	elif path_to_file.ends_with(".mist"):
		var error = load_sim_data_mist(path_to_file)
		habitable_zone.star = star
		return error
	else:
		FluffyLogger.print_error("Can't find file.")
		return Error.ERR_FILE_CANT_OPEN


func load_sim_data_starpasta(path_to_csv:String):
	var data_file = FileAccess.open(path_to_csv, FileAccess.READ)
	if FileAccess.get_open_error() != OK:
		FluffyLogger.print_error("Can't find or read '{0}'".format([path_to_csv]))
		return Error.ERR_FILE_CANT_READ
	else:
		FluffyLogger.print_info("Opened '{0}' successfully".format([path_to_csv]))
	FluffyLogger.print_info("Now reading '{0}'...".format([path_to_csv]))
	
	# Age: col. 3, idx. 2
	# Mass: col. 4, idx. 3
	# Teff: calculated using stefan-boltzmann law
	# radius: col. 8, idx. 7
	# luminosity: col. 7, idx. 6
	var age_array:Array
	var mass_array:Array
	var teff_array:Array
	var radius_array:Array
	var lum_array:Array
	var stage_array:Array
	var hz_array:Array
	
	while data_file.get_position() < data_file.get_length():
		var csv_array = data_file.get_csv_line()
		
		stage_array.append(int(csv_array[1]))
		age_array.append(float(csv_array[2]))
		mass_array.append(float(csv_array[3]))
		lum_array.append(float(csv_array[7]))
		radius_array.append(float(csv_array[8]))
	FluffyLogger.print_info("Finished reading '{0}'".format([path_to_csv]))
	
	age_sim_data = age_array
	mass_sim_data = mass_array
	radius_sim_data = radius_array
	lum_sim_data = lum_array
	stage_sim_data = stage_array
	
	FluffyLogger.print_info("Calculating temperature and habitable zone...")

	for idx in age_sim_data.size():
		var teff = Functions.calc_temp_from_radius_and_lum(radius_sim_data[idx], lum_sim_data[idx])
		teff_array.append(teff)
		
		var hz_bounds = Functions.find_habitable_zone(teff, lum_sim_data[idx])
		hz_array.append(hz_bounds)
	teff_sim_data = teff_array
	hz_sim_data = hz_array
	
	FluffyLogger.print_info("Removing differences less than 1e-5")
	
	var zero_indices:Array
	for age_val_idx in age_sim_data.size():
		@warning_ignore("shadowed_global_identifier", "unused_variable")
		var len = age_sim_data.size()
		var cur:float
		var prev:float
		
		if age_val_idx > 0:
			cur = age_sim_data[age_val_idx]
			prev = age_sim_data[age_val_idx- 1]
			
			#FluffyLogger.print_debug_2(cur - prev, age_val_idx, age_val_idx - 1)
			if cur - prev <= 1e-5:
				FluffyLogger.print_info(age_val_idx)
				zero_indices.append(age_val_idx)
	var all_data = [age_sim_data, stage_sim_data, mass_sim_data, radius_sim_data, lum_sim_data, teff_sim_data, hz_sim_data]
	
	for data in all_data:
		for remove_indices in zero_indices:
			data.remove_at(remove_indices)
	
	FluffyLogger.print_info("Applying data to star...")
	
	star.temperature = teff_sim_data[0]
	star.mass = mass_sim_data[0]
	star.radius = radius_sim_data[0]
	star.luminosity = lum_sim_data[0]
	
	multiplier = 1
	
	init_diff = (age_sim_data[1] - age_sim_data[0]) * multiplier

	FluffyLogger.print_info("initial difference: {0}".format([init_diff]))
	cur_index = 0
	split_hz(hz_sim_data)
	return Error.OK
	
func load_sim_data_mist(path_to_csv:String):
	var data_file = FileAccess.open(path_to_csv, FileAccess.READ)
	if FileAccess.get_open_error() != OK:
		FluffyLogger.print_error("Can't find or read '{0}'".format([path_to_csv]))
		return Error.ERR_FILE_CANT_READ
	else:
		FluffyLogger.print_info("Opened '{0}' successfully".format([path_to_csv]))
	FluffyLogger.print_info("Now reading '{0}'...".format([path_to_csv]))
	
	# Data to take: 
	# Age (which doesnt start at 0...) (col. 1) - 0
	# Star mass (col. 2) - 1
	# Take Teff and Radius, use the Stefan - Boltzmann law to get luminosity.
	# Effective temperature (which has been fixed from log) (col. 12) - 11
	# Radius (which has been fixed from log) (col. 14)
	# Structure of packed float (64bit i assume) arrays: [age, mass, teff, radius, lum]
	# Arrays will be larger than those of Starpasta's data (the data for the a sun-mass star with [Fe/H] = 0
	# reaches up to 1800 lines
	
	var age_array:Array
	var mass_array:Array
	var teff_array:Array
	var radius_array:Array
	var lum_array:Array
	var stage_array:Array
	var hz_array:Array
	
	while data_file.get_position() < data_file.get_length():
		var csv_array = data_file.get_csv_line()
		age_array.append(float(csv_array[0]) / 1_000_000) # divide the year by a million
		mass_array.append(float(csv_array[1]))
		var teff:float = float(csv_array[11])
		teff_array.append(teff)
		var radius:float = float(csv_array[13])
		radius_array.append(radius)
		var lum:float = Functions.calc_lum_from_radius_and_teff(radius, teff)
		lum_array.append(lum)
		stage_array.append(int(csv_array[76]))
		
	FluffyLogger.print_info("Finished reading '{0}'".format([path_to_csv]))
	age_sim_data = age_array
	mass_sim_data = mass_array
	teff_sim_data = teff_array
	radius_sim_data = radius_array
	lum_sim_data = lum_array
	stage_sim_data = stage_array
	
	FluffyLogger.print_info("Calculating habitable zone...")
	for i in range(0, age_sim_data.size()):
		var hz_b:Array = Functions.find_habitable_zone(teff_sim_data[i], lum_sim_data[i])
		hz_array.append(hz_b)
	hz_sim_data = hz_array
	FluffyLogger.print_info("Set data to simulation")
	
	star.temperature = teff_sim_data[0]
	star.mass = mass_sim_data[0]
	star.radius = radius_sim_data[0]
	star.luminosity = lum_sim_data[0]
	
	var msi = 0
	
	var diff_array:Array
	for age_val_idx in age_sim_data.size():
		var cur:float
		var prev:float
		if age_val_idx > 0:
			cur = age_sim_data[age_val_idx]
			prev = age_sim_data[age_val_idx - 1]
			
			diff_array.append([cur - prev, age_val_idx - 1, age_val_idx])
			
	diff_array.sort()
	diff_array.reverse()
	
	var first = diff_array[0]
	
	multiplier *= mass_sim_data[0]
	
	multiplier /= 5 * (mass_sim_data[0] / 2)
	multiplier *= 2
	
	init_diff = (age_sim_data[first[2]] - age_sim_data[first[1]]) * multiplier
	
	FluffyLogger.print_info("initial difference: {0}".format([init_diff]))
	cur_index = 0
	split_hz(hz_sim_data)
	return Error.OK

func split_hz(hz_array:Array):
	for hz:Array in hz_array:
		hz_in_data.append(hz[0])
		hz_out_data.append(hz[1])
	hz_array.clear()

func advance_age(delta:float):
	var prev_age = age_sim_data[cur_index]
	var next_age = prev_age
	var max_idx = age_sim_data.size() - 1
	
	if cur_index == max_idx  - 1:
		next_age = age_sim_data[max_idx]
	else:
		next_age = age_sim_data[cur_index + 1]
	
	var ydiff:float = (next_age - prev_age) * multiplier
	
	
	frac = init_diff / ydiff
	
	if ydiff == 0:
		frac = 1
	
	star.age += (ydiff * delta) * frac
	
	if star.age >= next_age:
		star.age = next_age
		
		if star.age >= age_sim_data[max_idx]:
			ydiff = 0
		else:
			cur_index += 1

func advance_temp(delta):
	var prev_temp = teff_sim_data[cur_index]
	var next_temp = teff_sim_data[cur_index + 1]
	var max_idx = age_sim_data.size() - 1
	
	if cur_index == max_idx - 1:
		next_temp = teff_sim_data[cur_index]
	else:
		next_temp = teff_sim_data[cur_index + 1]
		
	var diff:float = (next_temp - prev_temp) * multiplier
	
	star.temperature += (diff * delta) * frac
	
	if diff < 0:
		if star.temperature <= next_temp:
			star.temperature = next_temp
	else:
		if star.temperature >= next_temp:
			star.temperature = next_temp

func advance_radius(delta):
	var prev_radius = radius_sim_data[cur_index]
	var next_radius = prev_radius
	var max_idx = age_sim_data.size() - 1
	
	if cur_index == max_idx - 1:
		next_radius = radius_sim_data[max_idx]
	else:
		next_radius = radius_sim_data[cur_index + 1]
		
	var diff:float = (next_radius - prev_radius) * multiplier
	star.radius += (diff * delta) * frac
	
	if diff < 0:
		if star.radius <= next_radius:
			star.radius = next_radius
	else:
		if star.radius >= next_radius:
			star.radius = next_radius
			
func advance_mass(delta):
	var prev_mass = mass_sim_data[cur_index]
	var next_mass = prev_mass
	var max_idx = age_sim_data.size() - 1
	
	if cur_index == max_idx - 1:
		next_mass = mass_sim_data[max_idx]
	else:
		next_mass = mass_sim_data[cur_index + 1]
		
	var diff:float = (next_mass - prev_mass) * multiplier
	star.mass += (diff * delta) * frac
	
	
	if diff < 0:
		if star.mass <= next_mass:
			star.mass = next_mass
	else:
		if star.mass >= next_mass:
			star.mass = next_mass

func advance_luminosity(delta):
	var prev_lum = lum_sim_data[cur_index]
	var next_lum = prev_lum
	var max_idx = age_sim_data.size() - 1
	
	if cur_index == max_idx - 1:
		next_lum = lum_sim_data[max_idx]
	else:
		next_lum = lum_sim_data[cur_index + 1]
		
	var diff:float = (next_lum - prev_lum) * multiplier
	star.luminosity += (diff * delta) * frac
		
	if diff < 0:
		if star.luminosity <= next_lum:
			star.luminosity = next_lum
	else:
		if star.luminosity >= next_lum:
			star.luminosity = next_lum

func advance_hz_in(delta):
	var prev_in = hz_in_data[cur_index]
	var next_in = prev_in
	var max_idx = age_sim_data.size() - 1
	
	if cur_index == max_idx - 1:
		next_in = hz_in_data[max_idx]
	else:
		next_in = hz_in_data[cur_index + 1]
		
	var diff:float = (next_in - prev_in) * multiplier
	
	habitable_zone.in_bound += (diff * delta) * frac
	
	if diff < 0:
		if habitable_zone.in_bound <= next_in:
			habitable_zone.in_bound = next_in
	else:
		if habitable_zone.in_bound >= next_in:
			habitable_zone.in_bound = next_in

func advance_hz_out(delta):
	var prev_out = hz_out_data[cur_index]
	var next_out = prev_out
	var max_idx = age_sim_data.size() - 1
	
	if cur_index == max_idx - 1:
		next_out = hz_out_data[max_idx]
	else:
		next_out = hz_out_data[cur_index + 1]
		
	var diff:float = (next_out - prev_out) * multiplier
	
	habitable_zone.out_bound += (diff * delta) * frac
	
	if diff < 0:
		if habitable_zone.out_bound <= next_out:
			habitable_zone.out_bound = next_out
	else:
		if habitable_zone.out_bound >= next_out:
			habitable_zone.out_bound = next_out
			
