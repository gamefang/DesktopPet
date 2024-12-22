extends Node
class_name  AI

signal  request_finished
@onready var http_request: HTTPRequest = $HTTPRequest

var output: String
var history: Array
var history_count: int = 3
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	http_request.request_completed.connect(on_request_completed)

	
func call_aliyun(prompt):
	var new_message = {"role": "user", "content": prompt} 
	var sys_message = {"role": "system", "content": "你是一个名叫小狐狸的桌面宠物程序，你的功能是陪伴用户和解答各学科的知识，你的回答必须准确而且风趣，而且字数不超过200个字"}
	history.append(new_message)
	var messages = [sys_message]
	messages.append_array(history.slice(-history_count))
	# 这里需要填写自己申请好的apikey
	var api_key = "sk-xxxxxxxxxxx"
	var header = ["Authorization: Bearer " + api_key, "Content-Type: application/json"]
	var body = JSON.stringify({
		"model": "qwen-plus",
		"messages" : messages,
		"stream" : false
	})
	var url = "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions"
	var request_result = http_request.request(url,
									header,
									HTTPClient.METHOD_POST,
									body)

	
func call_ollama(prompt):
	var header = ["Content-Type: application/json"]
	var body = JSON.stringify({
		"model": "qwen2",
		"messages" : [
		{
			"role": "user",
			"content": prompt
		}
			],
		"stream" : false
	})
	var url = "http://127.0.0.1:11434/api/chat"
	var request_result = http_request.request(url,
									header,
									HTTPClient.METHOD_POST,
									body)


func on_request_completed(result, response_code, headers, body):
	var response = JSON.parse_string(body.get_string_from_utf8())
	#print(response.message.content)  
	output = response['choices'][0].message.content
	history.append({"role": "assistant", "content":output})
	request_finished.emit(output)
