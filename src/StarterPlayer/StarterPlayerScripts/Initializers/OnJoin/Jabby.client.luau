--Services
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Packages
local Jabby = require(ReplicatedStorage.Packages.Jabby)

local Client = Jabby.obtain_client()

local function CreateWidget(_, State: Enum.UserInputState)
    if State ~= Enum.UserInputState.Begin then return end

    Client.spawn_app(Client.apps.home, nil)
end

ContextActionService:BindAction("Open Jabby Home", CreateWidget, false, Enum.KeyCode.F4)