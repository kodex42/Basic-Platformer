extends ResourcePreloader

# Preloads
var upgrades = [
	preload("res://BlackPowderUpgrade.tscn"),
	preload("res://BodyArmorUpgrade.tscn"),
	preload("res://RubberBulletsUpgrade.tscn"),
	preload("res://DupingBulletsUpgrade.tscn"),
	preload("res://ExplosiveBulletsUpgrade.tscn"),
	preload("res://GoodShoesUpgrade.tscn"),
	preload("res://AbrasivePersonalityUpgrade.tscn"),
	preload("res://BarrelCleanerUpgrade.tscn"),
	preload("res://ShrapnelRoundsUpgrade.tscn"),
	preload("res://ScopeUpgrade.tscn"),
	preload("res://ForcefulSpringsUpgrade.tscn"),
	preload("res://AnimeDVDUpgrade.tscn")
]

func spawn():
	return upgrades[randi() % upgrades.size()].instance()
