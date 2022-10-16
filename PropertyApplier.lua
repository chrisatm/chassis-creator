local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PropertyApplier = {}
PropertyApplier.__index = PropertyApplier

function PropertyApplier.new(info)
    local self = setmetatable({}, PropertyApplier)

    self:Initiate(info)

    return self
end

function PropertyApplier:Initiate(info)

    self.Info = info

    self.CommonProperties = {
        "Name",
        "Parent",
        "Position",
        "Anchored",
        "Transparency",
        "CanCollide",
        "Size",
        "Shape",
        "Visible",
    }

    self:ApplyProperties()
end


function PropertyApplier:ApplyProperties()
    for propertySent, value in pairs(self.Info) do
        local InstanceHasProperty = self:CheckProperty(propertySent)
        --print(self.Info.Name .. " has property " .. propertySent .. ": " .. tostring(InstanceHasProperty))
        if InstanceHasProperty == true then
            if propertySent == "Parent" then
                --print(index2, property, properties[property])
                self.Info.Instance.Parent = value
            elseif propertySent == "Anchored" then
                --print(index2, property, properties[property])
                self.Info.Instance.Anchored = value
            elseif propertySent == "CFrame" then
                --print(index2, property, properties[property])
                self.Info.Instance.CFrame = value
            elseif propertySent == "Attachment0" then
                --print(index2, property, properties[property])
                self.Info.Instance.Attachment0 = value
            elseif propertySent == "Attachment1" then
                --print(index2, property, properties[property])
                self.Info.Instance.Attachment1 = value
            else
                self.Info.Instance[propertySent] = value
            end
        end
    end
end

function PropertyApplier:CheckProperty(prop)

    local success, response = pcall(function()
        -- check if property exists in instance
        local test = self.Info.Instance[prop]
    end)

    if success then
        return true
    end

    if response then
        --warn(prop .. " does not exist on " .. self.Info.Name)
        return false
    end
end

function PropertyApplier:Request(player, info)
    
end

function PropertyApplier:Destroy()
    
end

return PropertyApplier
