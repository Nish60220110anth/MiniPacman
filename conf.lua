function love.conf(t)
    t.identity = "data/"
    t.console = true
    t.audio.mic= true
    t.window.title = "MiniPacman"
    t.window.icon = "icon/icon.png"
    t.window.height = 600
    t.window.width = 800
    t.window.resizable = false
    t.window.minwidth = 400
    t.window.minheight = 400
    t.window.x = 100
    t.window.y = 100
end