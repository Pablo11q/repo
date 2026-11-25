-- ============================================================
-- المرحلة 1: بناء العالم الأساسي — المدينة + كشك التصليح
-- المرحلة 2 (جزء السيرفر): بيانات اللاعب الأساسية
-- ============================================================

local Workspace = game:GetService("Workspace")

-- ---------- أدوات مساعدة ----------

-- إنشاء جزء (Part) بمواصفات جاهزة
local function part(props, parent)
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in pairs(props) do
		p[k] = v
	end
	p.Parent = parent
	return p
end

-- إنشاء لافتة نصية حديثة فوق جزء
local function sign(parent, text, position, size, color)
	local partP = part({
		Name = "SignPart",
		Size = size,
		Position = position,
		Color = Color3.fromRGB(30, 34, 44),
		Material = Enum.Material.Metal,
	}, parent)

	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.CanvasSize = Vector2.new(600, 200)
	gui.Parent = partP

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = color or Color3.fromRGB(0, 200, 255)
	label.Parent = gui

	return partP
end

-- إنشاء عمود إنارة حديث (عمود + رأس مضيء + نقطة ضوء)
local function streetLight(parent, x, z)
	local base = Vector3.new(x, 0, z)

	part({
		Name = "LightPole",
		Size = Vector3.new(0.6, 14, 0.6),
		Position = base + Vector3.new(0, 7, 0),
		Color = Color3.fromRGB(40, 45, 55),
		Material = Enum.Material.Metal,
	}, parent)

	local head = part({
		Name = "LightHead",
		Size = Vector3.new(3, 0.5, 1.5),
		Position = base + Vector3.new(0, 14, 0),
		Color = Color3.fromRGB(245, 245, 230),
		Material = Enum.Material.Neon,
	}, parent)

	local light = Instance.new("PointLight")
	light.Brightness = 1.5
	light.Range = 30
	light.Color = Color3.fromRGB(220, 235, 255)
	light.Parent = head
end

-- ============================================================
-- 1) مجلدات تنظيم المدينة
-- ============================================================

local City      = Instance.new("Folder"); City.Name      = "City";        City.Parent      = Workspace
local Booth     = Instance.new("Folder"); Booth.Name     = "RepairBooth"; Booth.Parent     = Workspace
local Zones     = Instance.new("Folder"); Zones.Name     = "Zones";       Zones.Parent     = Workspace
local SpawnFldr = Instance.new("Folder"); SpawnFldr.Name = "Spawn";       SpawnFldr.Parent = Workspace

-- إزالة الـ Baseplate الافتراضي إن وُجد (هنستبدله بأرضية المدينة)
local oldBase = Workspace:FindFirstChild("Baseplate")
if oldBase then
	oldBase:Destroy()
end
local oldSpawn = Workspace:FindFirstChild("SpawnLocation")
if oldSpawn then
	oldSpawn:Destroy()
end

-- ============================================================
-- 2) الأرضية
-- ============================================================

part({
	Name = "CityGround",
	Size = Vector3.new(600, 2, 600),
	Position = Vector3.new(0, -1, 0),
	Color = Color3.fromRGB(120, 124, 132),
	Material = Enum.Material.Concrete,
}, City)

-- ============================================================
-- 3) الطريق الرئيسي وشوارع المدينة
-- ============================================================

local ROAD_COLOR = Color3.fromRGB(45, 47, 54)
local ROAD_WIDTH = 16
local CITY_HALF  = 300

part({
	Name = "MainRoad_NS",
	Size = Vector3.new(ROAD_WIDTH, 0.4, CITY_HALF * 2),
	Position = Vector3.new(0, 0.2, 0),
	Color = ROAD_COLOR,
	Material = Enum.Material.Asphalt,
}, City)

part({
	Name = "Street_EW_North",
	Size = Vector3.new(CITY_HALF * 2, 0.4, ROAD_WIDTH),
	Position = Vector3.new(0, 0.2, -120),
	Color = ROAD_COLOR,
	Material = Enum.Material.Asphalt,
}, City)

part({
	Name = "Street_EW_South",
	Size = Vector3.new(CITY_HALF * 2, 0.4, ROAD_WIDTH),
	Position = Vector3.new(0, 0.2, 120),
	Color = ROAD_COLOR,
	Material = Enum.Material.Asphalt,
}, City)

