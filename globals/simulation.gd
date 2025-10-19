extends Node

var age_sim_data:Array
var mass_sim_data:Array
var teff_sim_data:Array
var radius_sim_data:Array
var lum_sim_data:Array
var stage_sim_data:Array
var hz_sim_data:Array
var hz_in_data:Array
var hz_out_data:Array
var global_data:Array

var star:Star
var habitable_zone:HabitableZone
var main_node:VisualStuff

var cur_index:int = -90000
var init_diff:float
var frac:float
var multiplier:float = 1
var star_name:String
var mist:bool = true
var supernova:bool = true
var started:bool = false

func _ready() -> void:
	set_process(false)

func pause_sim(paused:bool):
	set_process(paused)

func reset_simulation():
	set_process(false)
	cur_index = -90000
	multiplier = 1
	init_diff = 0
	frac = 0
	for array in global_data:
		array.clear()

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
	star_name = pp[0].split(".")[0]
	
	if star_name == "SPData" or star_name == "MIST_EvolutionTrack":
		star_name = "[Unnamed Star]"
	
	main_node.set_star_name(star_name)
	if path_to_file.ends_with(".stp"):
		var error = load_sim_data_starpasta(path_to_file)
		habitable_zone.star = star
		mist = false
		
		if Options.skip_ms:
			FluffyLogger.print_info("Skipping main sequence ...")
			remove_ms()
		
		star.age = age_sim_data[0]
		star.temperature = teff_sim_data[0]
		star.mass = mass_sim_data[0]
		star.radius = radius_sim_data[0]
		star.luminosity = lum_sim_data[0]
		
		return error
	elif path_to_file.ends_with(".mist"):
		var error = load_sim_data_mist(path_to_file)
		habitable_zone.star = star
		mist = true
		
		if Options.skip_ms:
			FluffyLogger.print_info("Skipping main sequence ...")
			remove_ms()
			
		star.age = age_sim_data[0]
		star.temperature = teff_sim_data[0]
		star.mass = mass_sim_data[0]
		star.radius = radius_sim_data[0]
		star.luminosity = lum_sim_data[0]

		return error
	else:
		FluffyLogger.print_error("Can't find file.")
		return Error.ERR_FILE_CANT_OPEN

## Loads data from the Starpasta evolutionary "models" which are actually a set of formulae from a 2000 paper
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
		stage_array.append(float(csv_array[1]))
		age_array.append(float(csv_array[2]))
		mass_array.append(float(csv_array[3]))
		lum_array.append(float(csv_array[7]))
		radius_array.append(float(csv_array[8]))
	FluffyLogger.print_info("Finished reading '{0}'".format([path_to_csv]))
	
	age_sim_data = age_array
	mass_sim_data = mass_array
	radius_sim_data = radius_array
	lum_sim_data = lum_array
	stage_sim_data = stage_array.duplicate()
	
	stage_array.clear()
	
	#ugly hack to intify the floats
	for stage in stage_sim_data:
		stage_array.append(int(stage))
	
	stage_sim_data = stage_array
	
	FluffyLogger.print_info("Calculating temperature and habitable zone...")

	for idx in age_sim_data.size():
		var teff = Functions.calc_temp_from_radius_and_lum(radius_sim_data[idx], lum_sim_data[idx])
		teff_array.append(teff)
		
		var hz_b = Functions.find_habitable_zone(teff, lum_sim_data[idx])
		hz_in_data.append(hz_b[0])
		hz_out_data.append(hz_b[1])
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
			
			#FluffyLogger.debug_print(cur - prev, age_val_idx, age_val_idx - 1)
			if cur - prev <= 1e-5:
				FluffyLogger.print_info(age_val_idx)
				zero_indices.append(age_val_idx)
				
	
	global_data = [age_sim_data, stage_sim_data, mass_sim_data, radius_sim_data, lum_sim_data, teff_sim_data, hz_in_data, hz_out_data]
	
	for data in global_data:
		for remove_indices in zero_indices:
			data.remove_at(remove_indices)
	
	FluffyLogger.print_info("Applying data to star...")
	

	
	multiplier = 1
	
	init_diff = (age_sim_data[1] - age_sim_data[0]) * multiplier

	FluffyLogger.print_info("initial difference: {0}".format([init_diff]))
	cur_index = 0

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
		stage_array.append(float(csv_array[76]))
		
	FluffyLogger.print_info("Finished reading '{0}'".format([path_to_csv]))
	age_sim_data = age_array
	mass_sim_data = mass_array
	teff_sim_data = teff_array
	radius_sim_data = radius_array
	lum_sim_data = lum_array
	stage_sim_data = stage_array.duplicate()
	
	stage_array.clear()
	
	#ugly hack to intify the floats
	for stage in stage_sim_data:
		stage_array.append(int(stage))
	
	stage_sim_data = stage_array
	
	FluffyLogger.print_info("Calculating habitable zone...")
	for i in age_sim_data.size():
		var hz_b:Array = Functions.find_habitable_zone(teff_sim_data[i], lum_sim_data[i])
		hz_in_data.append(hz_b[0])
		hz_out_data.append(hz_b[1])
	FluffyLogger.print_info("Set data to simulation")
	
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
	
	init_diff -= 1 / mass_sim_data[0]
	
	FluffyLogger.print_info("initial difference: {0}".format([init_diff]))
	cur_index = 0

	global_data = [age_sim_data, stage_sim_data, mass_sim_data, radius_sim_data, lum_sim_data, teff_sim_data, hz_in_data, hz_out_data]
	
	return Error.OK

