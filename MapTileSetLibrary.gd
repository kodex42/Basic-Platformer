extends ResourcePreloader

# Enum
enum Biome {
	DIRTY_DEPTHS
}

# Nodes
onready var map = get_parent().get_node("Map")

# DIRTY DEPTHS
# Special rooms
var dirty_depths_special_rooms = [
	preload("res://MapTilesets/Dirty Depths/Special/Start.tscn"),
	preload("res://MapTilesets/Dirty Depths/Special/Boss.tscn"),
	preload("res://MapTilesets/Dirty Depths/Special/Shop.tscn"),
	preload("res://MapTilesets/Dirty Depths/Special/UpgradeRoom.tscn")
]
# Dead ends
var dirty_depths_map_1exit = [
	preload("res://MapTilesets/Dirty Depths/Normal/1exit/DDeadEnd.tscn"),
	preload("res://MapTilesets/Dirty Depths/Normal/1exit/DDeadEndDanger.tscn"),
	preload("res://MapTilesets/Dirty Depths/Normal/1exit/DDeadEndSecret.tscn"),
	preload("res://MapTilesets/Dirty Depths/Normal/1exit/LDeadEnd.tscn"),
	preload("res://MapTilesets/Dirty Depths/Normal/1exit/LDeadEndRisk.tscn"),
	preload("res://MapTilesets/Dirty Depths/Normal/1exit/RDeadEnd.tscn"),
	preload("res://MapTilesets/Dirty Depths/Normal/1exit/RDeadEndDanger.tscn"),
	preload("res://MapTilesets/Dirty Depths/Normal/1exit/UDeadEnd.tscn"),
	preload("res://MapTilesets/Dirty Depths/Normal/1exit/UDeadEndRisk.tscn")
]
# Two door rooms
var dirty_depths_map_2exit = [
	preload("res://MapTilesets/Dirty Depths/Normal/2exits/HCorridor.tscn"),
	preload("res://MapTilesets/Dirty Depths/Normal/2exits/HCorridorDanger.tscn"),
	preload("res://MapTilesets/Dirty Depths/Normal/2exits/HPedestal.tscn"),
	preload("res://MapTilesets/Dirty Depths/Normal/2exits/JTriangle.tscn"),
	preload("res://MapTilesets/Dirty Depths/Normal/2exits/JTriangleDanger.tscn"),
	preload("res://MapTilesets/Dirty Depths/Normal/2exits/LTriangle.tscn"),
	preload("res://MapTilesets/Dirty Depths/Normal/2exits/LTriangleDanger.tscn"),
	preload("res://MapTilesets/Dirty Depths/Normal/2exits/qCorner.tscn"),
	preload("res://MapTilesets/Dirty Depths/Normal/2exits/qCornerSecret.tscn"),
	preload("res://MapTilesets/Dirty Depths/Normal/2exits/rCorner.tscn"),
	preload("res://MapTilesets/Dirty Depths/Normal/2exits/rCornerCruel.tscn"),
	preload("res://MapTilesets/Dirty Depths/Normal/2exits/VCorridor.tscn"),
	preload("res://MapTilesets/Dirty Depths/Normal/2exits/VCorridorSecret.tscn")
]
# Three door rooms
var dirty_depths_map_3exit = [
	preload("res://MapTilesets/Dirty Depths/Normal/3exits/DCorridor.tscn"),
	preload("res://MapTilesets/Dirty Depths/Normal/3exits/DCorridorSecret.tscn"),
	preload("res://MapTilesets/Dirty Depths/Normal/3exits/DCorridorDanger.tscn"),
	preload("res://MapTilesets/Dirty Depths/Normal/3exits/LCorridor.tscn"),
	preload("res://MapTilesets/Dirty Depths/Normal/3exits/LCorridorRisk.tscn"),
	preload("res://MapTilesets/Dirty Depths/Normal/3exits/RCorridor.tscn"),
	preload("res://MapTilesets/Dirty Depths/Normal/3exits/RCorridorDanger.tscn"),
	preload("res://MapTilesets/Dirty Depths/Normal/3exits/UPlatforms.tscn"),
	preload("res://MapTilesets/Dirty Depths/Normal/3exits/UPlatformsDanger.tscn")
]
# Four door rooms
var dirty_depths_map_4exit = [
	preload("res://MapTilesets/Dirty Depths/Normal/4exits/PlusCorridor.tscn"),
	preload("res://MapTilesets/Dirty Depths/Normal/4exits/PlusCorridorRisk.tscn"),
	preload("res://MapTilesets/Dirty Depths/Normal/4exits/PlusCorridorSecret.tscn"),
	preload("res://MapTilesets/Dirty Depths/Normal/4exits/PlusCorridorDanger.tscn")
]

