start = null
is-blink = false
is-light = true
is-run = false
is-show = true
is-warned = false
handler = null
latency = 0
stop-by = null
delay = 60000
audio-remind = null
audio-end = null
alarm-fade-handler = null

new-audio = (file) ->
  node = new Audio!
    ..src = file
    ..loop = false
    ..load!
  document.body.appendChild node
  return node

sound-toggle = (des, state) ->
  if state => des.play!
  else des
    ..currentTime = 0
    ..pause!

stop-alarm = ->
  if alarm-fade-handler => clearInterval alarm-fade-handler
  alarm-fade-handler := null
  if audio-end =>
    audio-end.loop = false
    sound-toggle audio-end, false
    audio-end.volume = 1

start-alarm = ->
  stop-alarm!
  if audio-end =>
    audio-end.volume = 0.1
    audio-end.loop = true
    audio-end.currentTime = 0
    audio-end.play!
    alarm-fade-handler := setInterval ( ->
      v = audio-end.volume + 0.1
      if v >= 1 =>
        audio-end.volume = 1
        clearInterval alarm-fade-handler
        alarm-fade-handler := null
      else audio-end.volume = v
    ), 500

show = ->
  is-show := !is-show
  $ \.fbtn .css \opacity, if is-show => \1.0 else \0.1

adjust = (it,v) ->
  if is-blink => return
  delay := delay + it * 1000
  if it==0 => delay := v * 1000
  if delay <= 0 => delay := 0
  $ \#timer .text delay
  resize!

toggle = ->
  is-run := !is-run
  $ \#toggle .text if is-run => "STOP" else "RUN"
  if !is-run and handler =>
    stop-by := new Date!
    clearInterval handler
    handler := null
    stop-alarm!
    sound-toggle audio-remind, false
  if stop-by =>
    latency := latency + (new Date!)getTime! - stop-by.getTime!
  if is-run => run!

reset = ->
  if delay == 0 => delay := 1000
  sound-toggle audio-remind, false
  stop-alarm!
  stop-by := 0
  is-warned := false
  is-blink := false
  latency := 0
  start := null #new Date!
  is-run := true
  toggle!
  if handler => clearInterval handler
  handler := null
  $ \#timer .text delay
  $ \#timer .css \color, \#fff
  resize!


blink = ->
  is-blink := true
  is-light := !is-light
  $ \#timer .css \color, if is-light => \#fff else \#f00

count = ->
  tm = $ \#timer
  diff = start.getTime! - (new Date!)getTime! + delay + latency
  if diff > 60000 => is-warned := false
  if diff < 60000 and !is-warned =>
    is-warned := true
    sound-toggle audio-remind, true
  if diff < 55000 => sound-toggle audio-remind, false
  if diff < 0 and !is-blink =>
    start-alarm!
    is-blink := true
    diff = 0
    clearInterval handler
    handler := setInterval ( -> blink!), 500
  tm.text "#{diff}"
  resize!

run =  ->
  if start == null =>
    start := new Date!
    latency := 0
    is-blink := false
  if handler => clearInterval handler
  if is-blink => handler := setInterval (-> blink!), 500
  else handler := setInterval (-> count!), 100

resize = ->
  tm = $ \#timer
  w = tm.width!
  h = $ window .height!
  len = tm.text!length
  len>?=3
  tm.css \font-size, "#{1.5 * w/len}px"
  tm.css \line-height, "#{h}px"


window.onload = ->
  $ \#timer .text delay
  resize!
  #audio-remind := new-audio \audio/cop-car.mp3
  #audio-end := new-audio \audio/fire-alarm.mp3
  audio-remind := new-audio \audio/smb_warning.mp3
  audio-end := new-audio \audio/fire-alarm.mp3
window.onresize = -> resize!
