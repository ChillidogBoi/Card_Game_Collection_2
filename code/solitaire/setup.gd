extends Node


@export var StartStacks: Array[Stack]
@export var Deck: Stack


func _ready():
	for c in get_children():
		Deck.cards.append(c)
	Deck.shuffle()
	
	for x:int in StartStacks.size():
		for y:int in x:
			StartStacks[x].cards.append(Deck.cards.pop_back())
		StartStacks[x].cards.append(Deck.cards.pop_back())
		StartStacks[x].cards.back().Flipped = false
		StartStacks[x].cards.back().gen()
		StartStacks[x].gen()
	
	Deck.gen()
