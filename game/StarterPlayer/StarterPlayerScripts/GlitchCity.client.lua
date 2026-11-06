--!strict
-- Neon Breakout client HUD, input and local-only visual feedback.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("GlitchCityEvent") :: RemoteEvent
local gui = Instance.new("ScreenGui")
gui.Name = "NeonBreakoutHUD"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 20
gui.Parent = player:WaitForChild("PlayerGui")

local CYAN = Color3.fromRGB(57, 245, 255)
local PURPLE = Color3.fromRGB(169, 99, 255)
local GOLD = Color3.fromRGB(255, 211, 92)
local WHITE = Color3.fromRGB(236, 244, 255)
local MUTED = Color3.fromRGB(143, 159, 190)
local PANEL = Color3.fromRGB(12, 17, 36)

local function rounded(parent: Instance, radius: number)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent
end

local function stroke(parent: Instance, color: Color3, thickness: number, transparency: number?)
	local outline = Instance.new("UIStroke")
	outline.Color = color
	outline.Thickness = thickness
	outline.Transparency = transparency or 0
	outline.Parent = parent
end

local function label(parent: Instance, text: string, size: UDim2, position: UDim2, fontSize: number, color: Color3, bold: boolean?)
	local item = Instance.new("TextLabel")
	item.BackgroundTransparency = 1
	item.Size = size
	item.Position = position
	item.Text = text
	item.TextColor3 = color
	item.TextSize = fontSize
	item.Font = bold and Enum.Font.GothamBold or Enum.Font.GothamMedium
	item.TextXAlignment = Enum.TextXAlignment.Left
	item.TextYAlignment = Enum.TextYAlignment.Center
	item.Parent = parent
	return item
end

local function panel(parent: Instance, size: UDim2, position: UDim2, anchor: Vector2?)
	local frame = Instance.new("Frame")
	frame.Size = size
	frame.Position = position
	frame.AnchorPoint = anchor or Vector2.zero
	frame.BackgroundColor3 = PANEL
	frame.BackgroundTransparency = 0.1
	frame.Parent = parent
	rounded(frame, 12)
	stroke(frame, Color3.fromRGB(70, 91, 139), 1, 0.25)
	return frame
end

local header = panel(gui, UDim2.fromOffset(330, 86), UDim2.fromOffset(22, 20))
local logo = label(header, "N//B", UDim2.fromOffset(68, 42), UDim2.fromOffset(16, 10), 25, CYAN, true)
logo.TextXAlignment = Enum.TextXAlignment.Center
label(header, "NEON BREAKOUT", UDim2.fromOffset(230, 29), UDim2.fromOffset(91, 11), 18, WHITE, true)
local subtitle = label(header, "ROOFTOP RUNNER  •  SECTOR 09", UDim2.fromOffset(230, 24), UDim2.fromOffset(91, 42), 10, MUTED, true)
subtitle.TextYAlignment = Enum.TextYAlignment.Top
local logoLine = Instance.new("Frame")
logoLine.Size = UDim2.fromOffset(2, 48)
logoLine.Position = UDim2.fromOffset(81, 19)
logoLine.BackgroundColor3 = CYAN
logoLine.BorderSizePixel = 0
logoLine.Parent = header

local objective = panel(gui, UDim2.fromOffset(270, 114), UDim2.new(1, -22, 0, 20), Vector2.new(1, 0))
label(objective, "MISSION // DATA HEIST", UDim2.new(1, -28, 0, 23), UDim2.fromOffset(14, 11), 11, PURPLE, true)
local shardsText = label(objective, "◇  DATA SHARDS     0 / 10", UDim2.new(1, -28, 0, 25), UDim2.fromOffset(14, 40), 13, GOLD, true)
local relaysText = label(objective, "▣  NETWORK RELAYS  0 / 3", UDim2.new(1, -28, 0, 25), UDim2.fromOffset(14, 69), 13, CYAN, true)

