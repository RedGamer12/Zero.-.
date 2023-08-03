local module = {}

local isTeleporting = false

function GetDistance(PartA, PartB)
	return(PartA.Position - PartB.Position).Magnitude
end

local function transparencySphere(sphere, transparencyValue)
	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0)
	local tween = game:GetService("TweenService"):Create(sphere, tweenInfo, {Transparency = transparencyValue})
	tween:Play()
	--tween.Completed:Wait()
end

local function moveSphere(sphere, targetPosition, useTween)
	if useTween then
		local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tween = game:GetService("TweenService"):Create(sphere, tweenInfo, {CFrame = CFrame.new(targetPosition)})
		tween:Play()
	else
		sphere.CFrame = CFrame.new(targetPosition)
	end
end

local function createSphere(name, position, color)
	local sphere = Instance.new("Part")
	sphere.Name = name
	sphere.Shape = Enum.PartType.Ball
	sphere.Size = Vector3.new(0.5, 0.5, 0.5)
	sphere.Anchored = true
	sphere.CanCollide = false
	sphere.Transparency = 0.5
	sphere.Material = Enum.Material.Neon
	sphere.BrickColor = color
	sphere.CFrame = CFrame.new(position)
	return sphere
end

local function CalculateDirectionAndDistance(partA, partB)
	local direction = (partB.Position - partA.Position).Unit
	local distanceToB = (partB.Position - partA.Position).Magnitude
	return direction, distanceToB
end

function module.CreateRopeBetweenParts(PartA, PartB, color, Length)
	if not (PartA:IsA("BasePart") and PartB:IsA("BasePart")) then
		error("createRopeBetweenParts function requires BasePart arguments")
		return
	end

	if type(Length) ~= "number" then
		error("Length must be a number")
		return
	end

	local ropeFolder = Instance.new("Folder")
	ropeFolder.Name = "RopeBetween_" .. PartA.Name .. "_and_" .. PartB.Name
	ropeFolder.Parent = workspace

	local function CalculateDirectionAndDistance(partA, partB)
		local direction = (partB.Position - partA.Position).Unit
		local distanceToB = (partB.Position - partA.Position).Magnitude
		return direction, distanceToB
	end

	local direction, distanceToB = CalculateDirectionAndDistance(PartA, PartB)
	local numSpheres = math.ceil(distanceToB / Length)
	local spaceBetweenSpheres = distanceToB / (numSpheres - 1)

	for i = 0, numSpheres - 1 do
		local spherePosition = PartA.Position + direction * (spaceBetweenSpheres * i)
		local sphere = createSphere("Part #" .. i, spherePosition, color)
		sphere.Parent = ropeFolder
	end

	local function updateRope()
		direction, distanceToB = CalculateDirectionAndDistance(PartA, PartB)
		spaceBetweenSpheres = distanceToB / (numSpheres - 1)

		local spheres = ropeFolder:GetChildren()
		for i, sphere in ipairs(spheres) do
			local targetPosition = PartA.Position + direction * (spaceBetweenSpheres * (i - 1))
			moveSphere(sphere, targetPosition)
		end
	end

	PartA:GetPropertyChangedSignal("Position"):Connect(updateRope)
	PartB:GetPropertyChangedSignal("Position"):Connect(updateRope)

	return ropeFolder
end

