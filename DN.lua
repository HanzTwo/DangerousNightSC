-- [[ KONFIGURASI WORKER ]] --
local WORKER_URL = "https://gatedn.hanztwo10.workers.dev"
local CLIENT_TOKEN = "TOKEN_RAHASIA_HANZ_2026"

-- [[ LAYANAN ROBLOX ]] --
local rawReq = request or http_request or (http and http.request)
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- [[ CUSTOM MODERN NOTIFICATION UI ]] --
local function Notify(title, text, notifType)
    task.spawn(function()
        local parentGui = (gethui and gethui()) or CoreGui
        local existing = parentGui:FindFirstChild("HanzGateNotify")
        if existing then existing:Destroy() end

        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "HanzGateNotify"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ScreenGui.Parent = parentGui

        -- Tentukan warna aksen berdasarkan status
        local accentColor = Color3.fromRGB(180, 0, 0) -- Merah Crimson (Default / Error)
        local badgeText = "DENIED"
        if notifType == "success" then
            accentColor = Color3.fromRGB(46, 204, 113) -- Hijau Modern
            badgeText = "VERIFIED"
        elseif notifType == "loading" then
            accentColor = Color3.fromRGB(241, 196, 15) -- Kuning Emas
            badgeText = "CHECKING"
        end

        -- Container Utama
        local MainFrame = Instance.new("Frame")
        MainFrame.Size = UDim2.new(0, 270, 0, 68)
        MainFrame.Position = UDim2.new(1, 20, 1, -85) -- Mulai dari luar layar kanan
        MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
        MainFrame.BorderSizePixel = 0
        MainFrame.Parent = ScreenGui

        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 10)
        UICorner.Parent = MainFrame

        local UIStroke = Instance.new("UIStroke")
        UIStroke.Color = accentColor
        UIStroke.Thickness = 1.3
        UIStroke.Transparency = 0.25
        UIStroke.Parent = MainFrame

        -- Garis Aksen Kiri
        local AccentBar = Instance.new("Frame")
        AccentBar.Size = UDim2.new(0, 4, 1, -16)
        AccentBar.Position = UDim2.new(0, 8, 0, 8)
        AccentBar.BackgroundColor3 = accentColor
        AccentBar.BorderSizePixel = 0
        AccentBar.Parent = MainFrame

        local BarCorner = Instance.new("UICorner")
        BarCorner.CornerRadius = UDim.new(1, 0)
        BarCorner.Parent = AccentBar

        -- Judul Notifikasi
        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Size = UDim2.new(1, -85, 0, 20)
        TitleLabel.Position = UDim2.new(0, 20, 0, 10)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Text = tostring(title)
        TitleLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.TextSize = 13
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.Parent = MainFrame

        -- Badge Status (Kanan Atas)
        local BadgeLabel = Instance.new("TextLabel")
        BadgeLabel.Size = UDim2.new(0, 58, 0, 16)
        BadgeLabel.Position = UDim2.new(1, -68, 0, 12)
        BadgeLabel.BackgroundColor3 = accentColor
        BadgeLabel.BackgroundTransparency = 0.82
        BadgeLabel.Text = badgeText
        BadgeLabel.TextColor3 = accentColor
        BadgeLabel.Font = Enum.Font.GothamBold
        BadgeLabel.TextSize = 9
        BadgeLabel.Parent = MainFrame

        local BadgeCorner = Instance.new("UICorner")
        BadgeCorner.CornerRadius = UDim.new(0, 4)
        BadgeCorner.Parent = BadgeLabel

        -- Pesan Isi
        local DescLabel = Instance.new("TextLabel")
        DescLabel.Size = UDim2.new(1, -30, 0, 26)
        DescLabel.Position = UDim2.new(0, 20, 0, 32)
        DescLabel.BackgroundTransparency = 1
        DescLabel.Text = tostring(text)
        DescLabel.TextColor3 = Color3.fromRGB(185, 185, 195)
        DescLabel.Font = Enum.Font.Gotham
        DescLabel.TextSize = 11
        DescLabel.TextWrapped = true
        DescLabel.TextXAlignment = Enum.TextXAlignment.Left
        DescLabel.TextYAlignment = Enum.TextYAlignment.Top
        DescLabel.Parent = MainFrame

        -- Animasi Masuk (Slide-in)
        local tweenIn = TweenService:Create(
            MainFrame,
            TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            { Position = UDim2.new(1, -285, 1, -85) }
        )
        tweenIn:Play()

        task.wait(4.2)

        -- Animasi Keluar (Slide-out)
        if MainFrame and MainFrame.Parent then
            local tweenOut = TweenService:Create(
                MainFrame,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                { Position = UDim2.new(1, 20, 1, -85) }
            )
            tweenOut:Play()
            tweenOut.Completed:Wait()
        end

        if ScreenGui then ScreenGui:Destroy() end
    end)
