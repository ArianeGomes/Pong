function love.load()
	mainFont = love.graphics.newFont("fonts/pixeled.ttf", 20)
	instructionsFont = love.graphics.newFont("fonts/pixeled.ttf", 5)

	screenHeight = 400
	screenWidth = 600

	-- Altura e largura das barras dos players
	barHeight = 50
	barWidth = 6

	-- Posição dos elementos na tela de jogo
	ballposX = (screenWidth/2) - 3
	ballposY = (screenHeight/2) - 3

	player1posX = 100
	player1posY = 175
	player2posX = 494
	player2posY = 175

	-- Pontuação dos players
	score1 = 0
	score2 = 0
	
	-- Variáveis auxiliares para diferenciação de telas para recomeçar o jogo
	start = 0
	finish = 0

	-- Variáveis auxiliares para movimentação da bolinha
	movement = false
	acceleration = 10
	pause = 0

	love.window.setTitle("Pong - by 4riane")
	love.window.setMode(screenWidth, screenHeight)
	love.mouse.setVisible(false)
end

function love.draw()
	love.graphics.setFont(mainFont)

	if (start == 0) then
		menuScreen()
	elseif (start == 1 and finish == 0) then
		gameScreen()
	else
		winnerScreen()
	end
end

function love.update(dt)
	if (love.keyboard.isDown("return") and (start == 0 or finish == 1)) then
		start = 1
		if finish == 1 then
			resetGame()
		end
	end

	if (love.keyboard.isDown("space") and start == 1 and finish == 0) then
		if pause == 0 then
			pause = 1
		end
	end

	if (love.keyboard.isDown("escape") and start == 1 and finish == 0) then
		if pause == 1 then
			pause = 0
		end
	end

	if (love.keyboard.isDown("escape") and (start == 0 or finish == 1)) then
		love.event.quit()
	end

	playersControl(dt)
	ballMoves(dt)
	collisions()
end

function resetGame()
	ballposX = (screenWidth/2) - 3
	ballposY = (screenHeight/2) - 3

	player1posX = 100
	player1posY = 175
	player2posX = 494
	player2posY = 175

	score1 = 0
	score2 = 0

	finish = 0
end

function playersControl(dt)
	if pause == 0 then
		playerVelocity = 200 * dt
	else
		playerVelocity = 0
	end

	-- Mover barras para cima ou para baixo
	-- Player 1
	if love.keyboard.isDown("w") then
		player1posY = player1posY - playerVelocity
	end

	if love.keyboard.isDown("s") then
		player1posY = player1posY + playerVelocity
	end

	-- Player 2
	if love.keyboard.isDown("up") then
		player2posY = player2posY - playerVelocity
	end

	if love.keyboard.isDown("down") then
		player2posY = player2posY + playerVelocity
	end

	-- Não ultrapassar limite superior e inferior da tela
	if player1posY < 0 then
		player1posY = 0
	elseif player1posY > screenHeight - barHeight then
		player1posY = screenHeight - barHeight
	end

	if player2posY < 0 then
		player2posY = 0
	elseif player2posY > screenHeight - barHeight then
		player2posY = screenHeight - barHeight
	end
end

function ballMoves(dt)
	if pause == 0 then
		velocity = 7 * dt * acceleration
	else
		velocity = 0
	end

	if movement == false then
		quadrant = love.math.random(0, 3)
		movement = true
	end

	if quadrant == 0 then
		ballposX = ballposX - velocity
		ballposY = ballposY - velocity
	elseif quadrant == 1 then
		ballposX = ballposX - velocity
		ballposY = ballposY + velocity
	elseif quadrant == 2 then
		ballposX = ballposX + velocity
		ballposY = ballposY + velocity
	elseif quadrant == 3 then
		ballposX = ballposX + velocity
		ballposY = ballposY - velocity
	end

	if ballposY <= 0 then
		if quadrant == 0 then
			quadrant = 1
		else
			quadrant = 2
		end
	elseif ballposY >= 400 then
		if quadrant == 1 then
			quadrant = 0
		else
			quadrant = 3
		end
	end
