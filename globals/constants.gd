extends Node

# visual constants, 1 pixel = 10000 km
const SUN_PX:float = 69.57
const AU_PX:float = 14959.78707

# other astronomical constants
const AU_KM:float = 149597870.7
const SUN_KM:float = 695700

const EARTH_KM:float = 6378.14
const JUPITER_KM:float = 71492

# Starpasta constants
const SP_MS_0:int = 0
const SP_MS_1:int = 1
const SP_HERTZSPRUNG_GAP:int = 2
const SP_FIRST_GIANT_BRANCH:int = 3
const SP_CORE_He_BURNING:int = 4
const SP_EARLY_AGB:int = 5
const SP_TP_AGB:int = 6
const SP_NAKED_He_STAR_MS:int = 7
const SP_NAKED_He_STAR_HG:int = 8
const SP_NAKED_He_STAR_GB:int = 9
const SP_He_WD:int = 10
const SP_CO_WD:int = 11
const SP_ONe_WD:int = 12
const SP_NEUTRON_STAR:int = 13
const SP_BLACK_HOLE:int = 14
const SP_MASSLESS_REMNANT:int = 15

# MIST stages (EEP)
# i'll count Wolf-Rayet stars as non-main sequence
const MIST_PMS:int = -1
const MIST_MS:int = 0
const MIST_RGB:int = 2
const MIST_CORE_He_BURNING:int = 3
const MIST_EARLY_AGB: int = 4
const MIST_TP_AGB:int = 5
const MIST_POST_AGB:int = 6
const MIST_WOLF_RAYET:int = 9


# Radius text constants
const UNIT_KM:int = 0
const UNIT_EARTH:int = 1
const UNIT_JUPITER:int = 2
const UNIT_SOL:int = 3
const UNIT_AU:int = 4

const UNITS_ARRAY:Array = [UNIT_KM, UNIT_EARTH, UNIT_JUPITER, UNIT_SOL, UNIT_AU]

const DYK:Array = [
	"R136a1 is one of the most massive stars known. Its mass at least 300 M☉.",
	"Mira (Omicron Ceti) is a star in the asymptotic giant branch. The Sun will reach this stage in 7-10 billion years.",
	"O-types and hydrogen-burning Wolf-Rayet stars are unlikely to have planets.",
	"An extremely metal-poor Sun-mass star has temperatures of an A-type star.",
	"J1407b is a brown dwarf with a protoplanetary disk.",
	"HD 100546 b is not 752 M♃, it is likely 3-25 M♃.",
	"The creator of this has never heard of AstroCat in five years :)"]
	
const HARDCODED_STAR_AGES:Dictionary = {
	"Sun": 4568.2,
	"Sol": 4568.2,
	"Tairu": 4420.14519234235,
	"Antaira": 4420.14519234235,
	"Mitria": 6470.67013609426,
	"Kerdo": 5121.76366400273,
	"Genor": 4333.55092447457,
	"Feria": 810.15894486118,
	"Argoth": 528.06912130613,
	"Berigea": 5.26706624964,
	"Orinesa": 1.237988292
}