# Constants
const TILE_PIXEL_DIMENSION_X = 630
const TILE_PIXEL_DIMENSION_Y = 420

# State
var spawned_tiles = {}
var grid = []
var grid_size = Vector2()
var obstacle_placement_attempts = 0
var start = Vector2()
var shop = Vector2()
var upgrade = Vector2()
var boss = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	init_tile_sets(Biome.DIRTY_DEPTHS)

func init_tile_sets(biome):
	clear_vars()
	match biome:
		Biome.DIRTY_DEPTHS:
			grid_size = Vector2(5, 5)
			start = Vector2(0, 0)
			shop = Vector2(4, 0)
			upgrade = Vector2(0, 4)
			boss = Vector2(4, 4)
			obstacle_placement_attempts = 5
			pass
	if (grid_size != Vector2()):
		generate_grid()

func clear_vars():
	spawned_tiles.clear()
	grid.clear()
	grid_size = Vector2()

func generate_grid():
	# Seed random
	randomize()
	
	# Initialize grid
	var g_center = Vector2(floor(grid_size.x/2), floor(grid_size.y/2))
	var g = []
	for i in range(grid_size.x):
		g.append([])
		for j in range(grid_size.y):
			g[i].append([])
			g[i][j] = '.' # Assume each tile starts out unreachable
			
	# Initiate obstacle population loop
	var obstructed = false
	while (true):
		# Insert a random obstacle
		var coord = null
		while (true): # Generate random grid coordinate that isn't overlapping a special tile
			coord = Vector2(randi()%int(grid_size.x), randi()%int(grid_size.y))
			if (coord == start or coord == shop or coord == upgrade or coord == boss): # Try again if we picked a coord matching a special tile
				continue
			else: # Set an obstacle at the position of our random coordinate
				g[coord.x][coord.y] = '#'
				break
		
		# Run DFS from center of graph
		g = DFS(g, g_center)
		
		# Print
#		var rev = g.duplicate()
#		rev.invert()
#		print ("\n GRID ITERATION")
#		for row in rev:
#			print(row)
		
		# Check if all special rooms are reachable
		obstructed = g[start.x][start.y] != '+' or g[shop.x][shop.y] != '+' or g[upgrade.x][upgrade.y] != '+' or g[boss.x][boss.y] != '+'
		if (not obstructed):
			grid = g.duplicate(true)
		else: # Subtract an attempt and try again for possibly more obstacles
			obstacle_placement_attempts -= 1
			if (obstacle_placement_attempts == 0): # If no more attempts, end generation
				break
			else: # Revert attempt
				g[coord.x][coord.y] = '+'
				print("Attempts remaining: " + str(obstacle_placement_attempts))
	
	# Print
	var rev = grid.duplicate(true)
	rev.invert()
	print ("\n FINAL GRID")
	for row in rev:
		print(row)

