push = require 'push'

Class = require 'class'

require 'Paddle'
require 'Ball'

WIN_H = 720
WIN_W = 1280

VIRTUAL_W=432
VIRTUAL_H=243

paddleSpeed = 200
pad1x=10
pad1y=30
pad2x=VIRTUAL_W-10
pad2y=VIRTUAL_H-50
function love.load()
	love.window.setTitle("Poong! by:Garret Ravelli")
	love.graphics.setDefaultFilter('nearest', 'nearest')
	math.randomseed(os.time())
	
	smallFont=love.graphics.newFont('COMICATE.ttf',14)
	scoreFont=love.graphics.newFont('font.ttf',32)

	love.graphics.setFont(smallFont)
	
	push:setupScreen(VIRTUAL_W, VIRTUAL_H, WIN_W, WIN_H,{
	fullscreen = false,
	resizable = false,
	vsync = true})
	
	--ahi inicia el rectangulo 
	player1 = Paddle(pad1x,pad1y,5,30)
	player2 = Paddle(pad2x,pad2y,5,30)
	
	pl1score = 0
	pl2score = 0
	
	--Jugador en servició 
	servingPlayer = 1
	
	--pelota
	ball = Ball(VIRTUAL_W/2-2, VIRTUAL_H/2-2,4,4)
	
	gameState = 'start'
	--Imagen en backgraund
	bg = love.graphics.newImage("jupiter.jpg")

	--Sonido
	sonidoCollisions = love.audio.newSource("collision.wav","static")
	sonidoMisService = love.audio.newSource("misservice.wav","static")
	sonidoWinning = love.audio.newSource("winning.wav","static")
	bgmusic = love.audio.newSource("8Bits.mp3","stream")
end

function love.keypressed(key)
    if key == 'escape' then 
        love.event.quit()
	elseif key == 'enter' or key == 'return' then
			if gameState=='start' then
				gameState ='serve' --serve
			elseif gameState=='serve' then
				gameState ='play'
			elseif gameState == 'done' then
				gameState = 'start'
				pl1score=0--añadido
				pl2score=0--añadido
				player1:reset(pad1x,pad1y)
				player2:reset(pad2x,pad2y)
				--ponerlo con la clase
				ball:reset()
				if winningPlayer == 1 then
					servingPlayer = 2
				else
					servingPlayer = 1
				end
				--ballX = VIRTUAL_W/2-2
				--ballY = VIRTUAL_H/2-2
				--ballDX = math.random(2) == 1 and 100 or -100
				--ballDY = math.random(-50, 50)
			else
				gameState = 'start'
				pl1score=0--añadido
				pl2score=0--añadido
				--ponerlo con la clase
				player1:reset(pad1x,pad1y)
				player2:reset(pad2x,pad2y)
				ball:reset()
			end
	elseif key == 'w' or key =='s' then
		if gameState == 'start' then
			servingPlayer = 2
			gameState = 'serve'
		end
	elseif key == 'up' or key =='down' then
		if gameState == 'start' then
			servingPlayer = 1
			gameState = 'serve'
		end
    end    
end

