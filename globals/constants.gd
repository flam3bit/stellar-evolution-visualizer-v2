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
const MSU07:int = 0
const MSO07:int = 1
const HERTZSPRUNG_GAP:int = 2
const FIRST_GIANT_BRANCH:int = 3
const CORE_He_BURNING:int = 4
const EARLY_AGB:int = 5
const TP_AGB:int = 6
const NAKED_He_STAR_MS:int = 7
const NAKED_He_STAR_HG:int = 8
const NAKED_He_STAR_GB:int = 9
const He_WD:int = 10
const CO_WD:int = 11
const ONe_WD:int = 12
const NEUTRON_STAR:int = 13
const BLACK_HOLE:int = 14
const MASSLESS_REMNANT:int = 15

# Radius text constants
const UNIT_KM:int = 0
const UNIT_EARTH:int = 1
const UNIT_JUPITER:int = 2
const UNIT_SOL:int = 3
const UNIT_AU:int = 4

const UNITS_ARRAY:Array = [UNIT_KM, UNIT_EARTH, UNIT_JUPITER, UNIT_SOL, UNIT_AU]
