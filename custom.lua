-- Configurações
local tempoEntreMensagens = {3, 10}
local tempoEntreAcoes = {15, 30}
local mensagens = {
    "Contas de Blox Fruits? Apenas com o SirMadri!",
    "As melhores contas na GGMAX!",
    "gg/bloxemporium",
    "Garanta suas novas frutas na gg/bloxemporium!",
    "gg/bloxemporium"
}
local nomesbloqueados = {
    "BloxEmporium",
    "SirMadriGGMAX",
    "RoyaleAccounts",
    "PlaceBloxx",
}
local comprarespadas = true
local gravestone = true
local IDs = {
    7449423635, -- Sea 3
    2753915549, -- Sea 1
    4442272183, -- Sea 2
}

-- Verificação de nome bloqueado
local function estaBloqueado(nome)
    for _, bloqueado in ipairs(nomesbloqueados) do
        if nome == bloqueado then
            return true
        end
    end
    return false
end

-- Espera até o jogo e o jogador estarem carregados
local function esperarCarregamento()
    while not game:IsLoaded() or not game.Players.LocalPlayer do
        task.wait(1)
    end
end

-- Pray Event
local function gravestoneEvent()
    if game.PlaceId == 7449423635 then
        while gravestone do
            wait(1)
                local args = {
                "gravestoneEvent",
                2
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
        end
    end
end

-- Compra de itens com delay
local function comprarItem(categoria, nome)
    local args = {
        [1] = categoria,
        [2] = nome
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
    task.wait(0.2)
end

-- Compra automática de espadas
local function buySwords()
    if not comprarespadas then return end
    task.spawn(function()
        while true do
            comprarItem("LegendarySwordDealer", "2")
            local armas = {
                "Katana", "Cutlass", "Dual Katana", "Iron Mace",
                "Triple Katana", "Dual-Headed Blade", "Pipe", "Soul Cane", "Bisento"
            }
            for _, arma in ipairs(armas) do
                comprarItem("BuyItem", arma)
            end
            task.wait(0.5)
        end
    end)
end

-- Escolhe intervalo aleatório entre dois valores
local function intervaloAleatorio(intervalo)
    return math.random(intervalo[1], intervalo[2])
end

-- Envia mensagem no chat
local ultimaMensagem = ""
local function enviarMensagem()
    if #mensagens == 0 then return end
    local mensagem
    repeat
        mensagem = mensagens[math.random(#mensagens)]
    until mensagem ~= ultimaMensagem
    ultimaMensagem = mensagem
    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(mensagem, "All")
end

-- Envia pedido de amizade
local function enviarPedidoAmizade(jogador)
    if jogador and jogador ~= game.Players.LocalPlayer
    and not game.Players.LocalPlayer:IsFriendsWith(jogador.UserId)
    and not estaBloqueado(jogador.DisplayName) then
        game.Players.LocalPlayer:RequestFriendship(jogador)
    end
end

-- Aceita automaticamente amizades
local function aceitarPedidosAmizade()
    while task.wait(5) do
        for _, jogador in ipairs(game.Players:GetPlayers()) do
            if jogador ~= game.Players.LocalPlayer
            and not game.Players.LocalPlayer:IsFriendsWith(jogador.UserId) then
                game.Players.LocalPlayer:RequestFriendship(jogador)
            end
        end
    end
end

-- Inicialização
local function rodarScript()
    gravestoneEvent()
    buySwords()
    task.spawn(aceitarPedidosAmizade)
    while task.wait(intervaloAleatorio(tempoEntreMensagens)) do
        enviarMensagem()
        task.wait(intervaloAleatorio(tempoEntreAcoes))
        local jogadores = game.Players:GetPlayers()
        if #jogadores > 1 then
            local escolhido = jogadores[math.random(#jogadores)]
            enviarPedidoAmizade(escolhido)
        end
    end
end

-- Checar o ID do jogo para inicialização.
local function checkGameID()
    local gameID = game.PlaceId
    local jogo = false
    for _, id in ipairs(IDs) do
        if gameID == id then
            jogo = true
            break
        end
    end
        if jogo then
            print("Iniciando script...")
            rodarScript()
        else
            game.Players.LocalPlayer:Kick("Jogo não suportado.")
    end
end

-- Iniciar
esperarCarregamento()
checkGameID()