## Removes the main sequence from the data.
func remove_ms():
	var stop_ms_idx:int
	
	var age_skipms:Array
	var mass_skipms:Array
	var teff_skipms:Array
	var radius_skipms:Array
	var lum_skipms:Array
	var stage_skipms:Array
	var hz_in_skipms:Array
	var hz_out_skipms:Array
	
	var tmp_glb_data = [age_skipms, stage_skipms, mass_skipms, radius_skipms, lum_skipms, teff_skipms, hz_in_skipms, hz_out_skipms]
	
	# [age_sim_data, stage_sim_data, mass_sim_data, radius_sim_data, lum_sim_data, teff_sim_data, hz_in_data, hz_out_data]
	
	if mist:
		for stage_val_idx in stage_sim_data.size():
			if stage_sim_data[stage_val_idx] > Constants.MIST_MS:
				stop_ms_idx = stage_val_idx
				break
		for data_idx in global_data.size():
			var idx:int = -1
			for stat in global_data[data_idx]:
				idx += 1
				if idx >= stop_ms_idx:
					tmp_glb_data[data_idx].append(stat)
					
		age_sim_data = age_skipms
		stage_sim_data = stage_skipms
		mass_sim_data = mass_skipms
		radius_sim_data = radius_skipms
		lum_sim_data = lum_skipms
		teff_sim_data = teff_skipms
		hz_in_data = hz_in_skipms
		hz_out_data = hz_out_skipms
			
	else: # sp
		for stage_val_idx in stage_sim_data.size():
			if stage_sim_data[stage_val_idx] > Constants.SP_MS_1:
				stop_ms_idx = stage_val_idx
				break
		for data_idx in global_data.size():
			var idx:int = -1
			for stat in global_data[data_idx]:
				idx += 1
				if idx >= stop_ms_idx:
					tmp_glb_data[data_idx].append(stat)
					
		age_sim_data = age_skipms
		stage_sim_data = stage_skipms
		mass_sim_data = mass_skipms
		radius_sim_data = radius_skipms
		lum_sim_data = lum_skipms
		teff_sim_data = teff_skipms
		hz_in_data = hz_in_skipms
		hz_out_data = hz_out_skipms

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
	
	#if (mist and stage_sim_data[cur_index] == Constants.MIST_TP_AGB and star_has_tpagb):
	#	ydiff = tpagb_age_diff
	
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

	#if (mist and stage_sim_data[cur_index] == Constants.MIST_TP_AGB and star_has_tpagb):
	#	diff = tpagb_teff_diff

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

	#if (mist and stage_sim_data[cur_index] == Constants.MIST_TP_AGB and star_has_tpagb):
	#	diff = tpagb_radius_diff

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
	
	#if (mist and stage_sim_data[cur_index] == Constants.MIST_TP_AGB and star_has_tpagb):
	#	diff = tpagb_mass_diff
	
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
	
	#if (mist and stage_sim_data[cur_index] == Constants.MIST_TP_AGB and star_has_tpagb):
	#	diff = tpagb_lum_diff
	
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
	
	#if (mist and stage_sim_data[cur_index] == Constants.MIST_TP_AGB and star_has_tpagb):
	#	diff = tpagb_hz_in_diff

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
	
	#if (mist and stage_sim_data[cur_index] == Constants.MIST_TP_AGB and star_has_tpagb):
	#	diff = tpagb_hz_out_diff
		
	habitable_zone.out_bound += (diff * delta) * frac
	
	if diff < 0:
		if habitable_zone.out_bound <= next_out:
			habitable_zone.out_bound = next_out
	else:
		if habitable_zone.out_bound >= next_out:
			habitable_zone.out_bound = next_out

func has_stage(stage_val:int):
	var idx:int
	for stage_idx in stage_sim_data.size():
		if stage_sim_data[stage_idx] == stage_val:
			idx = stage_idx
			break
	# if the very first index of the stage is at the very last index of the entire array
	if idx == stage_sim_data.size() - 1:
		return false
	else:
		if stage_sim_data[idx] == stage_val:
			return true
		else:
			return false

func calc_difference_wtf(stage_val:int, data_array:Array):
	var idx:int
	for stage in stage_sim_data.size():
		if stage_sim_data[stage] == stage_val:
			idx = stage
			break

	if idx == data_array.size() - 1:
		return
	return data_array[idx + 1] - data_array[idx]