-- خطوط التقسيم البيضاء على الطريق الرئيسي
for z = -290, 290, 12 do
	if not (z > -130 and z < -110) and not (z > 110 and z < 130) then
		part({
			Name = "RoadDash",
			Size = Vector3.new(0.5, 0.05, 5),
			Position = Vector3.new(0, 0.45, z),
			Color = Color3.fromRGB(235, 235, 235),
			Material = Enum.Material.SmoothPlastic,
			CanCollide = false,
		}, City)
	end
end

-- أرصفة على جانبي الطريق الرئيسي
for _, side in ipairs({-1, 1}) do
	part({
		Name = "Sidewalk_NS",
		Size = Vector3.new(4, 0.5, CITY_HALF * 2),
		Position = Vector3.new(side * (ROAD_WIDTH / 2 + 2), 0.25, 0),
		Color = Color3.fromRGB(190, 192, 198),
		Material = Enum.Material.Concrete,
	}, City)
end

-- أرصفة على جانبي الشارعين العرضيين
for _, z in ipairs({-120, 120}) do
	for _, side in ipairs({-1, 1}) do
		part({
			Name = "Sidewalk_EW",
			Size = Vector3.new(CITY_HALF * 2, 0.5, 4),
			Position = Vector3.new(0, 0.25, z + side * (ROAD_WIDTH / 2 + 2)),
			Color = Color3.fromRGB(190, 192, 198),
			Material = Enum.Material.Concrete,
		}, City)
	end
end

-- ============================================================
-- 4) إضاءة الشوارع الحديثة
-- ============================================================

for z = -240, 240, 80 do
	streetLight(City, ROAD_WIDTH / 2 + 5, z)
	streetLight(City, -(ROAD_WIDTH / 2 + 5), z + 40)
end

-- ============================================================
-- 5) كشك التصليح (نقطة البداية) — حديث وصغير
-- ============================================================

local BOOTH_POS = Vector3.new(-14, 0, -40)

part({
	Name = "BoothFloor",
	Size = Vector3.new(18, 1, 14),
	Position = BOOTH_POS + Vector3.new(0, 0.5, 0),
	Color = Color3.fromRGB(70, 76, 88),
	Material = Enum.Material.Metal,
}, Booth)

local colOffsets = {{-7, -5}, {7, -5}, {-7, 5}, {7, 5}}
for i, off in ipairs(colOffsets) do
	part({
		Name = "BoothColumn" .. i,
		Size = Vector3.new(1, 10, 1),
		Position = BOOTH_POS + Vector3.new(off[1], 6, off[2]),
		Color = Color3.fromRGB(35, 40, 50),
		Material = Enum.Material.Metal,
	}, Booth)
end

part({
	Name = "BoothRoof",
	Size = Vector3.new(19, 0.8, 15),
	Position = BOOTH_POS + Vector3.new(0, 11.4, 0),
	Color = Color3.fromRGB(50, 55, 66),
	Material = Enum.Material.Metal,
}, Booth)

part({
	Name = "BoothRoofNeon",
	Size = Vector3.new(19.4, 0.3, 15.4),
	Position = BOOTH_POS + Vector3.new(0, 10.9, 0),
	Color = Color3.fromRGB(0, 200, 255),
	Material = Enum.Material.Neon,
	CanCollide = false,
}, Booth)

sign(Booth, "🔧 REPAIR BOOTH", BOOTH_POS + Vector3.new(0, 9.2, -7.6), Vector3.new(14, 3, 0.4))

-- منصة/طاولة العمل الرئيسية
part({
	Name = "WorkTable",
	Size = Vector3.new(6, 3, 3),
	Position = BOOTH_POS + Vector3.new(0, 2.5, -3),
	Color = Color3.fromRGB(90, 96, 108),
	Material = Enum.Material.DiamondPlate,
}, Booth)

part({
	Name = "WorkTableNeon",
	Size = Vector3.new(5, 1.5, 0.2),
	Position = BOOTH_POS + Vector3.new(0, 2.5, -1.4),
	Color = Color3.fromRGB(0, 200, 255),
	Material = Enum.Material.Neon,
	CanCollide = false,
}, Booth)

-- ============================================================
-- 6) SpawnLocation — نقطة الظهور الآمنة قرب الكشك
-- ============================================================