local healthPanel = panel(gui, UDim2.fromOffset(250, 62), UDim2.new(0, 22, 1, -22), Vector2.new(0, 1))
label(healthPanel, "VITALS", UDim2.fromOffset(70, 17), UDim2.fromOffset(14, 8), 10, MUTED, true)
local healthBack = Instance.new("Frame")
healthBack.Size = UDim2.new(1, -28, 0, 11)
healthBack.Position = UDim2.fromOffset(14, 34)
healthBack.BackgroundColor3 = Color3.fromRGB(41, 47, 70)
healthBack.BorderSizePixel = 0
healthBack.Parent = healthPanel
rounded(healthBack, 5)
local healthFill = Instance.new("Frame")
healthFill.Size = UDim2.fromScale(1, 1)
healthFill.BackgroundColor3 = Color3.fromRGB(95, 255, 178)
healthFill.BorderSizePixel = 0
healthFill.Parent = healthBack
rounded(healthFill, 5)
local healthValue = label(healthPanel, "100", UDim2.fromOffset(38, 17), UDim2.new(1, -52, 0, 7), 11, WHITE, true)
healthValue.TextXAlignment = Enum.TextXAlignment.Right

local abilityPanel = panel(gui, UDim2.fromOffset(412, 84), UDim2.new(1, -22, 1, -22), Vector2.new(1, 1))
label(abilityPanel, "GLITCH ENERGY", UDim2.fromOffset(142, 17), UDim2.fromOffset(15, 9), 10, MUTED, true)
local energyValue = label(abilityPanel, "100%", UDim2.fromOffset(48, 17), UDim2.fromOffset(350, 9), 10, CYAN, true)
energyValue.TextXAlignment = Enum.TextXAlignment.Right
local energyBack = Instance.new("Frame")
energyBack.Size = UDim2.new(1, -30, 0, 5)
energyBack.Position = UDim2.fromOffset(15, 29)
energyBack.BackgroundColor3 = Color3.fromRGB(40, 48, 75)
energyBack.BorderSizePixel = 0
energyBack.Parent = abilityPanel
rounded(energyBack, 3)
local energyFill = Instance.new("Frame")
energyFill.Size = UDim2.fromScale(1, 1)
energyFill.BackgroundColor3 = CYAN
energyFill.BorderSizePixel = 0
energyFill.Parent = energyBack
rounded(energyFill, 3)

local function abilityButton(name: string, hint: string, x: number, accent: Color3, action: string)
	local button = Instance.new("TextButton")
	button.Name = name .. "Button"
	button.Size = UDim2.fromOffset(184, 37)
	button.Position = UDim2.fromOffset(x, 39)
	button.BackgroundColor3 = Color3.fromRGB(23, 31, 57)
	button.Text = ""
	button.AutoButtonColor = false
	button.Parent = abilityPanel
	rounded(button, 8)
	stroke(button, accent, 1, 0.25)
	local key = label(button, hint, UDim2.fromOffset(30, 30), UDim2.fromOffset(8, 3), 11, accent, true)
	key.TextXAlignment = Enum.TextXAlignment.Center
	label(button, name, UDim2.new(1, -48, 1, 0), UDim2.fromOffset(43, 0), 12, WHITE, true)
	button.Activated:Connect(function() remote:FireServer(action) end)
	return button
end

abilityButton("GLITCH DASH", "SHIFT", 12, CYAN, "Dash")
abilityButton("SYSTEM PULSE", "Q", 207, PURPLE, "Pulse")

local toast = panel(gui, UDim2.fromOffset(350, 48), UDim2.new(0.5, 0, 0, 26), Vector2.new(0.5, 0))
toast.Visible = false
toast.BackgroundTransparency = 0.04
local toastText = label(toast, "", UDim2.new(1, -24, 1, 0), UDim2.fromOffset(12, 0), 14, CYAN, true)
toastText.TextXAlignment = Enum.TextXAlignment.Center

local crosshair = Instance.new("Frame")
crosshair.Size = UDim2.fromOffset(7, 7)
crosshair.Position = UDim2.new(0.5, -3, 0.5, -3)
crosshair.BackgroundColor3 = CYAN
crosshair.BackgroundTransparency = 0.25
crosshair.BorderSizePixel = 0
crosshair.Parent = gui
rounded(crosshair, 4)

