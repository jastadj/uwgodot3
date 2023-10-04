extends Control
			
var palettes = []
var aux_palettes = []

signal palettes_generated

func _ready():
	palettes = $palettes.palettes
	$aux_palettes.set_palettes(palettes)
	aux_palettes = $aux_palettes.aux_palettes
	$images.set_palettes(palettes, aux_palettes)
	
