extends Menu

class_name TutorialMenu

@export var video: VideoStreamPlayer
@export var labels_container: VBoxContainer

var current_index: int = 1

var infos: Array[Infos]

func _ready() -> void:
	create_info()
	set_video_path(1, "res://Cenas/Menus/Tutorial/Videos/Movimentação-2025-11-29_22.25.48.ogv" )
	set_labels(1, [
		"No controle use o Analógico",
		"No teclado use W, A, S, D",
		"Para se movimentar"
	])
	
	create_info()
	set_video_path(2, "res://Cenas/Menus/Tutorial/Videos/Dash-2025-11-29_22.54.11.ogv" )
	set_labels(2, [
		"No controle Aperte RT/R2",
		"No teclado use Espaço",
		"Para executar um Dash"
	])
	
	

func set_active(mode: bool):
	super.set_active(mode)
	if mode:
		current_index = 1
		play(1)

func next():
	var i = current_index + 1
	if i > infos.size(): return
	play(i)

func back():
	var i = current_index - 1
	if i < 1: return
	play(i)
	
func exit() -> void:
	set_active(false)
	Globals.house.inital_menu.set_active(true)
	
func play(i: int):
	
	var info = get_info(i)
	if not info: return
	
	current_index = i
	
	video.stream = load(info.video_path)
	video.play()
	
	for child in labels_container.get_children():
		if is_instance_valid(child):
			labels_container.remove_child(child)
			child.queue_free()
			
	for text in info.labels_text:
		var label = Label.new()
		label.label_settings = load("res://Cenas/Menus/Tutorial/Label/Tutorial.tres")
		label.text = text
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		labels_container.add_child(label)
	
	
	
func create_info():
	var info = Infos.new()
	info.index = infos.size() + 1
	infos.append(info)
	
func get_info(i: int) -> Infos:
	return infos.get(i - 1) as Infos
	
func set_video_path(i: int, path: String):
	var info = get_info(i)
	
	if not info: return
	
	info.video_path = path
	
func set_labels(i: int, texts: Array[String]):
	var info = get_info(i)
	
	if not info: return
	
	info.labels_text = texts
	
class Infos:
	var index: int
	var video_path: String
	var labels_text: Array[String]
	
