extends Node
# ============================================================
# AudioManager - 音频管理器
# 职责：管理背景音乐（BGM）、音效（SFX）播放与音量控制
# 音频缺失时优雅跳过（不报错），后续补充资源即可生效
# ============================================================

const BGM_DIR := "res://assets/sounds/bgm/"
const SFX_DIR := "res://assets/sounds/sfx/"
const SFX_POOL_SIZE := 8

var _bgm_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []


func _ready() -> void:
	_bgm_player = AudioStreamPlayer.new()
	add_child(_bgm_player)
	for i in range(SFX_POOL_SIZE):
		var player := AudioStreamPlayer.new()
		add_child(player)
		_sfx_players.append(player)


# 播放背景音乐
func play_bgm(track_name: String, fade_time: float = 0.5) -> void:
	var stream := _load_audio(BGM_DIR + track_name + ".ogg")
	if stream == null:
		return
	_bgm_player.stream = stream
	_bgm_player.play()


# 停止背景音乐
func stop_bgm(fade_time: float = 0.5) -> void:
	_bgm_player.stop()


# 播放音效
func play_sfx(sfx_name: String, volume_db: float = 0.0) -> void:
	var stream := _load_audio(SFX_DIR + sfx_name + ".ogg")
	if stream == null:
		return
	for player in _sfx_players:
		if not player.playing:
			player.stream = stream
			player.volume_db = volume_db
			player.play()
			return


# 设置背景音乐音量（-60 ~ 0 dB）
func set_bgm_volume(value_db: float) -> void:
	_bgm_player.volume_db = value_db


# 设置音效音量（-60 ~ 0 dB）
func set_sfx_volume(value_db: float) -> void:
	for player in _sfx_players:
		player.volume_db = value_db


# 内部：加载音频（文件不存在返回 null）
func _load_audio(path: String) -> AudioStream:
	if not ResourceLoader.exists(path):
		return null
	var res: Variant = load(path)
	return res if res is AudioStream else null
