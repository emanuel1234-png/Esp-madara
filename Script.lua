--[[
    Madara ESP Script para Roblox
    Autor: Você
    Descrição:
    Exibe "MADARA MODS" sobre todos os players,
    desenha uma linha do centro da tela até eles,
    com botão para ativar/desativar.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESPEnabled = false
local BillboardGuis = {}
local Lines = {}

-- Cria UI de controle
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "MadaraESPControl"

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 200, 0, 50)
ToggleButton.Position = UDim2.new(0, 20, 0, 100)
ToggleButton.Text = "Ativar ESP"
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextScaled = true
ToggleButton.Parent = ScreenGui

local function createBillboard(player)
    local char = player.Character
    if not char then return nil end
    local head = char:FindFirstChild("Head")
    if not head then return nil end

    local bb = Instance.new("BillboardGui")
    bb.Name = "MadaraESP"
    bb.Adornee = head
    bb.Size = UDim2.new(0, 100, 0, 30)
    bb.StudsOffset = Vector3.new(0, 2.5, 0)
    bb.AlwaysOnTop = true

    local label = Instance.new("TextLabel", bb)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = "MADARA MODS"
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 0, 0)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.SourceSansBold
    label.TextScaled = true

    bb.Parent = head
    return bb
end

local function createLine()
    local line = Drawing.new("Line")
    line.Color = Color3.fromRGB(255, 0, 0)
    line.Thickness = 2
    line.Visible = true
    return line
end

local function enableESP()
    if ESPEnabled then return end
    ESPEnabled = true
    ToggleButton.Text = "Desativar ESP"
    ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local bb = createBillboard(player)
            BillboardGuis[player] = bb

            local line = createLine()
            Lines[player] = line
        end
    end
end

local function disableESP()
    ESPEnabled = false
    ToggleButton.Text = "Ativar ESP"
    ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)

    for _, bb in pairs(BillboardGuis) do
        if bb then bb:Destroy() end
    end
    BillboardGuis = {}

    for _, line in pairs(Lines) do
        if line then
            line.Visible = false
            line:Remove()
        end
    end
    Lines = {}
end

ToggleButton.MouseButton1Click:Connect(function()
    if ESPEnabled then
        disableESP()
    else
        enableESP()
    end
end)

RunService.RenderStepped:Connect(function()
    if not ESPEnabled then return end

    for player, line in pairs(Lines) do
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position)
            local screenPos = Vector2.new(pos.X, pos.Y)
            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)

            if onScreen then
                line.From = screenCenter
                line.To = screenPos
                line.Visible = true
            else
                line.Visible = false
            end
        else
            line.Visible = false
        end
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if ESPEnabled then
            local bb = createBillboard(player)
            BillboardGuis[player] = bb

            local line = createLine()
            Lines[player] = line
        end
    end)
end)