end

function collisions()
	-- Colisão da bola com a lateral esquerda do campo
	if (collisionLeft(90, -200, 800, 2, ballposX, ballposY, 6, 6)) then
		score2 = score2 + 1
		ballposX = (screenWidth/2) - 3
		ballposY = (screenHeight/2) - 3
		movement = false
		acceleration = 10
	end

	-- Colisão da bola com o Player 1
	if (collisionLeft(player1posX, player1posY, barHeight, barWidth, ballposX, ballposY, 6, 6)) then
		acceleration = acceleration + 5
		-- Mecanica de rebater
		if quadrant == 0 then
			quadrant = 3
		else
			quadrant = 2
		end
	end

	-- Colisão da bola com a lateral direita do campo
	if (collisionRight(510, -200, 800, 2, ballposX, ballposY, 6, 6)) then
		score1 = score1 + 1
		ballposX = (screenWidth/2) - 3
		ballposY = (screenHeight/2) - 3
		movement = false
		acceleration = 10
	end

	-- Colisão da bola com o Player 2
	if (collisionRight(player2posX, player2posY, barHeight, barWidth, ballposX, ballposY, 6, 6)) then
		acceleration = acceleration + 5
		-- Mecanica de rebater
		if quadrant == 3 then
			quadrant = 0
		else
			quadrant = 1
		end
	end


	if (score1 >= 3 or score2 >= 3) then
		finish = 1
	end
end

function collisionRight(posX1, posY1, alt1, larg1, posX2, posY2, alt2, larg2)
	return (posX2 + larg2) > posX1 and ((posY2 + alt2) > posY1 and posY2 < (posY1 + alt1))
end

function collisionLeft(posX1, posY1, alt1, larg1, posX2, posY2, alt2, larg2)
	return posX2 < (posX1 + larg1) and ((posY2 + alt2) > posY1 and posY2 < (posY1 + alt1))
end

function menuScreen()
	love.graphics.printf("PONG", 0, 50, 600, "center")
	love.graphics.printf("Play (enter)", 0, 150, 600, "center")
	love.graphics.printf("Exit (esc)", 0, 200, 600, "center")
end

function gameScreen()
	love.graphics.printf(score1, 5, 25, 85, "center")
	love.graphics.printf(score2, 345, 25, 425, "center")

	love.graphics.setFont(instructionsFont)
	if pause == 0 then
		love.graphics.printf("Pause (space)", 5, 380, 85, "center")
		love.graphics.printf("Pause (space)", 345, 380, 425, "center")
	else
		love.graphics.setFont(mainFont)
		love.graphics.printf("PAUSED", 0, 170, 600, "center")
		love.graphics.setFont(instructionsFont)
		love.graphics.printf("Release (esc)", 5, 380, 85, "center")
		love.graphics.printf("Release (esc)", 345, 380, 425, "center")
	end
	love.graphics.setFont(mainFont)

	love.graphics.line(90, 0, 90, 400)
	love.graphics.line(510, 0, 510, 400)

	ball = love.graphics.rectangle("fill", ballposX, ballposY, 6, 6)
	player1 = love.graphics.rectangle("fill", player1posX, player1posY, barWidth, barHeight)
	player2 = love.graphics.rectangle("fill", player2posX, player2posY, barWidth, barHeight)
end

function winnerScreen()
	if score2 >= 3 then
		love.graphics.clear()
		love.graphics.printf("Player 2 wins!", 0, 50, 600, "center")
		love.graphics.printf("Play again (enter)", 0, 150, 600, "center")
		love.graphics.printf("Quit (esc)", 0, 200, 600, "center")
	elseif score1 >= 3 then
		love.graphics.clear()
		love.graphics.printf("Player 1 wins!", 0, 50, 600, "center")
		love.graphics.printf("Play again (enter)", 0, 150, 600, "center")
		love.graphics.printf("Quit (esc)", 0, 200, 600, "center")
	end
end