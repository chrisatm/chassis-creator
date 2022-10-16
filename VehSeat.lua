local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VehSeat = {}
VehSeat.__index = VehSeat

-- Chassis

local PropertyApplier = require(ReplicatedStorage.Utilities.PropertyApplier)

function VehSeat.new(info)
    local self = setmetatable({}, VehSeat)

    self.Info = info
    self.IsDriver = info.IsDriver

    self.Instance = self:CreateSeat()
    self.ProxPrompt = self:CreateProxPrompt()

    return self
end

function VehSeat:CreateSeat()

    local Seat = nil
    local Part1 = nil
    local Name = "Seat"
    local Disabled = true

    Seat = Instance.new("VehicleSeat")

    local driverSeatProperties = {
        ["Instance"] = Seat,
        ["Name"] = Name,
        ["Parent"] = self.Info.Platform,
		["Disabled"] = Disabled,
        ["CanCollide"] = true,
        ["HeadsUpDisplay"] = true,
		["Position"] = self.Info.Platform.Position + Vector3.new(0, self.Info.Platform.Size.Y + Seat.Size.Y + 1, 0)
	}
	
	PropertyApplier.new(driverSeatProperties)

    -- weld seat to platform
    local driverSeatWeldConstraint = Instance.new("WeldConstraint")

    local driverSeatWeldProperties = {
        ["Instance"] = driverSeatWeldConstraint,
        ["Name"] = "DriverSeatWeld",
        ["Parent"] = self.Info.Platform,
        ["Enabled"] = true,
        ["Part0"] = self.Info.Platform,
		["Part1"] = Seat,
    }

	PropertyApplier.new(driverSeatWeldProperties)

    return Seat
end

function VehSeat:CreateProxPrompt()

    local ActionText = ""
    local ObjectText = ""

    if self.IsDriver == true then
        ActionText = "Drive"
        ObjectText = "Drive Vehicle"
    else
        ActionText = "Enter"
        ObjectText = "Enter Vehicle"
    end

    local SeatPrompt = Instance.new("ProximityPrompt")

    local SeatPromptProperties = {
        ["Instance"] = SeatPrompt,
        ["Name"] = "DriverSeatPrompt",
        ["Parent"] = self.DriverSeat,
        ["ActionText"] = ActionText,
        ["ClickablePrompt"] = true,
        ["Enabled"] = true,
        ["Exclusivity"] = Enum.ProximityPromptExclusivity.OnePerButton,
        ["GamepadKeycode"] = Enum.KeyCode.ButtonX,
        ["HoldDuration"] = 0,
        ["KeyboardKeycode"] = Enum.KeyCode.E,
        ["MaxActivationDistance"] = 10,
        ["ObjectText"] = ObjectText,
        ["RequiresLineOfSight"] = false,
        ["Style"] = Enum.ProximityPromptStyle.Default,
        ["UIOffset"] = Vector2.new(0, 0),
    }

	PropertyApplier.new(SeatPromptProperties)
	SeatPrompt.Parent = self.Instance
	
	SeatPrompt.Triggered:Connect(function(plr)
		print(plr.Character.Humanoid)
		self.Instance:Sit(plr.Character.Humanoid)
	end)

  return SeatPrompt
end

function VehSeat:Request(player, info)
    
end

function VehSeat:Destroy()
    
end

return VehSeat
