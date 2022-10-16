
local Corners = {}
Corners.__index = Corners

function Corners.new(part)
    local self = setmetatable({}, Corners)

    self.Corners = self:GetCorners(part)

    return self
end

function Corners:GetCorners(part)
	local corners = {
        ["All"] = {},
        ["TopSide"] = {},
        ["BottomSide"] = {},
        ["TopFront"] = {},
        ["BottomFront"] = {},
        ["TopBack"] = {},
        ["BottomBack"] = {},
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
    }
	
	-- helper cframes for intermediate steps
	-- before finding the corners cframes.
	-- With corners I only need cframe.Position of corner cframes.
	
	-- face centers - 2 of 6 faces referenced
	local frontFaceCenter = (part.CFrame + part.CFrame.LookVector * part.Size.Z/2)
	local backFaceCenter = (part.CFrame - part.CFrame.LookVector * part.Size.Z/2)
	
	-- edge centers - 4 of 12 edges referenced
	local topFrontEdgeCenter = frontFaceCenter + frontFaceCenter.UpVector * part.Size.Y/2
	local bottomFrontEdgeCenter = frontFaceCenter - frontFaceCenter.UpVector * part.Size.Y/2
	local topBackEdgeCenter = backFaceCenter + backFaceCenter.UpVector * part.Size.Y/2
	local bottomBackEdgeCenter = backFaceCenter - backFaceCenter.UpVector * part.Size.Y/2
	
	-- corners
	corners.All.topFrontRight = (topFrontEdgeCenter + topFrontEdgeCenter.RightVector * part.Size.X/2).Position
	corners.All.topFrontLeft = (topFrontEdgeCenter - topFrontEdgeCenter.RightVector * part.Size.X/2).Position
	
	corners.All.bottomFrontRight = (bottomFrontEdgeCenter + bottomFrontEdgeCenter.RightVector * part.Size.X/2).Position
	corners.All.bottomFrontLeft = (bottomFrontEdgeCenter - bottomFrontEdgeCenter.RightVector * part.Size.X/2).Position
	
	corners.All.topBackRight = (topBackEdgeCenter + topBackEdgeCenter.RightVector * part.Size.X/2).Position
	corners.All.topBackLeft = (topBackEdgeCenter - topBackEdgeCenter.RightVector * part.Size.X/2).Position
	
	corners.All.bottomBackRight = (bottomBackEdgeCenter + bottomBackEdgeCenter.RightVector * part.Size.X/2).Position
	corners.All.bottomBackLeft = (bottomBackEdgeCenter - bottomBackEdgeCenter.RightVector * part.Size.X/2).Position

  --topside
  corners.TopSide.topFrontRight = corners.All.topFrontRight
	corners.TopSide.topFrontLeft = corners.All.topFrontLeft
  corners.TopSide.topBackRight = corners.All.topBackRight
	corners.TopSide.topBackLeft = corners.All.topBackLeft

  --bottomside
  corners.BottomSide.bottomFrontRight = corners.All.bottomFrontRight
	corners.BottomSide.bottomFrontLeft = corners.All.bottomFrontLeft
  corners.BottomSide.bottomBackRight = corners.All.bottomBackRight
	corners.BottomSide.bottomBackLeft = corners.All.bottomBackLeft

  --topfront
  corners.TopFront.topFrontRight = corners.All.topFrontRight
	corners.TopFront.topFrontLeft = corners.All.topFrontLeft

  --bottomfront
  corners.BottomFront.bottomFrontRight = corners.All.bottomFrontRight
	corners.BottomFront.bottomFrontLeft = corners.All.bottomFrontLeft

  --topback
  corners.TopBack.topBackRight = corners.All.topBackRight
	corners.TopBack.topBackLeft = corners.All.topBackLeft

  --bottomback
  corners.BottomBack.bottomBackRight = corners.All.bottomBackRight
	corners.BottomBack.bottomBackLeft = corners.All.bottomBackLeft

  --frontright
  corners.Verticals.FrontRight.Top.topFrontRight = corners.All.topFrontRight
  corners.Verticals.FrontRight.Bottom.bottomFrontRight = corners.All.bottomFrontRight

  --frontleft
  corners.Verticals.FrontLeft.Top.topFrontLeft = corners.All.topFrontLeft
  corners.Verticals.FrontLeft.Bottom.bottomFrontLeft = corners.All.bottomFrontLeft

  --backright
  corners.Verticals.BackRight.Top.topBackRight = corners.All.topBackRight
  corners.Verticals.BackRight.Bottom.bottomBackRight = corners.All.bottomBackRight

  --backleft
  corners.Verticals.BackLeft.Top.topBackLeft = corners.All.topBackLeft
  corners.Verticals.BackLeft.Bottom.bottomBackLeft = corners.All.bottomBackLeft

	return corners
end

function Corners:Request(player, info)
    
end

function Corners:Destroy()
    
end

return Corners
