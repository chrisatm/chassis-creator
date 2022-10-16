local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")

local Utilities = ReplicatedStorage:FindFirstChild("Utilities")
local PropertyApplierModule = Utilities:FindFirstChild("PropertyApplier")
local PropertyApplier = require(PropertyApplierModule)
local CornersModule = require(script.Parent.Corners)

local VehSeat = require(script.Parent.VehSeat)

local Signals = ReplicatedStorage:FindFirstChild("Signals")
local SeatedSignal = Instance.new("RemoteEvent")
SeatedSignal.Name = "PlayerSeated"
SeatedSignal.Parent = Signals

local PlatformSize = Vector3.new(9, 1, 18.5)
local Platform = nil

local SeatCount = 1
local Seats = nil

local MassPartSize = Vector3.new(4, 4, 4)

local WheelConfig = "Standard"
local WheelCount = 4
local WheelSize = Vector3.new(3, 3, 3)
local Wheels = nil

local Corners = nil
local Suspension = nil
local MasterChassisModel = nil

local function CreateWheels()
	-- clone platform a delete any children in cloned platform
	local WheelBase = Platform:Clone()
	for i,v in pairs(WheelBase:GetChildren()) do
		v:Destroy()
		v = nil
	end
	-- apply properties to platform
	local properties = {
		["Instance"] = WheelBase,
		["Name"] = "WheelBase",
		["Parent"] = MasterChassisModel,
		["CanCollide"] = false,
		["Size"] = (PlatformSize / 1.5) + (Vector3.new(0, Platform.Size.Y * 2, 0)),
	}
	PropertyApplier.new(properties)
	
	-- create weld from platform to wheelbase
	local WheelBaseWeld = Instance.new("WeldConstraint")
	local WheelBaseWeldProperties = {
		["Instance"] = WheelBaseWeld,
		["Name"] = "WheelBase",
		["Parent"] = Platform,
		["Enabled"] = true,
		["Part0"] = Platform,
		["Part1"] = WheelBase,
	}
	PropertyApplier.new(WheelBaseWeldProperties)
	
	-- get the corners of wheelbase
	Corners = CornersModule.new(WheelBase).Corners
	-- create wheels (spheres) on the bottom four corners
	local Wheels = {}
	for corner, pos in pairs(Corners.BottomSide) do
		local Wheel = Instance.new("Part")
		local wheelProperties = {
			["Instance"] = Wheel,
			["Name"] = string.gsub(corner, "bottom", "") .. "Wheel",
			["Parent"] = MasterChassisModel,
			["Position"] = pos,
			["Transparency"] = 0.5,
			["Anchored"] = false,
			["CanCollide"] = true,
			["Size"] = WheelSize,
			["Shape"] = Enum.PartType.Ball,
		}
		PropertyApplier.new(wheelProperties)
		table.insert(Wheels, Wheel)
	end
	Platform.Position += Vector3.new(0, WheelSize.Y / 2, 0)

	-- apply weldconstraints to wheels
	for i, wheel in pairs(Wheels) do
		local WheelWeld = Instance.new("WeldConstraint")
		local WheelWeldProperties = {
			["Instance"] = WheelWeld,
			["Name"] = wheel.Name .. "Weld",
			["Parent"] = Platform,
			["Enabled"] = false,
			["Part0"] = Platform,
			["Part1"] = wheel,
		}
		PropertyApplier.new(WheelWeldProperties)
	end
	return Wheels
end

