extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Mobile performance monitoring
	print("VRAM Usage: ", Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED))
	print("Mobile Platform: ", OS.get_name())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
