extends CanvasLayer

func _ready():
	Global.ui = self
	
	# UI setup
	$Menu_start.visible = true
	$HUD.visible = false
	$Menu_gameOver.visible = false;

func _physics_process(delta):
	pass

func _on_btn_start_pressed():
	Global.game.game_start()
	$Menu_start.visible = false
	$HUD.visible = true

func _on_btn_restart_pressed():
	$Menu_gameOver.visible = false
	$Menu_start.visible = true
	control_score("set", 0)

func control_score(action, value=0):
	var score = int($HUD/Label_score.text.split(":")[1].strip_edges())
	
	match (action):
		("get"):
			return score
		("set"):
			score = value
		("add"):
			score += value
		("minus"):
			score -= value
	score = max(score, 0)
	$HUD/Label_score.text = "Score: %s" % score
	return 0

func show_result():
	var score = control_score("get")
	var score_highest = Global.control_db("get", "Player", "Score")
	if (score > score_highest): 
		score_highest = score
		Global.control_db("set", "Player", "Score", score)
	
	var node = find_child("VBoxContainer", true, false)
	node.get_node("Label_score").text = "Score: " + str(score)
	node.get_node("Label_highestScore").text = "Highest Score: " + str(score_highest)
