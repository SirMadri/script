local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local webhookUrl = getgenv().webhookCONFIG
local vps = getgenv().VPSCONFIG
local alreadySent = false

task.spawn(function()
	while task.wait(0.2) do
		local gui = player:FindFirstChild("PlayerGui")
		if not gui then continue end

		local app = gui:FindFirstChild("CatBatTamingApp")
		if not app then continue end

		local progress = app:FindFirstChild("ProgressText")
		if not progress or not progress:IsA("TextLabel") then
			print("[INFO][" .. vps .. "] A GUI de progresso ainda não existe.")
			continue
		end

		local text = progress.Text
		print("[Progress][" .. vps .. "] Taming: " .. text)

		if text == "100%" and not alreadySent then
			alreadySent = true

			local data = {
				content = "",
				tts = false,
				embeds = {{
					id = 356043464,
					title = "Um pet Kitty Bat foi obtido no evento de Halloween! 🎃",
					description = "Usuário: **" .. player.Name .. "**\nVPS: **" .. vps .. "**",
					color = 0xFF7518,
					fields = {{
						name = "⏰ Horário Local",
						value = os.date("%d/%m/%Y %H:%M:%S"),
						inline = true
					}},
					timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
				}},
				username = "Kitty Bat",
				avatar_url = "https://media.discordapp.net/attachments/1416974801255399525/1424246106690289787/Kitty_Bat.webp?ex=68e3400d&is=68e1ee8d&hm=336c96705b9fba28a5a867a9ce69d72a0179e58f566bc8908e68e755ac5e6d25&=&format=webp&width=960&height=960"
			}

			local success, err = pcall(function()
				HttpService:PostAsync(
					webhookUrl,
					HttpService:JSONEncode(data),
					Enum.HttpContentType.ApplicationJson
				)
			end)

			if success then
				print("[Webhook][" .. vps .. "] 🎃 Enviado com sucesso para o Discord!")
			else
				warn("[Webhook][" .. vps .. "] Erro ao enviar:", err)
			end

		elseif text ~= "100%" and alreadySent then
			alreadySent = false
			print("[INFO][" .. vps .. "] Progresso resetado, aguardando novo pet...")
		end
	end
end)