local function CreateSuspension()

	local suspension = {
		["Attachments"] = {
			["All"] = {},
			["Verticals"] = {
				["FrontRight"] = {
					["Top"] = {},
					["Bottom"] = {},
				},
				["FrontLeft"] = {
					["Top"] = {},
					["Bottom"] = {},
				},
				["BackRight"] = {
					["Top"] = {},
					["Bottom"] = {},
				},
				["BackLeft"] = {
					["Top"] = {},
					["Bottom"] = {},
				},
			},
		},
		["Springs"] = {},
		["CylindricalConstraint"] = {},
	}

	-- create attachments

	for cat, sides in pairs(Corners.Verticals) do
		-- side is top or bottom
		for side, corners in pairs(sides) do
			for corner, pos in pairs(corners) do
				local Attachment = Instance.new("Attachment")
				local parent
				local cf
				local orientation
				if side == "Top" then
					parent = Platform
					cf = Platform.CFrame:ToObjectSpace(CFrame.new(pos))
					orientation = Vector3.new(0, 0, -90)
				elseif side == "Bottom" then
					parent = Platform.Parent[tostring(string.gsub(corner, "bottom", "") .. "Wheel")]
					cf = Platform.Parent[tostring(string.gsub(corner, "bottom", "") .. "Wheel")].CFrame:ToObjectSpace(CFrame.new(pos))
					local cornerName = tostring(string.gsub(corner, "top", ""))
					if cornerName == "FrontRight" or cornerName == "BackRight" then
						orientation = Vector3.new(90, -180, 0)
					elseif cornerName == "FrontLeft" or cornerName == "BackLeft" then
						orientation = Vector3.new(-90, -180, 0)
					end
				end
				local properties = {
					["Instance"] = Attachment,
					["Name"] = corner .. "Attachment",
					["Parent"] = parent,
					["CFrame"] = cf,
					["Visible"] = true,
					["Orientation"] = orientation,
				}
				PropertyApplier.new(properties)
				table.insert(suspension.Attachments.All, Attachment)
				table.insert(suspension.Attachments.Verticals[cat][side], Attachment)
			end
		end
	end

	-- create springs
	for cat, sides in pairs(suspension.Attachments.Verticals) do
		-- side is top or bottom
		for side, attachment in pairs(sides) do
			local Spring = Instance.new("SpringConstraint")
			local att0
			local att1
			if side == "Top" then
				att0 = attachment[1]
				for i, v in pairs(sides.Bottom) do
					att1 = v
				end
				local properties = {
					["Instance"] = Spring,
					["Name"] = cat .. "Spring",
					["Parent"] = Platform,
					["Visible"] = false,
					["Damping"] = 500,
					["FreeLength"] = 3,
					["MaxForce"] = math.huge,
					["Stiffness"] = 25000,
					["Radius"] = 0.4,
					["Thickness"] = 0.1,
					["Color"] = BrickColor.new("Really red"),
					["Attachment0"] = att0,
					["Attachment1"] = att1,
				}
				PropertyApplier.new(properties)
				table.insert(suspension.Springs, Spring)
			end
		end
	end

	-- create cylindrical constraints
	for cat, sides in pairs(suspension.Attachments.Verticals) do
		-- side is top or bottom
		for side, attachment in pairs(sides) do
			local CylindricalConstraint = Instance.new("CylindricalConstraint")
			local att0
			local att1
			-- left is -90 and right is 90
			local inclinationAngle
			if side == "Top" then
				att0 = attachment[1]
				for i, v in pairs(sides.Bottom) do
					att1 = v
				end
				-- inclinationAngle
				if cat == "FrontRight" or cat == "BackRight" then
					inclinationAngle = 90
				elseif cat == "FrontLeft" or cat == "BackLeft" then
					inclinationAngle = -90
				end
				local properties = {
					["Instance"] = CylindricalConstraint,
					["Name"] = cat .. "CylindricalConstraint",
					["Parent"] = Platform,
					["Size"] = 0.15,
					["Visible"] = false,
					["RotationAxisVisible"] = true,
					["Enabled"] = true,
					["Color"] = BrickColor.new("Really red"),
					["AngularActuatorType"] = Enum.ActuatorType.Motor,
					["InclinationAngle"] = inclinationAngle,
					["Attachment0"] = att0,
					["Attachment1"] = att1,
				}
				PropertyApplier.new(properties)
				table.insert(suspension.CylindricalConstraint, CylindricalConstraint)
			end
		end
	end
