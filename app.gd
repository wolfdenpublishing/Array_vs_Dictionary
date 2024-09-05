# Performance comparison using a Dictionary as an Array

extends Node

const ITEM_COUNT := 100_000_000
const ITEM_COUNT_DISPLAY := "100,000,000"

var start_time:int
var start_mem:int
var ordered:Array
var ordered_iter_time:int
var random:Array
var random_iter_time:int


func _ready() -> void:

	# pause the main loop (probably not necessary, but no reason not to)
	get_tree().paused = true
	
	# display processor and memory info
	print("%s %s Cores" % [OS.get_processor_name(), OS.get_processor_count()])
	var m := OS.get_memory_info()
	print("%s mb Physical Memory, %s mb Available, %s mb Free\n" % [m.physical / 1_000_000, m.available / 1_000_000, m.free / 1_000_000])

	# create two arrays of size ITEM_COUNT, one ordered, one randomized (for repeatable random ordering)
	ordered = range(ITEM_COUNT)
	random = ordered.duplicate()
	random.shuffle()
	
	test_begin("Iterate the ordered array")
	for i:int in ordered:
		pass
	ordered_iter_time = Time.get_ticks_usec() - start_time
	test_end()
	
	test_begin("Iterate the random array")
	for i:int in random:
		pass
	random_iter_time = Time.get_ticks_usec() - start_time
	test_end()
	
	test_begin("Array: add %s elements in order via append()" % [ITEM_COUNT_DISPLAY])
	var a1:Array[int]
	for i:int in ordered:
		a1.append(i)
	test_end(ordered_iter_time)
	a1.clear()
	
	test_begin("Array: add %s elements in order via [], preallocate with resize()" % [ITEM_COUNT_DISPLAY])
	var a2:Array[int]
	a2.resize(ITEM_COUNT)
	for i:int in ordered:
		a2[i] = i
	test_end(ordered_iter_time)
	a2.clear()
	
	test_begin("Array: add %s elements in random order, dynamically extend with resize()" % [ITEM_COUNT_DISPLAY])
	var a3:Array[int]
	for i:int in random:
		if a3.size() < i + 1:
			a3.resize(i + 1)
		a3[i] = i
	test_end(random_iter_time)
	a3.clear()
	
	test_begin("Array: add %s elements in random order, preallocate with resize()" % [ITEM_COUNT_DISPLAY])
	var a4:Array[int]
	a4.resize(ITEM_COUNT)
	for i:int in random:
		a4[i] = i
	test_end(random_iter_time)
	
	test_begin("Array: access all %s elements in order" % [ITEM_COUNT_DISPLAY])
	for i:int in ordered:
		var n := a4[i]
	test_end(ordered_iter_time)
	
	test_begin("Array: access all %s elements in random order" % [ITEM_COUNT_DISPLAY])
	for i:int in random:
		var n := a4[i]
	test_end(random_iter_time)
	
	test_begin("Dictionary: add %s elements in order" % [ITEM_COUNT_DISPLAY])
	var d1:Dictionary
	for i:int in ordered:
		d1[i] = i
	test_end(ordered_iter_time)
	
	test_begin("Dictionary: add %s elements in random order" % [ITEM_COUNT_DISPLAY])
	var d2:Dictionary
	for i:int in random:
		d2[i] = i
	test_end(random_iter_time)
	d2.clear()
	
	test_begin("Dictionary: access all %s elements in order" % [ITEM_COUNT_DISPLAY])
	for i:int in ordered:
		var n:int = d1[i]
	test_end(ordered_iter_time)
	
	test_begin("Dictionary: access all %s elements in random order" % [ITEM_COUNT_DISPLAY])
	for i:int in random:
		var n:int = d1[i]
	test_end(random_iter_time)


func test_begin(msg:String) -> void:
	print(msg)
	start_time = Time.get_ticks_usec()
	start_mem = OS.get_static_memory_usage()


func test_end(iter_time:int = 0) -> void:
	var time := (Time.get_ticks_usec() - start_time - iter_time) / 1_000_000.0
	var mem := (OS.get_static_memory_usage() - start_mem) / 1_000_000.0
	print("done: time = %s sec, mem = %s mb\n" % [time, mem])
