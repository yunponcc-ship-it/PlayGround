--!strict
-- Neon Breakout: a small, server-authoritative hacking parkour experience.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local remote = Instance.new("RemoteEvent")
remote.Name = "GlitchCityEvent"
remote.Parent = ReplicatedStorage

local oldWorld = workspace:FindFirstChild("GlitchCity")
if oldWorld then oldWorld:Destroy() end
local world = Instance.new("Folder")
world.Name = "GlitchCity"
world.Parent = workspace

Lighting.ClockTime = 0
Lighting.Brightness = 2
Lighting.Ambient = Color3.fromRGB(28, 38, 78)
Lighting.OutdoorAmbient = Color3.fromRGB(15, 20, 45)
Lighting.FogColor = Color3.fromRGB(15, 26, 62)
Lighting.FogStart = 140
Lighting.FogEnd = 600

local CYAN = Color3.fromRGB(42, 244, 255)
local PURPLE = Color3.fromRGB(150, 73, 255)
local PINK = Color3.fromRGB(255, 62, 173)
local DARK = Color3.fromRGB(13, 17, 38)
local GOLD = Color3.fromRGB(255, 207, 87)

local function part(name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material?, parent: Instance?): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Position = position
	p.Anchored = true
	p.Material = material or Enum.Material.SmoothPlastic
	p.Color = color
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent or world
	return p
end

local function neonLine(name: string, size: Vector3, position: Vector3, color: Color3)
	local p = part(name, size, position, color, Enum.Material.Neon)
	p.CanCollide = false
	return p
end

-- The floating city course.
part("The Rooftop", Vector3.new(72, 4, 58), Vector3.new(0, 0, 4), Color3.fromRGB(24, 31, 57), Enum.Material.Slate)
part("Rooftop rim", Vector3.new(73, 0.5, 59), Vector3.new(0, 2.2, 4), CYAN, Enum.Material.Neon).CanCollide = false
part("Checkpoint 01", Vector3.new(48, 3, 38), Vector3.new(0, 8, -54), Color3.fromRGB(34, 30, 70), Enum.Material.Slate)
part("Checkpoint 02", Vector3.new(46, 3, 38), Vector3.new(20, 17, -111), Color3.fromRGB(34, 30, 70), Enum.Material.Slate)
part("Checkpoint 03", Vector3.new(48, 3, 38), Vector3.new(-12, 27, -168), Color3.fromRGB(34, 30, 70), Enum.Material.Slate)
part("Extraction platform", Vector3.new(64, 4, 54), Vector3.new(0, 37, -225), Color3.fromRGB(24, 31, 57), Enum.Material.Slate)

-- Bright edge strips give the route a readable silhouette.
for _, stage in ipairs({
	{center = Vector3.new(0, 8, -54), width = 48, depth = 38},
	{center = Vector3.new(20, 17, -111), width = 46, depth = 38},
	{center = Vector3.new(-12, 27, -168), width = 48, depth = 38},
	{center = Vector3.new(0, 37, -225), width = 64, depth = 54},
}) do
	local center, width, depth = stage.center, stage.width, stage.depth
	neonLine("Platform edge", Vector3.new(width + 0.4, 0.35, 0.45), center + Vector3.new(0, 1.7, 0), PURPLE)
	neonLine("Platform edge", Vector3.new(0.45, 0.35, depth + 0.4), center + Vector3.new(width / 2, 1.7, 0), CYAN)
	neonLine("Platform edge", Vector3.new(0.45, 0.35, depth + 0.4), center + Vector3.new(-width / 2, 1.7, 0), CYAN)
end