end


local function Initiate(spwnPt)
	
	local spawnPart = spwnPt
	spawnPart.CanCollide = false

	-- create model
	MasterChassisModel = Instance.new("Model")
	MasterChassisModel.Name = "MasterChassis"

	-- create platform
	local function CreatePlatform()

		Platform = Instance.new("Part")

		local properties = {
			["Instance"] = Platform,
			["Name"] = "Platform",
			["Parent"] = MasterChassisModel,
			["Position"] = spawnPart.Position + Vector3.new(0, 5, 0),
			["Transparency"] = 0.5,
			["Anchored"] = false,
			["CanCollide"] = true,
			["Size"] = PlatformSize,
		}

		PropertyApplier.new(properties)

		-- set platform as primary part
		MasterChassisModel.PrimaryPart = Platform

		return Platform
	end
	Platform = CreatePlatform()
	
	local function AddSeats()
		local seats = {}
		for count = 1, SeatCount do
			local IsDriver
			if count == 1 then
				IsDriver = true
			else
				IsDriver = false
			end
			local properties = {
				["IsDriver"] = IsDriver,
				["Platform"] = Platform,
			}
			local newDriverSeat = VehSeat.new(properties)
			table.insert(seats, newDriverSeat.Instance)
			print("Created seat:", count)
			newDriverSeat.Instance.Changed:Connect(function(valueChanged)
				if valueChanged == "Occupant" then
					if not newDriverSeat.Instance.Occupant then return end
					local character = newDriverSeat.Instance.Occupant.Parent
					local player = Players:GetPlayerFromCharacter(character)
					if not player then return end
					print(player)
					for i,v in pairs(character:GetDescendants()) do
						--print(v.ClassName)
						if v:IsA("Part") or v:IsA("MeshPart") then
							v.CollisionGroup = "Bull"
						end
						if v:IsA("Accessory") then
							for i2,v2 in pairs(v:GetDescendants()) do
								if v2:IsA("Part") or v:IsA("MeshPart") then
									v2.CollisionGroup = "Bull"
								end
							end
						end
					end
					for i,v in pairs(newDriverSeat.Instance.Parent.Parent:GetDescendants()) do
						if v:IsA("Part") or v:IsA("MeshPart") then
							v:SetNetworkOwner(player)
						end
					end
					newDriverSeat.ProxPrompt.Enabled = false
				end
			end)
		end
		return seats
	end
	Seats = AddSeats()
	
	
	Wheels = CreateWheels()
	-- todo separate functions from CreateSuspension
	-- create attachments
	-- create springs
	-- create cylindrical contraints
	-- create suspension
	Suspension = CreateSuspension()

	-- add to vehicles folder in workspace
	MasterChassisModel.Parent = game.Workspace.BullSpawns
	
	-- add body to chassis
	local attachment = Instance.new("Attachment")
	attachment.Parent = MasterChassisModel.PrimaryPart
	local body = ReplicatedStorage:FindFirstChild("Assets"):FindFirstChild("Bull")
	if not body then return end
	local newBody = body:Clone()
	newBody.HumanoidRootPart.Position = MasterChassisModel.PrimaryPart.Position + Vector3.new(0,5,0)
	local alignOrientation = newBody.PrimaryPart:FindFirstChild("AlignOrientation")
	alignOrientation.Attachment1 = attachment
	local alignPosition = newBody.PrimaryPart:FindFirstChild("AlignPosition")
	alignPosition.Attachment1 = attachment
	-- set physics group so none collide with each other
	for i,v in pairs(MasterChassisModel:GetDescendants()) do
		if v:IsA("Part") or v:IsA("VehicleSeat") then
			v.CollisionGroup = "Bull"
			v.Transparency = 1
		end
	end
	newBody.Parent = MasterChassisModel
end


for i,v in pairs(game.Workspace.BullSpawns:GetChildren()) do
	local spawnPart = v
	Initiate(spawnPart)
end
