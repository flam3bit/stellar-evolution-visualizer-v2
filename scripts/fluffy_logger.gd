@abstract class_name FluffyLogger extends RefCounted

const FATAL = 0
const ERROR = 1
const WARNING = 2
const DEBUG = 3
const INFO = 4

const LOGTYPES = {
	0: "FATAL",
	1: "ERROR",
	2: "WARN",
	3: "DEBUG",
	4: "INFO"
}

const LOGCOLORS = {
	0: "red",
	1: "red",
	2: "gold",
	3: "blue",
	4: "green"
}

static func _logprints(type:int, ...varargs):
	var text = " ".join(varargs)
	var string = "[color={3}][{0} - {2}][/color] {1}".format([Time.get_time_string_from_system(), text, LOGTYPES[type], LOGCOLORS[type]])
	
	print_rich(string)
	if type == ERROR or type == FATAL:
		push_error(text)
	if type == WARNING:
		push_warning(text)
	
static func print_fatal(...args):
	var text = " ".join(args)
	_logprints(FATAL, text)
	
static func print_error(...args):
	var text = " ".join(args)
	_logprints(ERROR, text)

static func print_warn(...args):
	var text = " ".join(args)
	_logprints(WARNING, text)
	
static func debug_print(...args):
	var text = " ".join(args)
	_logprints(DEBUG, text)
	
static func print_info(...args):
	var text = " ".join(args)
	_logprints(INFO, text)
