getgenv().url = "http://localhost:8081/add" -- endpoint para enviar secrets
getgenv().x_token = "supersecreto123"
getgenv().get_job_url = "http://localhost:8081/get-job" -- endpoint para pegar job_id para hop

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local plots = Workspace:WaitForChild("Plots")
local HttpService = game:GetService("HttpService")
local TPS = game:GetService("TeleportService")
local Player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()

-- FPS boost / invisibilidade
local Lighting = game:GetService('Lighting')
settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
Lighting.Brightness = 0
Lighting.GlobalShadows = false
Lighting.Ambient = Color3.new(0,0,0)
Lighting.OutdoorAmbient = Color3.new(0,0,0)
Lighting.FogEnd = 1
Lighting.FogStart = 0

local function makeInvisible(object)
    pcall(function()
        if object:IsA('BasePart') then object.Transparency = 1 object.CastShadow = false
        elseif object:IsA('Decal') or object:IsA('Texture') then object.Transparency = 1
        elseif object:IsA('ParticleEmitter') or object:IsA('Trail') or object:IsA('Beam') then object.Enabled = false end
    end)
end

for _, v in next, workspace:GetDescendants() do makeInvisible(v) end
workspace.DescendantAdded:Connect(makeInvisible)
for _, v in next, workspace:GetDescendants() do pcall(function() if v:IsA("Sound") then v.Playing = false end end) end
workspace.DescendantAdded:Connect(function(v) pcall(function() if v:IsA("Sound") then v.Playing = false end end) end)

-- Conversor abreviação
local function conversor(valor)
    if not valor then return 0 end
    local mult = 1
    local number = valor:match("[%d%.]+")
    if valor:find("K") then mult = 1_000
    elseif valor:find("M") then mult = 1_000_000
    elseif valor:find("B") then mult = 1_000_000_000 end
    return tonumber(number) and tonumber(number) * mult or 0
end

-- Envia Secret
local function sendSecret(name, generation, job_id)
    local payload = {
        name = name,
        generation = generation,
        job_id = job_id
    }

    local encoded = HttpService:JSONEncode(payload)
    local requestFunc = http_request or request or (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request)

    if requestFunc then
        pcall(function()
            requestFunc({
                Url = getgenv().url,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json",
                    ["x-token"] = getgenv().x_token
                },
                Body = encoded
            })
        end)
    end
end

-- Server hop usando job_id do seu novo endpoint
local function serverHop()
    local requestFunc = http_request or request or (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request)
    if not requestFunc then return end

    local ok, res = pcall(function()
        return requestFunc({
            Url = getgenv().get_job_url,
            Method = "GET"
        })
    end)

    if ok and res and res.Body then
        local data = HttpService:JSONDecode(res.Body)
        if data and data.job_id then
            TPS:TeleportToPlaceInstance(game.PlaceId, data.job_id, Player)
        end
    end
end

-- Checagem de plots e envio de Secrets
local function checker()
    local playersnum = #Players:GetPlayers()
    if playersnum >= 8 then return end

    local totalFound = 0

    for _, plot in ipairs(plots:GetChildren()) do
        local animalPodiums = plot:FindFirstChild("AnimalPodiums")
        if animalPodiums then
            for _, model in ipairs(animalPodiums:GetChildren()) do
                local base = model:FindFirstChild("Base")
                local spawn = base and base:FindFirstChild("Spawn")
                local attach = spawn and spawn:FindFirstChild("Attachment")
                local overhead = attach and attach:FindFirstChild("AnimalOverhead")
                if overhead then
                    local nome = overhead:FindFirstChild("DisplayName")
                    local gen = overhead:FindFirstChild("Generation")
                    local rarity = overhead:FindFirstChild("Rarity")
                    local valorcorreto = gen and conversor(gen.Text) or 0
                    if rarity and rarity.Text == "Secret" and valorcorreto >= 1_000_000 then
                        sendSecret(
                            nome and nome.Text or "Unknown",
                            gen and gen.Text or "0",
                            game.JobId
                        )
                        totalFound += 1
                    end
                end
            end
        end
    end

    if totalFound == 0 then
        print("Nenhum animal encontrado, fazendo hop...")
        serverHop()
    end
end

-- Loop principal
task.spawn(function()
    while task.wait(5) do
        checker()
    end
end)
