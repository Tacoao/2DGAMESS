extends CanvasItem


# Called when the node enters the scene tree for the first time.
var piece_lenght := 4.0
var RopePiece = preload("res://RopePiece.tscn")
var rope_parts := []
var rope_close_tolerance := 4.0
@onready var rope_start_piece = $RopeStartPiece
@onready var rope_end_piece = $RopeEndPiece
@onready var rope_start_joint = $RopeStartPiece/C/J
@onready var rope_end_joint = $RopeEndPiece/C/J

	
	
func spawn_rope(start_pos:Vector2, end_pos:Vector2):
	rope_start_piece.global_position = start_pos
	rope_end_piece.global_position = end_pos
	start_pos = rope_start_piece.get_node("C/J").global_position
	end_pos = rope_end_piece.get_node("C/J").global_position
	var distance = start_pos.distance_to(end_pos)
	var segment_amount = round(distance/piece_lenght)
	for i in segment_amount:
		print(i)
	var spawn_angle = (end_pos-start_pos).angle() - PI/2
	create_rope(segment_amount,rope_start_piece,end_pos,spawn_angle)
	
func create_rope(piece_amount:int,parent:Object,end_pos:Vector2, spawn_angle:float)->void:
	for i in piece_amount:
		parent = add_piece(parent,i,spawn_angle)
		parent.set_name("rope_piece"+str(i))
		rope_parts.append(parent)
		var joint_pos = parent.get_node("C/J").global_position
		if joint_pos.distance_to(end_pos) < rope_close_tolerance:
			break
	rope_end_piece.get_node("C/J").node_a = rope_end_piece.get_path()
	rope_end_piece.get_node("C/J").node_b = rope_parts[-1].get_path()
	
func add_piece(parent:Object, id:int,spawn_angle:float) -> Object:
	var joint : PinJoint2D = parent.get_node("C/J") as PinJoint2D
	var piece : Object = RopePiece.instantiate() as Object
	piece.global_position = joint.global_position
	piece.rotation = spawn_angle
	piece.parent = self
	piece.id = id
	add_child(piece)
	joint.node_a = parent.get_path()
	joint.node_b = piece.get_path()
	return piece
func retirer_piece(count: int) -> void:
	for i in count:
		if rope_parts.size() > 0:
			var last_piece = rope_parts.pop_back()
			last_piece.queue_free()

func update_rope_position(position: Vector2) -> void:
	var start_pos = rope_start_piece.global_position
	var end_pos = rope_end_piece.global_position
	rope_start_piece.global_position = position
	var distance = start_pos.distance_to(end_pos)
	var new_distance = start_pos.distance_to(position)
	var new_piece_amount = round(new_distance / piece_lenght)
	if new_piece_amount > rope_parts.size():
		var additional_pieces = new_piece_amount - rope_parts.size()
		
		for i in additional_pieces+10:
			add_piece(rope_parts[-1], rope_parts.size() + i, 0)
	elif new_piece_amount < rope_parts.size():
		var pieces_to_remove = rope_parts.size() - new_piece_amount 
		retirer_piece(pieces_to_remove)
	


	
