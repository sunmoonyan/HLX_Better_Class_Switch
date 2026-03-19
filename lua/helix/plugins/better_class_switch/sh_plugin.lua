local PLUGIN = PLUGIN

PLUGIN.name = "Better Class Switch"
PLUGIN.author = "Sunshi"
PLUGIN.description = "Automatically join the default class when a player joins a faction and apply playermodel."

ix.config.Add("setFactionModel", true, "Set automatically faction or class model.", nil, {
    category = "Characters"
})

if SERVER then
    local character = ix.meta.character

    hook.Add("OnCharacterTransferred", "SetDefaultClass", function(character, faction)
        character:SetDefaultClass(faction)
        if ix.config.Get("setFactionModel") then
        character:SetFactionModel(faction)
        local class = GetDefaultClass(faction)
        if class then
            character:SetClassModel(class)
        end
        end
    end)

    function PLUGIN:PlayerLoadedCharacter(client, character, currentChar)
    end

    function PLUGIN:OnCharacterDisconnect(client, character)
        if ix.config.Get("setFactionModel") then
        local faction = character:GetFaction()
        character:SetClassModel(GetDefaultClass(faction))
        end
    end

    function PLUGIN:PlayerJoinedClass(client, class, oldClass)
        if ix.config.Get("setFactionModel") then
        local character = client:GetCharacter()
        character:SetClassModel(class)
        end
    end

    function PLUGIN:CharacterLoaded(character)
        local client = character:GetPlayer()
        local faction = character:GetFaction()
        local defaultClass = GetDefaultClass(faction)
        local class = character:GetClass()
        if ix.config.Get("setFactionModel") then
        character:SetFactionModel(faction)
        if defaultClass then
            character:SetClassModel(defaultClass)
        end
        end
    end

    function GetDefaultClass(faction)
        for i, v in ipairs(ix.class.list) do
            if v.faction == faction and v.isDefault then
                return i
            end
        end
        return nil
    end

    function character:SetDefaultClass(faction)
        for i, v in ipairs(ix.class.list) do
            if v.faction == faction and v.isDefault then
                self:JoinClass(i)
                break
            end
        end
    end

    function character:SetClassModel(class)
        local client = self:GetPlayer()
        if not class then return end
        local data = ix.class.Get(class)
        if not data then return end
        if isstring(data.model) then
            self:SetModel(data.model)
            client:SetSkin(data.skin or 0)
        end
    end

    function character:SetFactionModel(faction)
        local client = self:GetPlayer()
        local data = ix.faction.Get(faction)
        if not data then return end
        if isstring(data.models) then
            self:SetModel(data.models)
        elseif istable(data.models) then
            self:SetModel(data.models[math.random(1, table.Count(data.models))])
        end
    end
end