-- Floating stepping stones lead players through the gaps.
local stones = {
	{Vector3.new(-16, 3, -27), Vector3.new(13, 2, 12)},
	{Vector3.new(15, 5, -34), Vector3.new(12, 2, 11)},
	{Vector3.new(7, 7, -78), Vector3.new(11, 2, 11)},
	{Vector3.new(25, 11, -85), Vector3.new(12, 2, 12)},
	{Vector3.new(4, 12, -136), Vector3.new(12, 2, 12)},
	{Vector3.new(-19, 20, -143), Vector3.new(12, 2, 11)},
	{Vector3.new(-22, 23, -196), Vector3.new(12, 2, 12)},
	{Vector3.new(16, 30, -198), Vector3.new(12, 2, 12)},
}
for i, stone in ipairs(stones) do
	part("Jump pad " .. i, stone[2], stone[1], Color3.fromRGB(37, 46, 88), Enum.Material.Metal)
	neonLine("Jump pad glow", Vector3.new(stone[2].X - 1, 0.2, 0.35), stone[1] + Vector3.new(0, 1.1, 0), CYAN)
end

-- Distant stylized skyline around the playable route.
math.randomseed(22)
for i = 1, 32 do
	local x = (i % 2 == 0 and 1 or -1) * math.random(58, 140)
	local z = -math.random(15, 260)
	local height = math.random(24, 90)
	local width = math.random(9, 20)
	local building = part("Distant tower", Vector3.new(width, height, width), Vector3.new(x, height / 2 - 7, z), Color3.fromRGB(math.random(18, 30), math.random(22, 38), math.random(48, 80)), Enum.Material.Slate)
	building.CanCollide = false
	local glow = neonLine("Tower light", Vector3.new(0.35, height * 0.72, 0.35), building.Position + Vector3.new(width / 2 + 0.2, 0, 0), i % 2 == 0 and CYAN or PINK)
	glow.Transparency = 0.14
end

-- Spawn and mission signage.
local spawn = Instance.new("SpawnLocation")
spawn.Name = "Runner spawn"
spawn.Size = Vector3.new(10, 1, 10)
spawn.Position = Vector3.new(0, 2.7, 13)
spawn.Anchored = true
spawn.Neutral = true
spawn.Material = Enum.Material.Neon
spawn.Color = Color3.fromRGB(32, 91, 112)
spawn.Transparency = 0.12
spawn.Parent = world

local sign = part("Mission sign", Vector3.new(22, 8, 1), Vector3.new(0, 8, 27), DARK, Enum.Material.SmoothPlastic)
local surface = Instance.new("SurfaceGui")
surface.Face = Enum.NormalId.Front
surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
surface.PixelsPerStud = 32
surface.Parent = sign
local signText = Instance.new("TextLabel")
signText.Size = UDim2.fromScale(1, 1)
signText.BackgroundTransparency = 1
signText.Text = "NEON BREAKOUT\nCOLLECT DATA  /  HACK RELAYS  /  ESCAPE"
signText.TextColor3 = CYAN
signText.TextScaled = true
signText.Font = Enum.Font.GothamBlack
signText.Parent = surface

-- State is per player; the server remains the source of truth.
type PlayerState = { shards: {[number]: boolean}, relays: {[number]: boolean}, energy: number, nextDash: number, nextPulse: number, lastDamage: number, won: boolean }
local states: {[Player]: PlayerState} = {}
local shardParts: {BasePart} = {}
local relayParts: {BasePart} = {}
local drones: {{part: BasePart, base: Vector3, phase: number, stunnedUntil: number}} = {}
local exitPad: BasePart

local function progress(player: Player)
	local state = states[player]
	if not state then return end
	local shardCount, relayCount = 0, 0
	for _ in pairs(state.shards) do shardCount += 1 end
	for _ in pairs(state.relays) do relayCount += 1 end
	remote:FireClient(player, "State", {
		shards = shardCount,
		totalShards = #shardParts,
		relays = relayCount,
		totalRelays = #relayParts,
		energy = math.floor(state.energy),
		won = state.won,
		ready = shardCount >= #shardParts and relayCount >= #relayParts,
	})
end