end

-- [[ 1. DETEKSI HTTP SPY & HOOK ]] --
if not rawReq then
    Notify("System Error", "Executor tidak mendukung HTTP Request", "error")
    return
end

local function CheckSpyEnvironment()
    if iscclosure then
        local checks = {
            ["loadstring"] = loadstring,
            ["HttpGet"] = game.HttpGet,
            ["request"] = rawReq,
            ["print"] = print
        }
        for name, fn in pairs(checks) do
            if type(fn) == "function" and not iscclosure(fn) then
                return true, "Hooked function: " .. name
            end
        end
    end

    if getgenv then
        local env = getgenv()
        if env.SimpleSpyExecuted or env.HttpSpy or env.Hydroxide then
            return true, "Spy Global Terdeteksi"
        end
    end

    return false, nil
end

local isSpy, spyReason = CheckSpyEnvironment()

if isSpy then
    pcall(function()
        rawReq({
            Url = WORKER_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["X-Client-Token"] = CLIENT_TOKEN
            },
            Body = HttpService:JSONEncode({
                username = LocalPlayer.Name,
                displayName = LocalPlayer.DisplayName,
                userId = LocalPlayer.UserId,
                placeId = game.PlaceId,
                spyDetected = true,
                spyReason = spyReason
            })
        })
    end)
    return
end

-- [[ 2. AUTENTIKASI KE CLOUDFLARE WORKER ]] --
Notify("Hanz Gate", "Memverifikasi akses akun...", "loading")

local success, res = pcall(function()
    return rawReq({
        Url = WORKER_URL,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["X-Client-Token"] = CLIENT_TOKEN
        },
        Body = HttpService:JSONEncode({
            username = LocalPlayer.Name,
            displayName = LocalPlayer.DisplayName,
            userId = LocalPlayer.UserId,
            placeId = game.PlaceId
        })
    })
end)

if not success or not res or res.StatusCode ~= 200 then
    Notify("Koneksi Gagal", "Gagal terhubung ke server autentikasi", "error")
    return
end

local okDecode, data = pcall(function()
    return HttpService:JSONDecode(res.Body)
end)

if not okDecode or type(data) ~= "table" then
    Notify("System Gate", "Respon server tidak valid", "error")
    return
end

-- [[ 3. EKSEKUSI SESUAI STATUS SERVER ]] --
if data.status == "NOT_WHITELISTED" then
    Notify("Akses Ditolak", "USERNAME BELUM TERDAFTAR", "error")
    return
elseif data.status == "WRONG_MAP" then
    Notify("Akses Ditolak", "ID MAP TIDAK SESUAI", "error")
    return
elseif data.status == "OK" and data.payload then
    getgenv().UserRole = tostring(data.role)
    Notify("Akses Diterima", LocalPlayer.Name .. " [" .. tostring(data.role) .. "]", "success")

    local exec, err = loadstring(data.payload)
    if exec then
        task.spawn(exec)
    else
        warn("[Gate Error]:", err)
    end
else
    Notify("System Gate", "Error: " .. tostring(data.status), "error")
end
