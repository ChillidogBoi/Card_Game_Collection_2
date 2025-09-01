extends Node


var PlayerHeldCard: StaticBody3D = null
var AllCards: Array = []
var HighestCard: int: 
	get():
		HighestCard = -1000000
		for c in AllCards:
			if c.global_position.y >= HighestCard:
				HighestCard = c.global_position.y + 0.01
		return HighestCard