local winPanel = panel(gui, UDim2.fromOffset(440, 220), UDim2.fromScale(0.5, 0.48), Vector2.new(0.5, 0.5))
winPanel.Visible = false
stroke(winPanel, CYAN, 2, 0.05)
local winTitle = label(winPanel, "SYSTEM BREACHED", UDim2.new(1, -40, 0, 54), UDim2.fromOffset(20, 32), 27, CYAN, true)
winTitle.TextXAlignment = Enum.TextXAlignment.Center
local winCopy = label(winPanel, "YOU GOT THE DATA. NOW GET OUT.\nSECTOR 09 IS YOURS.", UDim2.new(1, -50, 0, 62), UDim2.fromOffset(25, 99), 14, WHITE, true)
winCopy.TextXAlignment = Enum.TextXAlignment.Center
local winButton = Instance.new("TextButton")
winButton.Size = UDim2.fromOffset(154, 38)
winButton.Position = UDim2.new(0.5, -77, 1, -53)
winButton.BackgroundColor3 = Color3.fromRGB(20, 74, 88)
winButton.Text = "RUN IT BACK"
winButton.TextColor3 = WHITE
winButton.TextSize = 12
winButton.Font = Enum.Font.GothamBold
winButton.Parent = winPanel
rounded(winButton, 8)
winButton.Activated:Connect(function()
	winPanel.Visible = false
	remote:FireServer("Restart")
end)

local toastSerial = 0
local function showToast(message: string)
	toastSerial += 1
	local current = toastSerial
	toastText.Text = message
	toast.Visible = true
	toast.BackgroundTransparency = 0.04
	task.delay(2.4, function()
		if toastSerial == current then
			local fade = TweenService:Create(toast, TweenInfo.new(0.25), {BackgroundTransparency = 1})
			fade:Play()
			fade.Completed:Wait()
			if toastSerial == current then toast.Visible = false end
		end
	end)
end

local function updateHealth()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	local ratio = math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1)
	healthFill.Size = UDim2.fromScale(ratio, 1)
	healthFill.BackgroundColor3 = ratio < 0.3 and Color3.fromRGB(255, 85, 100) or Color3.fromRGB(95, 255, 178)
	healthValue.Text = tostring(math.ceil(humanoid.Health))
end

local function bindCharacter(character: Model)
	local humanoid = character:WaitForChild("Humanoid", 10)
	if humanoid and humanoid:IsA("Humanoid") then
		humanoid.HealthChanged:Connect(updateHealth)
		task.defer(updateHealth)
	end
end
player.CharacterAdded:Connect(bindCharacter)
if player.Character then task.spawn(bindCharacter, player.Character) end

local energy = 100
remote.OnClientEvent:Connect(function(kind: string, data: any)
	if kind == "State" then
		shardsText.Text = string.format("◇  DATA SHARDS     %d / %d", data.shards, data.totalShards)
		relaysText.Text = string.format("▣  NETWORK RELAYS  %d / %d", data.relays, data.totalRelays)
		energy = data.energy
		energyValue.Text = string.format("%d%%", energy)
		energyFill.Size = UDim2.fromScale(math.clamp(energy / 100, 0, 1), 1)
		energyFill.BackgroundColor3 = energy < 25 and Color3.fromRGB(255, 116, 121) or CYAN
		if data.ready then
			objective.BackgroundColor3 = Color3.fromRGB(18, 59, 68)
		else
			objective.BackgroundColor3 = PANEL
		end
	elseif kind == "Toast" then
		showToast(data)
	elseif kind == "Win" then
		winPanel.Visible = true
	elseif kind == "Pulse" and typeof(data) == "Vector3" then
		local wave = Instance.new("Part")
		wave.Name = "Local pulse effect"
		wave.Shape = Enum.PartType.Ball
		wave.Size = Vector3.new(2, 2, 2)
		wave.Position = data
		wave.Anchored = true
		wave.CanCollide = false
		wave.Material = Enum.Material.Neon
		wave.Color = PURPLE
		wave.Transparency = 0.25
		wave.Parent = workspace
		local tween = TweenService:Create(wave, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(62, 62, 62), Transparency = 1,
		})
		tween:Play()
		tween.Completed:Connect(function() wave:Destroy() end)
	end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
		remote:FireServer("Dash")
	elseif input.KeyCode == Enum.KeyCode.Q then
		remote:FireServer("Pulse")
	end
end)

pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false) end)
