extends Control
var count = 0
var default_path
var default_filename
var path
var file
var tape
var last_time
var current_time
var date_time_hover = false


func _ready():
	default_path = OS.get_environment("HOME") + "/Documents/"
	default_filename = "tickertape.txt"
	path = default_path + default_filename
	
	if FileAccess.file_exists(path):
		file = FileAccess.open(path, FileAccess.READ)
		tape = file.get_as_text(true).split("\n")
		if tape[tape.size() -2].split(", ")[0] == "CLEAR":
			%last_what.text = "Last cleared on:"
			%date_time.text = tape[tape.size() -2].split(", ")[1]
		else:
			count = int(tape[tape.size() -2].split(", ")[0])
			%amount.text = tape[tape.size() -2].split(", ")[1]
			%what.text = tape[tape.size() -2].split(", ")[2]
			%last_what.text = tape[tape.size() -2].split(", ")[1] + tape[tape.size() -2].split(", ")[2]
			%date_time.text = tape[tape.size() -2].split(", ")[3]
			%ticker.text = str(count)

	file = null


func _process(_delta):	
	if last_time != null and date_time_hover != true:
		current_time = Time.get_datetime_dict_from_system()
		var seconds
		var minutes
		var hours
		var last_total_time = last_time['second'] + (last_time['minute'] * 60) + (last_time['hour'] * 3600)
		var current_total_time = current_time['second'] + (current_time['minute'] * 60) + (current_time['hour'] * 3600)
		var time_elapsed
				
		if current_total_time > last_total_time:
			time_elapsed = current_total_time - last_total_time
		else:
			time_elapsed = last_total_time - current_total_time
			
		hours = int(time_elapsed / 3600)
		minutes = int((time_elapsed % 3600) / 60)
		seconds = int(time_elapsed % 60)
			
		%date_time.text = 'Pressed ' + "%02d:%02d:%02d" % [hours, minutes, seconds] + ' ago.'
		
	elif last_time != null:
		var hours = last_time['hour']
		var minutes = last_time['minute']
		var seconds = last_time['second']
		var time = "%02d:%02d:%02d" % [hours, minutes, seconds]
		var date_time = str(last_time['day']) + '-' + str(last_time['month']) + '-' + str(last_time['year']) + ' ' + time
		
		%date_time.text = date_time


func tick(entry_text):
	path = default_path + default_filename
	last_time = Time.get_datetime_dict_from_system()
	var hours = last_time['hour']
	var minutes = last_time['minute']
	var seconds = last_time['second']
	var time = "%02d:%02d:%02d" % [hours, minutes, seconds]
	var date_time = str(last_time['day']) + '-' + str(last_time['month']) + '-' + str(last_time['year']) + ' ' + time
	
	file = null
	var output = entry_text + ", " + date_time
	
	if FileAccess.file_exists(path):
		file = FileAccess.open(path, FileAccess.READ_WRITE)
		file.seek_end()
	else:
		file = FileAccess.open(path, FileAccess.WRITE)

	file.store_line(output)

	file.close()
	
	%last_what.text = %amount.text + %what.text
	%date_time.text = date_time


func _on_amount_text_changed():
	var old_amount = %amount.text
	var parsed = old_amount.to_int()
	if parsed != null:
		%amount.text = str(parsed)
	else:
		%amount.text = old_amount
	%amount.set_caret_column(%amount.text.length())


func _on_punch_pressed():
	count += 1
	%ticker.text = str(count)
	tick(str(count) + ", " + %amount.text + ", " + %what.text)


func _on_clear_pressed():
	count = 0
	%ticker.text = str(count)
	tick("CLEAR")
	%amount.text = ""
	%what.text = ""
	%last_what.text = "Last cleared on:"
	last_time = null


func _on_date_time_mouse_entered():
	date_time_hover = true


func _on_date_time_mouse_exited():
	date_time_hover = false