local shardPositions = {
	Vector3.new(-17, 5, -12), Vector3.new(14, 11, -46), Vector3.new(-8, 11, -60),
	Vector3.new(20, 20, -101), Vector3.new(3, 19, -119), Vector3.new(17, 14, -132),
	Vector3.new(-20, 30, -158), Vector3.new(-4, 31, -178), Vector3.new(17, 40, -218),
	Vector3.new(-17, 40, -236),
}
for i, position in ipairs(shardPositions) do
	local shard = part("Data shard " .. i, Vector3.new(2.4, 2.4, 2.4), position, GOLD, Enum.Material.Neon)
	shard.Shape = Enum.PartType.Ball
	shard.CanCollide = false
	shard:SetAttribute("ShardId", i)
	local light = Instance.new("PointLight")
	light.Color = GOLD
	light.Brightness = 1.5
	light.Range = 10
	light.Parent = shard
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromOffset(60, 24)
	billboard.StudsOffset = Vector3.new(0, 1.8, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = shard
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = "DATA"
	label.TextColor3 = GOLD
	label.TextStrokeTransparency = 0.4
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = billboard
	shardParts[i] = shard
end

for i, position in ipairs({Vector3.new(-14, 8, -52), Vector3.new(29, 17, -112), Vector3.new(-2, 27, -168)}) do
	local relayId = i
	local terminal = part("Relay " .. relayId, Vector3.new(5, 7, 4), position, Color3.fromRGB(23, 39, 67), Enum.Material.Metal)
	local screen = part("Relay screen", Vector3.new(3.2, 3.8, 0.18), position + Vector3.new(0, 0.2, -2.05), CYAN, Enum.Material.Neon, terminal)
	screen.CanCollide = false
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Breach relay"
	prompt.ObjectText = string.format("NETWORK RELAY %02d", relayId)
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.HoldDuration = 1.1
	prompt.MaxActivationDistance = 11
	prompt.RequiresLineOfSight = false
	prompt.Parent = terminal
	prompt.Triggered:Connect(function(player)
		local state = states[player]
		if not state or state.relays[relayId] then return end
		state.relays[relayId] = true
		terminal.Color = Color3.fromRGB(24, 104, 115)
		local screen = terminal:FindFirstChild("Relay screen")
		if screen and screen:IsA("BasePart") then screen.Color = Color3.fromRGB(47, 255, 208) end
		remote:FireClient(player, "Toast", "RELAY BREACHED  •  +250 XP")
		progress(player)
	end)
	relayParts[i] = terminal
end

-- Enemies are simple server-owned sentry orbs. A pulse stuns nearby ones briefly.
for i, position in ipairs({Vector3.new(5, 10, -38), Vector3.new(27, 21, -121), Vector3.new(-23, 31, -181), Vector3.new(13, 42, -239)}) do
	local drone = part("Sentinel " .. i, Vector3.new(3.5, 3.5, 3.5), position, PINK, Enum.Material.Neon)
	drone.Shape = Enum.PartType.Ball
	drone.CanCollide = false
	local ring = part("Sentinel ring", Vector3.new(5.5, 0.22, 5.5), position + Vector3.new(0, -0.5, 0), CYAN, Enum.Material.Neon)
	ring.Shape = Enum.PartType.Cylinder
	ring.CanCollide = false
	table.insert(drones, {part = drone, base = position, phase = i * 1.7, stunnedUntil = 0})
end

local gate = part("Extraction gate", Vector3.new(22, 16, 2), Vector3.new(0, 47, -247), PINK, Enum.Material.Neon)
gate.Transparency = 0.22
gate.CanCollide = true
exitPad = part("Escape beacon", Vector3.new(12, 0.6, 12), Vector3.new(0, 39.5, -225), CYAN, Enum.Material.Neon)
exitPad.Transparency = 0.25
exitPad.CanCollide = false

local function onCharacter(player: Player, character: Model)
	local humanoid = character:WaitForChild("Humanoid", 10)
	if humanoid and humanoid:IsA("Humanoid") then
		humanoid.WalkSpeed = 19
		humanoid.JumpPower = 55
	end
end

local function setupPlayer(player: Player)
	states[player] = {shards = {}, relays = {}, energy = 100, nextDash = 0, nextPulse = 0, lastDamage = 0, won = false}
	player.CharacterAdded:Connect(function(character) onCharacter(player, character) end)
	if player.Character then task.spawn(onCharacter, player, player.Character) end
	task.delay(1, function() if player.Parent then progress(player) end end)
end
Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player) states[player] = nil end)
for _, player in ipairs(Players:GetPlayers()) do setupPlayer(player) end

