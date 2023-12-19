extends Control

@onready var player = $".."

func _process(delta):
	set_value(player.hunger)
	$Panel/RichTextLabel.text = "[center] %s%% [/center]" % snapped(player.hunger, 0)

func set_value(hunger):
	if hunger <= 0:
		$Panel/TextureProgressBar.set_tint_progress(Color.DARK_RED)
	elif hunger <= 25:
		$Panel/TextureProgressBar.set_tint_progress(Color.DARK_RED)
	elif hunger <= 50:
		$Panel/TextureProgressBar.set_tint_progress(Color.DARK_GOLDENROD)
	elif hunger <= 75:
		$Panel/TextureProgressBar.set_tint_progress(Color.OLIVE)
	elif hunger > 75:
		$Panel/TextureProgressBar.set_tint_progress(Color.DARK_OLIVE_GREEN)
	$Panel/TextureProgressBar.value = hunger


