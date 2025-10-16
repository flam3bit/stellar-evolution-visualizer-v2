class_name DebugOverlay extends CanvasLayer



func _process(_delta: float) -> void:
	update_node_count()
	update_obj_count()
	
func update_node_count():
	var node_count = $DebugLayer/NodeCount
	var nodes = Performance.OBJECT_NODE_COUNT
	
	node_count.text = "Nodes: {0}".format([nodes])

func update_obj_count():
	var obj_count = $DebugLayer/ObjCount
	var obj = Performance.OBJECT_COUNT
	obj_count.text = "Objects: {0}".format([obj])
