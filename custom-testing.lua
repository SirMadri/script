-- IDs dos jogos (fixos)
local IDs = {
    7449423635, -- Sea 3
    2753915549, -- Sea 1
    4442272183, -- Sea 2
}

-- Configurações do usuário
local config = getgenv().Config or {}

local tempoEntreMensagens = config.TempoEntreMensagens or {3, 10}
local tempoEntreAcoes = config.TempoEntreAcoes or {15, 30}
local mensagens = config.mensagens or {}
local nomesbloqueados = config.nomesbloqueados or {}
local comprarespadas = config.ComprarEspadas or false
local gravestone = config.Gravestone or false

-- Funções auxiliares
local function estaBloqueado(nome)
    for _, bloqueado in ipairs(nomesbloqueados) do
        if nome == bloqueado then return true end
    end
    return false
end

local function esperarCarregamento()
    while not game:IsLoaded() or not game.Players.LocalPlayer do
        task.wait(1)
    end
end

local function gravestoneEvent()
    while gravestone do
        task.wait(1)
        local args = {"gravestoneEvent", 2}
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
    end
end

local function comprarItem(categoria, nome)
    local args = {[1] = categoria, [2] = nome}
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
    task.wait(0.2)
end

local function buySwords()
    task.spawn(function()
        while true do
            if not comprarespadas then break end
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

local function intervaloAleatorio(intervalo)
    return math.random(intervalo[1], intervalo[2])
end

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

local function enviarPedidoAmizade(jogador)
    if jogador and jogador ~= game.Players.LocalPlayer
    and not game.Players.LocalPlayer:IsFriendsWith(jogador.UserId)
    and not estaBloqueado(jogador.DisplayName) then
        game.Players.LocalPlayer:RequestFriendship(jogador)
    end
end

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

local function jogoSuportado()
    local id = game.PlaceId
    for _, permitido in ipairs(IDs) do
        if id == permitido then return true end
    end
    return false
end

local function rodarScript()
    local id = game.PlaceId

    -- Sea 3: gravestone + restante
    if id == 7449423635 and gravestone then
        task.spawn(gravestoneEvent)
    end

    -- Todos os mares: espadas, mensagens, amizade
    if comprarespadas then
        task.spawn(buySwords)
    end

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

-- Execução
esperarCarregamento()
if jogoSuportado() then
    print("Iniciando script...")
    rodarScript()
else
    game.Players.LocalPlayer:Kick("Jogo não suportado.")
end
