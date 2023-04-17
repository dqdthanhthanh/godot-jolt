extends Node2D

## Chuyen thanh string
# '%s' %

## Constants
# PI so pi = 3,14...
# TAU so tau = pi*2
# INF duong vo cung neu -INF thi la am vo cung (float)
# NAN NAN = nan --- "Not a Number", an invalid floating-point value.

## Color
# Color8 ( int r8, int g8, int b8, int a8=255 )
# ColorN ( String name, float alpha=1.0 )

## Tinh goc
# deg_to_rad ( float deg ) doi do ve radian
# rad_to_deg(s) doi radian ve do
# abs ( float s ) gia tri tuyet doi
# acos ( float s ) tinh theo radian
# asin ( float s ) tinh theo radian
# atan ( float s )
# atan2 ( float y, float x )
# cos ( float s ) tra ve cosin cua goc tinh bang radian
# cosh ( float s )
# sin ( float s )
# sinh ( float s )
# tan ( float s )
# tanh ( float s )

## Debug
# print() in thong tin nen man hinh debug. Nen dung push_error va push_warning de thong bao loi
# print_debug () giong print(). Chi dung trong debug mode
# print_stack ( ) in thong vi ve vi tri code
# printerr() giong print(). Hien dong thong bao mau do
# printraw() in nhung cung mot dong
# prints() in ra nhieu bien va tu cach nhau = 1 dau cach. prints("A", "B", "C") # Prints A B C
# printt() in ra nhieu bien va tu cach nhau = 1 dau tab. printt("A", "B", "C") # Prints A       B       C
# push_error ( String message ) dua thong bao loi den conso le vaf ca thiet bi. Cach nay se khong dung han chuong trinh. Nen dung assert(false) #,"test error")
# push_warning ( String message ) dua canh bao den conso le vaf ca thiet bi. Cach nay se khong dung han chuong trinh.
# Array get_stack ( ) kiem tra vi tri goi den tu ham nao, script nao
# assert ( bool condition, String message="" ) kiem tra debug
# instance_from_id ( int instance_id ) kiem tra doi tuong tuong ung voi instance_id

## So sanh, kiem tra
# is_inf ( float s ) true neu s la vo cung
# is_zero_approx ( float s ) true neu gan bang 0. nhanh hon is_equal_approx()
# is_equal_approx ( float a, float b ) true neu a va b gan bang nhau(4 so sau dau cham dong)
# is_instance_valid ( Object instance ) Returns whether instance is a valid object (e.g. has not been deleted from memory).
# is_nan ( float s ) Returns whether s is a NaN ("Not a Number" or invalid) value.

## Dac biet
# yield ( Object object=null, String signal="" ) Giup tao thoi gian cho giua cac ham, dong code.
# Stops the function execution and returns the current suspended state to the calling function.
#func _ready():
#	await countdown().completed # waiting for the countdown() function to complete
#	print('Ready')
#
#func countdown():
#	await get_tree().idle_frame # returns a GDScriptFunctionState object to _ready()
#	print(3)
#	await get_tree().create_timer(1.0).timeout
#	print(2)
#	await get_tree().create_timer(1.0).timeout
#	print(1)
#	await get_tree().create_timer(1.0).timeout

# Resource preload ( String path ) load san duong dan cua du lieu nao do. var bar_red = preload("res://Assets2D/UI/bar_red.png")
# Instance a scene. var diamond = preload("res://diamond.tscn").instantiate()
# If you want to load a resource from a dynamic/variable path, use load.
# Resource load ( String path ) load duong dan cua du lieu nao do. De tranh cham tre nen luu tren bien hoac dung preload
# funcref ( Object instance, String funcname ) use funcref to store a func in a variable and call it later (dung call_func()).

## JSON
# parse_json ( String json ) Parse JSON text to a Variant.
# JSON.new().stringify ( Variant var ) Converts a Variant var to JSON text and return the result
# validate_json ( String json ) Checks that json is valid JSON data.

## Convert
# type_exists ( String type ) true neu class có ton tai
# typeof ( Variant what ) tra ve kieu du lieu
# str() chuyen gia tri thanh chuoi.
# var_to_str ( Variant var ) Converts a Variant var to a formatted string that can later be parsed using str_to_var.
# str_to_var ( String string ) Converts a formatted string that was returned by var_to_str to the original value.
# convert ( Variant what, int type ) chuyen doi nhanh dang du lieu. a = convert(a, TYPE_STRING)
# The type parameter uses the Variant.Type values.
# deg_to_rad ( float deg ) doi do ve radian
# rad_to_deg(s) doi radian ve do
# cartesian2polar ( float x, float y ) chuyen doi he truc toa do
# polar2cartesian ( float r, float th ) chuyen doi he truc toa do
# linear_to_db ( float nrg ) lien quan den am thanh
# db_to_linear ( float db ) lien quan den am thanh
# inst_to_dict ( Object inst ) lien quan den tu dien
# dict_to_inst ( Dictionary dict ) lien quan den tu dien
# bytes_to_var ( PackedByteArray bytes, bool allow_objects=false ) giai ma byte
# weakref ( Object obj ) Returns a weak reference to an object.

