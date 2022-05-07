extends Node

var local_player = null
var local_player_color = null
var local_player_name = null

var credits = 0
var minerals = 0

# Spending functions


func init():
	credits = 500
	minerals = 500


func spend_credits(val):
	if credits >= val:
		credits -= val
		return true
	else:
		return false


func spend_minerals(val):
	if minerals >= val:
		minerals -= val
		return true
	else:
		return false


func can_spend_credits(val):
	if credits >= val:
		return true
	else:
		return false


func can_spend_minerals(val):
	if minerals >= val:
		return true
	else:
		return false
