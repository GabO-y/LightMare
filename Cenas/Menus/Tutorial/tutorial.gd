extends Menu

class_name TutorialMenu

@export var video: VideoStreamPlayer
@export var labels_container: VBoxContainer
@export var button_next: Button
@export var titulo: Label
@export var imgs_cont: VBoxContainer

var current_index: int = 1

var infos: Array[Infos]

func _ready() -> void:

	create_info(
		["res://Cenas/Menus/Tutorial/Videos/Movimentação-2025-11-29_22.25.48.ogv"],		[
			"Movimentação do Player",
			"No controle use o Analógico 
			Esquerdo",
			"No teclado use W, A, S, D",
		]
	)
	
	create_info(
		["res://Cenas/Menus/Tutorial/Videos/Lig_Des_Arma-2025-11-30_13.28.17.ogv"],
		[
			"Ligar e desligar as Armas",
			"No controle, aperte X",
			"No Mouse, use o 
			botão Esquerdo"
		]
	)
	
	create_info(
		["res://Cenas/Menus/Tutorial/Videos/DirArmas-2025-11-30_13.36.43.ogv"],
		[
			"Direcionar a Arma",
			"No Controle use o Anaçógico Direito",
			"Com o Mouse, arraste-o",
		]
	)
	
	create_info(
		["res://Cenas/Menus/Tutorial/Videos/AtacarEne1-2025-11-30_14.04.03.ogv"],
		[
			"Atacar Inimigo 
			com Lanterna Ou Isquéiro",
			"Mantenha o inimigo dentro da Luz",
			"Após um tempo ele sofrerá um dano",
			"Mantenha a Luz 
			constantemente  
			nele para derrotá-lo"
		]
	)
	
	create_info(
		["res://Cenas/Menus/Tutorial/Videos/AtacarEne2-2025-11-30_14.14.34.ogv"],
		[
			"Ataque Inimigo com 
			o Pisca-Pisca",
			"Com o Controle, aperte RB/R1",
			"No Mouse, aperte o botão Direito",
			"Para dísparar",
			"O projétil irá grudar num inimigo
			e dar dano nele e quem estiver em
			volta quando passar um tempo"
		]
	)
	
	create_info(
		["res://Cenas/Menus/Tutorial/Videos/Dash-2025-11-29_22.54.11.ogv"],
		[
			"Execução de um Dash",
			"No controle Aperte RT/R2
			No teclado use Espaço",
			"Enquando o Player estiver
			no Dash, ele não pode tomar
			dano"
			
		]
	)
	
	create_info(
		["res://Cenas/Menus/Tutorial/Videos/Moedas-2025-11-30_18.00.41.ogv"],
		[
			"Moedas",
			"Quando um inimigo é derrotado
			 ele deixa uma moeda cair",
			"Há vários tipos de moedas
			> Amarela vale 1
			> Vermelha vale 5
			> Verde vale 10
			> Azul vale 20",
			"Use-as na Loja"
		]
	)

	create_info(
		[
			"res://Cenas/Menus/Tutorial/Imagens/Captura de tela de 2025-11-30 15-40-58.png", 
			"res://Cenas/Menus/Tutorial/Imagens/Captura de tela de 2025-11-30 15-43-58.png",
			"res://Cenas/Menus/Tutorial/Imagens/Captura de tela de 2025-11-30 17-43-33.png"
		],
		[
			"Loja",
			"Há sempre um ursinho no primeiro quarto",
			"No Controle, aperte X
			No Mouse, aperte o botão Esquerdo
			Para abrir a Loja",
			"Melhoria das Armas e
			Melhoria dos atributos
			São feitos na Loja
			Com moedas"
		], 
		false
	)

	
	

func set_active(mode: bool, principal: bool = true):
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
	
	video.visible = info.is_video
	imgs_cont.visible = not info.is_video
	
	if info.is_video:
		video.stream = load(info.video_path)
		video.play()
	else:
		for child in imgs_cont.get_children():
			if is_instance_valid(child):
				child.queue_free()	
				imgs_cont.remove_child(child)
				
		for img in info.imgs_path:
			var t = TextureRect.new()
			t.texture = load(img)
			t.expand_mode = TextureRect.EXPAND_KEEP_SIZE
			t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			imgs_cont.add_child(t)
	
	
	for child in labels_container.get_children():		
		if is_instance_valid(child):
			if child.name == "T1" or child.name == "T2":
				continue
				
			labels_container.remove_child(child)
			child.queue_free()
			
	var is_first: bool = true
			
	for text in info.labels_text:
		
		if is_first:
			is_first = false
			titulo.text = text
			continue
		
		var label = Label.new()
		label.label_settings = load("res://Cenas/Menus/Tutorial/Label/Tutorial.tres")
		label.text = text
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var painel = PanelContainer.new()
		painel.add_child(label)
		labels_container.add_child(painel)
			
	
func create_info(contents: Array[String], texts: Array[String], is_video: bool = true):
	
	var info = Infos.new() as Infos
	info.index = infos.size() + 1
	
	if is_video:
		info.video_path = contents.get(0)
	else:
		info.imgs_path = contents
	
	info.labels_text = texts
	
	info.is_video = is_video
	
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
	var imgs_path: Array[String]
	var is_video: bool
	