# var_to_bytes ( Variant var, bool full_objects=false ) Encodes a variable value to a byte array.
#	var a = var_to_bytes(12000)
#	for i in a:
#		print(str(i))

# char ( int code ) tra ky tu voi ma Unicode, tuong thich voi ASCII. Nguoc vs ord
# int hash ( Variant var ) dia chi luu du lieu. print(hash("a")) # Prints 177670

## Tinh toan
# range() Returns an array with the given range. 
# Range can be 1 argument N (0 to N-1), two arguments (initial, final-1) or three arguments (initial, final-1, increment).

# remap ( float value, float istart, float istop, float ostart, float ostop )
# Maps a value from range [istart, istop] to [ostart, ostop].

# move_toward ( float from, float to, float delta ) Moves from toward to by the delta value. Use a negative delta value to move away.
# clamp ( float value, float min, float max ) gioi han gia tri trong khoang
# lerp ( Variant from, Variant to, float weight ) Linearly interpolates between two values by a normalized value. Nguoc voi inverse_lerp.
# lerp_angle ( float from, float to, float weight ) Linearly interpolates between two angles (in radians) by a normalized value.
# smoothstep ( float from, float to, float s ) lam muot. Dung lam shader,...
# sign ( float s ) kiem tra dau cua s. Neu + thi s = +1. Am thi s = -1. s = 0 tra ve 0
# max ( float a, float b ) tra gia tri lon nhat giua a va b
# min ( float a, float b ) tra gia tri nho nhat giua a va b
# len ( Variant var ) tra ve do dai of Variant var. Loi neu khong the tra duoc gia tri
# sqrt ( float s ) tra ve can bac 2 cua s. sqrt(9) # Returns 3

# wrapf ( float value, float min, float max ) Wraps float value between min and max.
# Usable for creating loop-alike behavior or infinite surfaces.
# Note: If min is 0, this is equivalent to fposmod, so prefer using that instead.
# wrapf is more flexible than using the fposmod approach by giving the user control over the minimum value.

# wrapi ( int value, int min, int max ) Wraps integer value between min and max.
# Usable for creating loop-alike behavior or infinite surfaces.
# Note: If min is 0, this is equivalent to posmod, so prefer using that instead.
# wrapi is more flexible than using the posmod approach by giving the user control over the minimum value.

# fmod ( float a, float b ) tra so du cua a/b
# fposmod ( float a, float b ) tra so du cua a/b voi am duong bang nhau (tru khi b la so am)
# posmod ( int a, int b ) tra so du cua a/b voi am duong bang nhau (tru khi b la so am)
# pow ( float base, float exp ) tinh so mu voi base va mu exp
# exp ( float s ) tinh so mu s cua so e
# step_decimals ( float step ) dem so thap phan sau dau phay
# move_toward ( float value, float amount, float step ) Returns the result of value decreased by step * amount. a = move_toward(60, 10, 0.1)) # a is 59.0
# ease ( float s, float curve ) lam muot. The curve values are: 0 is constant, 1 is linear, 0 to 1 is ease-in, 1+ is ease out. Negative values are in-out/out in.
# log ( float s ) tinh logarit tu nhien cua s
# nearest_po2 ( int value ) tra ve luy thua gan nhat bang hoac lon hon cua 2 cho gia tri so nguyen

## Lam tron
# ceil( float s ) lam tron theo 0.0 giong nhu floor, round, snapped, and int.
# floor ( float s ) lam tron theo 0.5 chuan hon ceil
# snapped ( float s, float step ) lam tron s theo step
# int

## Random
# randf_range ( float from, float to ) tra ngau nhien mot so float trong khoang tu from den to
# rand_seed ( int seed ) tra ve 1 khoang ngau nhien. Neu int seed cac lan gan nhat giong nhau thi khoang cho khong thay doi
# randf ( ) tra ve so float ngau nhien trong khoang [0, 1]
# randi ( ) tra ve so nguyen ngau nhien trong khoang [0, N-1] (voi N nho hon 2^32).
# randomize ( ) dung ham nay truoc khi dung cac ham random khac giup tao seed moi khac nhau
# seed ( int seed ) Sets seed for the random number generator.

## Test
#func _ready():
#	randomize()
#	$Button.text = str(var_to_bytes(464,false))
