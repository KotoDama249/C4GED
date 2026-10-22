extends Node

# Master database of all 19 secrets: ID -> { "name": String, "category": String, "discovered": bool }
var secret_database: Dictionary = {
	# --- UI SECRETS (1 - 5) ---
	1: { "name": "Cheater", "category": "UI", "discovered": false },
	2: { "name": "Default", "category": "UI", "discovered": false },
	3: { "name": "Prisoner", "category": "UI", "discovered": false },
	4: { "name": "Skulduggery", "category": "UI", "discovered": false },
	5: { "name": "Ivory Wraith", "category": "UI", "discovered": false },

	# --- IN-CAMERA SECRETS (6 - 18) ---
	6: { "name": "Umbrella Man", "category": "In-Cam", "discovered": false },
	7: { "name": "Irisu", "category": "In-Cam", "discovered": false },
	8: { "name": "KAngel", "category": "In-Cam", "discovered": false },
	9: { "name": "Koume", "category": "In-Cam", "discovered": false },
	10: { "name": "Bad Gal", "category": "In-Cam", "discovered": false },
	11: { "name": "Akisa", "category": "In-Cam", "discovered": false },
	12: { "name": "Little Sister", "category": "In-Cam", "discovered": false },
	13: { "name": "Shy Gal", "category": "In-Cam", "discovered": false },
	# (Reserved IDs 14-18 for future in-cam secrets if you expand past 8)
	14: { "name": "Placeholder 14", "category": "In-Cam", "discovered": false },
	15: { "name": "Placeholder 15", "category": "In-Cam", "discovered": false },
	16: { "name": "Placeholder 16", "category": "In-Cam", "discovered": false },
	17: { "name": "Placeholder 17", "category": "In-Cam", "discovered": false },
	18: { "name": "Placeholder 18", "category": "In-Cam", "discovered": false },

	# --- OFFICE SECRET (19) ---
	19: { "name": "Medusa (Fate)", "category": "Office", "discovered": false }
}

func roll_secret_chance() -> bool:
	# TEMPORARY FOR TESTING: Force success every time
	return true
	
func unlock_secret(id: int) -> bool:
	if secret_database.has(id):
		if not secret_database[id]["discovered"]:
			secret_database[id]["discovered"] = true
			print("Secret #", id, " [", secret_database[id]["name"], "] unlocked!")
			return true
	return false

func is_discovered(id: int) -> bool:
	return secret_database.get(id, {}).get("discovered", false)