function love.update(dt)
		--Servició
	if gameState == 'serve' then
		if servingPlayer == 1 then 
			ball.dx = math.random(100,200)
		else 
			ball.dx = -math.random(100,200)
		end

		ball.dy = math.random(-50,50)
		gameState = 'play' --ES AQUI GARRET

	elseif gameState == 'play' then
	--COLISIONES 
		--Arriba
		if ball.y <= 0 then
			ball.y = 0
			ball.dy = -ball.dy
			sonidoCollisions:play() -- Suena colisión
		end
		--Abajo
		if ball.y >= VIRTUAL_H -4 then
			ball.y =  VIRTUAL_H -4 
			ball.dy = -ball.dy
			sonidoCollisions:play() -- Suena colisión
		end
		--paddles
		if ball:collides(player1) then
			ball.dx=-ball.dx * 1.10
			ball.x = player1.x + 5
			
			if ball.dy <0 then
				ball.dy = -math.random(40,150) --experimentar angulos
			else
				ball.dy = math.random(40,150) --experimentar angulos
			end
			sonidoCollisions:play()
		end
		if ball:collides(player2) then
			ball.dx=-ball.dx * 1.10
			ball.x = player2.x - 4
			
			if ball.dy <0 then
				ball.dy = -math.random(40,150) --experimentar angulos
			else
				ball.dy = math.random(40,150) --experimentar angulos
			end
			sonidoCollisions:play()
		end
	end

	if ball.x<0 then 
		pl2score=pl2score+1
		--gameState = 'start'
		if pl2score == 5 then 
			winningPlayer = 2
			gameState = 'done'
			sonidoWinning:play() -- Suena ganado
		else
			servingPlayer = 1
			gameState = 'serve'
		end
		ball:reset()
		sonidoMisService:play() -- Suena gol
	end
	
	
	if ball.x>VIRTUAL_W then 
		pl1score=pl1score+1
		--gameState = 'start'
		if pl1score == 5 then 
			winningPlayer = 1
			gameState = 'done'
			sonidoWinning:play() -- Suena ganador
		else
			servingPlayer = 2
			gameState = 'serve'
		end
		ball:reset()
		sonidoMisService:play() -- Suena gol
	end

	--up and down of paddle in left
	if love.keyboard.isDown('w')then
	player1.dy = -paddleSpeed
	elseif love.keyboard.isDown('s')then
	player1.dy = paddleSpeed
	else
		player1.dy = 0
	end
	
	--un and down of paddle in right
	if love.keyboard.isDown('up')then
	player2.dy = -paddleSpeed
	--player2Y = math.max(0,player2Y - paddleSpeed * dt)
	elseif love.keyboard.isDown('down')then
	player2.dy = paddleSpeed
	--player2Y = math.min(VIRTUAL_H-20, player2Y + paddleSpeed * dt)
	else	
		player2.dy = 0
	end
	
	if gameState == 'play' then
	ball:update(dt)
	--ballX = ballX + ballDX * dt
	--ballY = ballY + ballDY * dt
	end
	player1:update(dt)
	player2:update(dt)

end

function love.draw()
	love.graphics.draw(bg, 0, 0, 0, 1.25)
	bgmusic:setVolume(0.25)
	bgmusic:play()
	push:apply("start")
	
	--draw here
	love.graphics.setFont(smallFont)
	--love.graphics.setColor( 65, 150, 12)
	
	if gameState =='start' then 
		love.graphics.printf('Welcome to Pong!',0, 10 ,VIRTUAL_W,'center')
		love.graphics.printf('Press enter to begin',0, 20 ,VIRTUAL_W,'center')
	elseif gameState == 'serve' then
		love.graphics.printf('Player ' .. tostring(servingPlayer) .. ' serving',0, 10 ,VIRTUAL_W,'center')
	
	elseif gameState == 'done' then
		love.graphics.printf('Player ' .. tostring(winningPlayer) .. 'wins!',0, 10 ,VIRTUAL_W,'center')
		love.graphics.printf('Press enter to play again',0, 30 ,VIRTUAL_W,'center')
	else
		love.graphics.printf('Player ' .. tostring(servingPlayer) .. ' serving',0, 10 ,VIRTUAL_W,'center')
		love.graphics.printf('Hello play!',0, 30 ,VIRTUAL_W,'center')
	end
	
	love.graphics.setFont(scoreFont)
	love.graphics.print(tostring(pl1score),VIRTUAL_W/2-50, VIRTUAL_H/4)
	love.graphics.print(tostring(pl2score),VIRTUAL_W/2+30, VIRTUAL_H/4)
	love.graphics.setColor( 255, 0, 0)	
	player1:render()
	love.graphics.setColor( 0, 0, 255)
	player2:render()
	love.graphics.setColor( 0, 255, 0)
	ball:render() 	
	
	push:apply("end")
	

end