local spawnLoc = Instance.new("SpawnLocation")
spawnLoc.Name = "StartSpawn"
spawnLoc.Size = Vector3.new(12, 1, 12)
spawnLoc.Position = Vector3.new(-14, 0.5, -25)
spawnLoc.Anchored = true
spawnLoc.Color = Color3.fromRGB(60, 66, 78)
spawnLoc.Material = Enum.Material.Metal
spawnLoc.Duration = 0
spawnLoc.Parent = SpawnFldr

part({
	Name = "SpawnNeonRing",
	Size = Vector3.new(13, 0.3, 13),
	Position = Vector3.new(-14, 0.15, -25),
	Color = Color3.fromRGB(0, 200, 255),
	Material = Enum.Material.Neon,
	CanCollide = false,
}, SpawnFldr)

-- ============================================================
-- 7) المناطق المخصصة للمستقبل (معلّمة بلافتات وأرضيات)
-- ============================================================

-- منطقة تطور المحل/المصنع — غرب المدينة
local factoryZone = Instance.new("Folder")
factoryZone.Name = "FactoryZone"
factoryZone.Parent = Zones

part({
	Name = "FactoryZoneFloor",
	Size = Vector3.new(80, 0.4, 80),
	Position = Vector3.new(-140, 0.2, 40),
	Color = Color3.fromRGB(100, 106, 120),
	Material = Enum.Material.Concrete,
}, factoryZone)

sign(factoryZone, "🏭 FACTORY / SHOP ZONE", Vector3.new(-140, 8, -1), Vector3.new(30, 6, 0.5))

-- منطقة البيوت — شرق المدينة
local homesZone = Instance.new("Folder")
homesZone.Name = "HomesZone"
homesZone.Parent = Zones

part({
	Name = "HomesZoneFloor",
	Size = Vector3.new(100, 0.4, 100),
	Position = Vector3.new(160, 0.2, 40),
	Color = Color3.fromRGB(110, 150, 120),
	Material = Enum.Material.Grass,
}, homesZone)

sign(homesZone, "🏠 HOMES ZONE", Vector3.new(160, 8, -11), Vector3.new(30, 6, 0.5))

-- معرض العربيات — جنوب المدينة
local carZone = Instance.new("Folder")
carZone.Name = "CarDealerZone"
carZone.Parent = Zones

part({
	Name = "CarDealerZoneFloor",
	Size = Vector3.new(90, 0.4, 70),
	Position = Vector3.new(0, 0.2, 220),
	Color = Color3.fromRGB(105, 110, 125),
	Material = Enum.Material.Concrete,
}, carZone)

sign(carZone, "🚗 CAR DEALER", Vector3.new(0, 8, 184), Vector3.new(30, 6, 0.5))

print("✅ المرحلة 1 اكتملت: المدينة الأساسية + كشك التصليح + المناطق المخصصة جاهزة.")

-- ============================================================
-- المرحلة 2 (جزء السيرفر): بيانات اللاعب الأساسية
-- ============================================================

local Players = game:GetService("Players")

local START_CASH = 50
local START_LEVEL = 1

local function setupPlayer(player)
	-- مجلد بيانات اللاعب
	local data = Instance.new("Folder")
	data.Name = "PlayerData"

	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = START_CASH
	cash.Parent = data

	local level = Instance.new("IntValue")
	level.Name = "Level"
	level.Value = START_LEVEL
	level.Parent = data

	-- وقت اليوم: من 0 إلى 1 (0=فجر، 0.5=ظهر، 0.75=غروب، 1=نهاية اليوم)
	local dayTime = Instance.new("NumberValue")
	dayTime.Name = "DayTime"
	dayTime.Value = 0
	dayTime.Parent = data

	data.Parent = player

	-- إشعار ترحيب بسيط في الـ Output للسيرفر
	print("✅ بيانات اللاعب جاهزة: " .. player.Name .. " (Cash=" .. START_CASH .. ", Level=" .. START_LEVEL .. ")")
end

Players.PlayerAdded:Connect(setupPlayer)

-- للاعبين الموجودين مسبقاً (حماية من سباق التحميل — بدون WaitForChild لا نهائي)
for _, player in ipairs(Players:GetPlayers()) do
	if not player:FindFirstChild("PlayerData") then
		task.spawn(setupPlayer, player)
	end
end

print("✅ المرحلة 2 (سيرفر): نظام بيانات اللاعب يعمل.")