function module.UpdateRopePosition(ropeFolder, PartA, PartB, distanceToRemove, Length, useTween)
	if not ropeFolder:IsA("Folder") then
		error("The first parameter must be a Folder containing rope spheres")
		return
	end

	if not PartA:IsA("BasePart") or not PartB:IsA("BasePart") then
		error("The second and third parameters must be BasePart objects")
		return
	end

	if not typeof(Length) == "number" then
		error("Length must be a number")
		return
	end

	local function CalculateDirectionAndDistance(partA, partB)
		local direction = (partB.Position - partA.Position).Unit
		local distanceToB = (partB.Position - partA.Position).Magnitude
		return direction, distanceToB
	end

	local direction, distanceToB = CalculateDirectionAndDistance(PartA, PartB)
	local targetNumSpheres = math.ceil(distanceToB / Length)

	local spheres = ropeFolder:GetChildren()
	local numSpheres = #spheres
	local spaceBetweenSpheres = distanceToB / (targetNumSpheres - 1)

	if targetNumSpheres > numSpheres then
		-- Need to add more spheres
		for i = numSpheres + 1, targetNumSpheres do
			local newSphere = createSphere("Part #" .. i, PartA.Position + direction * (spaceBetweenSpheres * (i - 1)), BrickColor.new("Neon orange"))
			newSphere.Transparency = 0.5
			newSphere.Parent = ropeFolder

			if useTween then
				transparencySphere(newSphere, 0.5)
				moveSphere(newSphere, newSphere.Position)
			end
		end
	elseif targetNumSpheres < numSpheres then
		-- Need to remove excess spheres
		for i = numSpheres, targetNumSpheres + 1, -1 do
			local sphere = spheres[i]
			if sphere then
				if useTween then
					transparencySphere(sphere, 1)
				end
				sphere:Destroy()
			end
		end
	end

	for i, sphere in ipairs(spheres) do
		sphere.Name = "Part #" .. (i - 1)
		local distanceToSphere = (PartA.Position - PartB.Position).Magnitude
		local transparency = distanceToSphere <= distanceToRemove and 1 or 0.5
		sphere.Transparency = transparency

		local targetPosition = PartA.Position + direction * (spaceBetweenSpheres * (i - 1))

		if useTween then
			moveSphere(sphere, targetPosition, true)
		else
			sphere.CFrame = CFrame.new(targetPosition)
		end
	end

	local endSphere = spheres[targetNumSpheres]
	if endSphere then
		local transparency = distanceToB <= distanceToRemove and 1 or 0.5
		endSphere.Transparency = transparency

		local targetPosition = PartA.Position + direction * (spaceBetweenSpheres * (targetNumSpheres - 1))
		if useTween then
			moveSphere(endSphere, targetPosition)
		else
			endSphere.CFrame = CFrame.new(targetPosition)
		end
	end
end

function module.TeleportThroughSpheres(spheresFolder, PartA, PartB, Length, LastCFrame)
	if not (PartA:IsA("BasePart") and PartB:IsA("BasePart")) then
		error("TeleportThroughSpheres function requires BasePart arguments")
		return
	end

	if not spheresFolder or not spheresFolder:IsA("Folder") then
		error("The first parameter must be a Folder containing the spheres")
		return
	end

	local teleportSpeed = 0.25
	local distanceBetweenSpheres = Length

	local spheres = spheresFolder:GetChildren()
	table.sort(spheres, function(a, b)
		return tonumber(string.match(a.Name, "%d+")) < tonumber(string.match(b.Name, "%d+"))
	end)

	isTeleporting = true

	spawn(function()
		while wait() do
			local distanceBetweenAB = (PartA.Position - PartB.Position).Magnitude
			if distanceBetweenAB < 150 then
				--print("Distance between PartA and PartB is less than 10 studs.")
				PartA.CFrame = LastCFrame
				isTeleporting = false
			end
		end
	end)

	local function teleportToNextSphere(index)
		if not isTeleporting then
			return
		end

		local sphere = spheres[index]
		if sphere then
			local destinationPosition = sphere.Position
			local distanceToSphere = (PartA.Position - destinationPosition).Magnitude
			if distanceToSphere > distanceBetweenSpheres then

				local direction = (destinationPosition - PartA.Position).Unit
				local teleportStep = direction * distanceBetweenSpheres
				local numTeleports = math.floor(distanceToSphere / distanceBetweenSpheres)

				for i = 1, numTeleports do
					if not isTeleporting then
						return
					end
					PartA.CFrame = PartA.CFrame + teleportStep
					wait(teleportSpeed)
				end
			end

			PartA.Position = destinationPosition
			wait(teleportSpeed)
			teleportToNextSphere(index + 1)
		else
			isTeleporting = false
		end
	end
	teleportToNextSphere(1)
end

function module.CancelTeleport()
	isTeleporting = false
end

return module