remote.OnServerEvent:Connect(function(player, action)
	local state = states[player]
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not state or not root or not root:IsA("BasePart") or not humanoid or humanoid.Health <= 0 then return end
	local now = os.clock()
	if action == "Restart" then
		states[player] = {shards = {}, relays = {}, energy = 100, nextDash = 0, nextPulse = 0, lastDamage = 0, won = false}
		root.CFrame = CFrame.new(0, 7, 13)
		progress(player)
		remote:FireClient(player, "Toast", "ROUTE RESET  •  GOOD LUCK")
	elseif action == "Dash" then
		if now < state.nextDash or state.energy < 25 then return end
		state.nextDash = now + 3.5
		state.energy -= 25
		local direction = humanoid.MoveDirection
		if direction.Magnitude < 0.1 then direction = root.CFrame.LookVector end
		root.AssemblyLinearVelocity = Vector3.new(direction.X * 72, math.max(root.AssemblyLinearVelocity.Y, 10), direction.Z * 72)
		remote:FireClient(player, "Toast", "GLITCH DASH")
		progress(player)
	elseif action == "Pulse" then
		if now < state.nextPulse or state.energy < 40 then return end
		state.nextPulse = now + 8
		state.energy -= 40
		for _, drone in ipairs(drones) do
			if (drone.part.Position - root.Position).Magnitude <= 34 then
				drone.stunnedUntil = now + 4
			end
		end
		remote:FireClient(player, "Pulse", root.Position)
		remote:FireClient(player, "Toast", "SYSTEM PULSE  •  SENTINELS DISABLED")
		progress(player)
	end
end)

-- Server-side pickups, sentry damage, energy regen and escape validation.
local lastSync = 0
RunService.Heartbeat:Connect(function(dt)
	local now = os.clock()
	for _, player in ipairs(Players:GetPlayers()) do
		local state = states[player]
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if state then
			state.energy = math.min(100, state.energy + dt * 11)
			if root and root:IsA("BasePart") and humanoid and humanoid.Health > 0 then
				for i, shard in ipairs(shardParts) do
					if not state.shards[i] and (shard.Position - root.Position).Magnitude < 5 then
						state.shards[i] = true
						remote:FireClient(player, "Toast", "DATA SECURED  •  +100 XP")
						progress(player)
					end
				end
				for _, drone in ipairs(drones) do
					local bob = math.sin(now * 1.8 + drone.phase) * 2
					if now >= drone.stunnedUntil then
						drone.part.Position = drone.base + Vector3.new(math.sin(now + drone.phase) * 5, bob, math.cos(now * 0.7 + drone.phase) * 4)
						drone.part.Color = PINK
					else
					drone.part.Position = drone.base + Vector3.new(0, bob, 0)
					drone.part.Color = CYAN
				end
				if now >= drone.stunnedUntil and (drone.part.Position - root.Position).Magnitude < 4 and now - state.lastDamage > 1.2 then
					state.lastDamage = now
					humanoid:TakeDamage(12)
					remote:FireClient(player, "Toast", "SENTINEL HIT  •  PULSE TO STUN")
				end
			end
				local shardCount, relayCount = 0, 0
				for _ in pairs(state.shards) do shardCount += 1 end
				for _ in pairs(state.relays) do relayCount += 1 end
				if shardCount >= #shardParts and relayCount >= #relayParts and not state.won and (exitPad.Position - root.Position).Magnitude < 10 then
					state.won = true
					gate.CanCollide = false
					gate.Transparency = 0.85
					remote:FireClient(player, "Win")
					progress(player)
				end
			end
		end
	end
	if now - lastSync > 1 then
		lastSync = now
		for _, player in ipairs(Players:GetPlayers()) do progress(player) end
	end
end)