# This is a standard implementation of Depth First Search, wherein a graph is traversed such that each traversable cell in the graph is visited
# This DFS will return a painted version of the grid where +'s indicate path cells, #'s indicate obstacles, and .'s indicate unreachable nodes
func DFS(g, v):
	# Reset paths on grid
	for i in range(grid_size.x):
		for j in range(grid_size.y):
			if (g[i][j] == '+'):
				g[i][j] = '.'
	var s = [] # Stack for vertices to be checked
	s.append(v)
	while (not s.empty()):
		var u = s.pop_front()
		if (g[u.x][u.y] == '.'): # Vertex u is unvisited and able to be visited
			g[u.x][u.y] = '+'
			 # Push neighbours of u to the stack
			if (u.x != grid_size.x-1):
				s.append(Vector2(u.x + 1, u.y))
			if (u.y != grid_size.y-1):
				s.append(Vector2(u.x, u.y + 1))
			if (u.x != 0):
				s.append(Vector2(u.x - 1, u.y))
			if (u.y != 0):
				s.append(Vector2(u.x, u.y - 1))
	return g

func get_nodes():
	var nodes = []
	# Make sure we have a generated map
	if (grid.size() > 0):
		for i in range(grid_size.x):
			for j in range(grid_size.y):
				if (grid[i][j] == '+'):
					var connections = compute_neighbour_connections(i, j)
					var num_exits = connections.count(true)
					if (Vector2(i, j) == start):
						connections[0] = true
						num_exits += 1
					elif (Vector2(i, j) == boss):
						connections[2] = true
						num_exits += 1
					elif (Vector2(i, j) == shop):
						connections[2] = true
						num_exits += 1
					elif (Vector2(i, j) == upgrade):
						connections[0] = true
						num_exits += 1
					var tile = null
					match num_exits:
						1:
							tile = compute_map_tiles_matching_connecitons(dirty_depths_map_1exit, connections)
						2:
							tile = compute_map_tiles_matching_connecitons(dirty_depths_map_2exit, connections)
						3:
							tile = compute_map_tiles_matching_connecitons(dirty_depths_map_3exit, connections)
						4:
							tile = compute_map_tiles_matching_connecitons(dirty_depths_map_4exit, connections)
					if (tile != null):
						tile.translate(Vector2(i * TILE_PIXEL_DIMENSION_X, -j * TILE_PIXEL_DIMENSION_Y))
						nodes.append(tile)
	# Compute special tiles
	var start_tile = dirty_depths_special_rooms[0].instance()
	var boss_tile = dirty_depths_special_rooms[1].instance()
	var shop_tile = dirty_depths_special_rooms[2].instance()
	var upgrade_room_tile = dirty_depths_special_rooms[3].instance()
	start_tile.translate(Vector2(-2 * TILE_PIXEL_DIMENSION_X, 0))
	boss_tile.translate(Vector2(grid_size.x * TILE_PIXEL_DIMENSION_X, -(grid_size.y-1) * TILE_PIXEL_DIMENSION_Y))
	shop_tile.translate(Vector2(grid_size.x * TILE_PIXEL_DIMENSION_X, 0))
	upgrade_room_tile.translate(Vector2(-1 * TILE_PIXEL_DIMENSION_X, -(grid_size.y-1) * TILE_PIXEL_DIMENSION_Y))
	nodes.append(start_tile)
	nodes.append(boss_tile)
	nodes.append(shop_tile)
	nodes.append(upgrade_room_tile)
	return nodes

func compute_neighbour_connections(i, j):
	var connections = [false, false, false, false]
	if (i != 0 and grid[i-1][j] == '+'):
		connections[0] = true # Has LEFT neighbour
	if (j != grid_size.y-1 and grid[i][j+1] == '+'):
		connections[1] = true # Has UP neighbour
	if (i != grid_size.x-1 and grid[i+1][j] == '+'):
		connections[2] = true # Has RIGHT neighbour
	if (j != 0 and grid[i][j-1] == '+'):
		connections[3] = true # Has DOWN neighbour
	return connections

func compute_map_tiles_matching_connecitons(tiles, connections):
	var arr = []
	# Get usable tiles
	for tile in tiles:
		var instance = tile.instance() # Need to instance to access export vars and functions
		if (instance.get_connections() == connections):
			arr.append(instance)
	# Choose a tile at random
	var tile = arr[randi()%arr.size()].duplicate()
	# Clean up spare instances
	for i in arr:
		i.free()
	# Return random tile instance
	return tile
