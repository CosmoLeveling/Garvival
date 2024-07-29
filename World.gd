extends Node3D

@export var chunkSize = 400
@export var terrain_height = 20
@export var view_distance = 4000
@export var viewer :Marker3D
@export var chunk_mesh_scene : PackedScene
var viewer_position = Vector2()
var terrain_chunks = {}
var chunksvisible=0
var last_visible_chunks = []

@export var noise:FastNoiseLite

func _ready():
	chunksvisible = roundi(view_distance/chunkSize)
	#set_wireframe()
	updateVisibleChunk()

func set_wireframe():
	RenderingServer.set_debug_generate_wireframes(true)
	get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
	
func _process(delta):
	viewer_position.x = viewer.global_position.x
	viewer_position.y = viewer.global_position.z
	updateVisibleChunk()
func updateVisibleChunk():
	for chunk in last_visible_chunks:
		chunk.setChunkVisibility(false)
	last_visible_chunks.clear()
	
	var currentX = roundi(viewer_position.x/chunkSize)
	var currentY = roundi(viewer_position.y/chunkSize)
	
	for yOffset in range(-chunksvisible,chunksvisible):
		for xOffset in range(-chunksvisible,chunksvisible):
			var view_chunk_coord = Vector2(currentX-xOffset,currentY-yOffset)
			if terrain_chunks.has(view_chunk_coord):
				terrain_chunks[view_chunk_coord].update_chunk(viewer_position,view_distance)
				if terrain_chunks[view_chunk_coord].update_lod(viewer_position):
					terrain_chunks[view_chunk_coord].gen_terrain(noise,view_chunk_coord,chunkSize,true)
				if terrain_chunks[view_chunk_coord].getChunkVisible():
					last_visible_chunks.append(terrain_chunks[view_chunk_coord])
			else:
				var chunk  :TerrainChunk= chunk_mesh_scene.instantiate()
				add_child(chunk)
				chunk.Terrain_Max_Height = terrain_height
				var pos = view_chunk_coord*chunkSize
				var world_position = Vector3(pos.x,0,pos.y)
				chunk.global_position = world_position
				chunk.gen_terrain(noise,view_chunk_coord,chunkSize,false)
				terrain_chunks[view_chunk_coord] = chunk
