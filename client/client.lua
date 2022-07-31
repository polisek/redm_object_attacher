local inEditMode = false
local objectEdit
local editData = {
    model= "",
    animDict = "",
    anim = "",
    bone = nil,
    posx = 0.0,
    posy = 0.0,
    posz = 0.0,
    rotx = 0.0,
    roty = 0.0,
    rotz = 0.0,
}
local posMove = 1.0
local pMove  = 1
local promptGroup
local prompts = {}
local pc = 1

local editPos = 1

local editValue = 1

Citizen.CreateThread(function()

    prompts[pc] = PromptRegisterBegin()
    PromptSetControlAction(prompts[pc], 0xB2F377E8) -- G
    PromptSetText(prompts[pc], CreateVarString(10, "LITERAL_STRING", "Move jump"))
    PromptSetStandardMode(prompts[pc], true)
    PromptSetHoldMode(prompts[pc], 0)
    PromptSetVisible(prompts[pc], 0)
    PromptSetEnabled(prompts[pc],0)
    N_0x0c718001b77ca468(prompts[pc], 3.0)
    PromptSetGroup(prompts[pc], promptGroup)
    PromptRegisterEnd(prompts[pc])
    pc += 1

    prompts[pc] = PromptRegisterBegin()
    PromptSetControlAction(prompts[pc], 0xF3830D8E) -- J
    PromptSetText(prompts[pc], CreateVarString(10, "LITERAL_STRING", "Next position"))
    PromptSetStandardMode(prompts[pc], true)
    PromptSetHoldMode(prompts[pc], 0)
    PromptSetVisible(prompts[pc], 0)
    PromptSetEnabled(prompts[pc], 0)
    N_0x0c718001b77ca468(prompts[pc], 3.0)
    PromptSetGroup(prompts[pc], promptGroup)
    PromptRegisterEnd(prompts[pc])
    pc += 1

    prompts[pc] = PromptRegisterBegin()
    PromptSetControlAction(prompts[pc], 0x6319DB71) -- Up arrow
    PromptSetText(prompts[pc], CreateVarString(10, "LITERAL_STRING", "UP "..posMove))
    PromptSetStandardMode(prompts[pc], true)
    PromptSetHoldMode(prompts[pc], 0)
    PromptSetVisible(prompts[pc], 0)
    PromptSetEnabled(prompts[pc] ,0)
    N_0x0c718001b77ca468(prompts[pc], 3.0)
    PromptSetGroup(prompts[pc], promptGroup)
    PromptRegisterEnd(prompts[pc])
    pc += 1

    prompts[pc] = PromptRegisterBegin()
    PromptSetControlAction(prompts[pc], 0x05CA7C52) -- Down arrow
    PromptSetText(prompts[pc], CreateVarString(10, "LITERAL_STRING", "DOWN "..posMove))
    PromptSetStandardMode(prompts[pc], true)
    PromptSetHoldMode(prompts[pc], 0)
    PromptSetVisible(prompts[pc], 0)
    PromptSetEnabled(prompts[pc], 0)
    N_0x0c718001b77ca468(prompts[pc], 3.0)
    PromptSetGroup(prompts[pc], promptGroup)
    PromptRegisterEnd(prompts[pc])
    pc += 1


end)











--------------------------------------
------------ Commands ---------------
--------------------------------------
Citizen.CreateThread(function()
	TriggerEvent('chat:addSuggestion', '/olstart',   "",   { { name = "( Model )  ( Bone ) ", help ="" }, } )	
    TriggerEvent('chat:addSuggestion', '/olanim',   "",   { { name = "( Anim Dict )  ( Anim ) ", help ="" }, } )
end)

RegisterCommand("olstart", function(source, args, rawCommand)

    inEditMode = true
    local player = PlayerPedId()
    local x,y,z = table.unpack(GetEntityCoords(player, true))
    editData.model = args[1]
    objectEdit = CreateObject(GetHashKey(editData.model), x, y, z + 0.2, true, true, true) -- Object
    editData.bone = GetEntityBoneIndexByName(player, args[2]) -- Bone
    AttachEntityToEntity(objectEdit, player, editData.bone, editData.posx, editData.posy, editData.posz, editData.rotx,editData.roty, editData.rotz, true,true, false, true, 1, true)
    for i=1, pc do
        PromptSetVisible(prompts[i], 1)
        PromptSetEnabled(prompts[i], 1)
    end
end, false )


RegisterCommand("olupdate", function(source, args, rawCommand)
    local player = PlayerPedId()
    local x,y,z = table.unpack(GetEntityCoords(player, true))
    DeleteEntity(objectEdit)
    Wait(100)
    objectEdit = CreateObject(GetHashKey(editData.model), x, y, z + 0.2, true, true, true) -- Object
    AttachEntityToEntity(objectEdit, player, editData.bone, editData.posx, editData.posy, editData.posz, editData.rotx,editData.roty, editData.rotz, true,true, false, true, 1, true)
end, false )

RegisterCommand("oljump", function(source, args, rawCommand)
    if pMove == 8 then
        pMove = 1
        moveJumps:case(pMove)
        PromptSetText(prompts[3], CreateVarString(10, "LITERAL_STRING", "UP "..posMove))
        PromptSetText(prompts[4], CreateVarString(10, "LITERAL_STRING", "DOWN "..posMove))
    else
        pMove += 1
        moveJumps:case(pMove)
        PromptSetText(prompts[3], CreateVarString(10, "LITERAL_STRING", "UP "..posMove))
        PromptSetText(prompts[4], CreateVarString(10, "LITERAL_STRING", "DOWN "..posMove))
    end
end, false )

RegisterCommand("olstop", function(source, args, rawCommand)
    inEditMode = false
    Wait(100)
    for i=1, pc do
        PromptSetVisible(prompts[i], 0)
        PromptSetEnabled(prompts[i], 0)
    end
    DeleteEntity(objectEdit)
    print(editData.bone..","..editData.posx..","..editData.posy..","..editData.posz..","..editData.rotx..","..editData.roty..","..editData.rotz)

end, false )




RegisterCommand("olanim", function(source, args, rawCommand)
    local data = {
        animDict = args[1],
        animName = args[2]
    }
    LoadAnimationDic(data.animDict)
    print(data.animDict)
    print(data.animName)
    TaskPlayAnim( PlayerPedId(), data.animDict, data.animName, 2.0, -2.0, -1, 67109393, 0.0, false, 1245184, false, "UpperbodyFixup_filter", false)

end, false )


--------------------------------------
------------ Loops     ---------------
--------------------------------------

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if inEditMode == true then
		local ped = PlayerPedId()
		local pos = GetEntityCoords(ped)
		DrawText3D(pos.x, pos.y, pos.z + 0.18, "Object Attacher")
        DrawText3D(pos.x, pos.y, pos.z, 'X: ' .. editData.posx .. ' - Y ' .. editData.posy .. ' - Z: ' ..  editData.posz .. '- RX: ' ..  editData.rotx .. '- RY: ' ..  editData.roty .. '- RZ: ' ..  editData.rotz .. '')
        DrawText3D(pos.x, pos.y, pos.z - 0.18, 'Editing: '..editPos..' - '..GetEditPosition(editPos)) 
        DrawText3D(pos.x, pos.y, pos.z - 0.36, 'Move jump: '..posMove)
        end
    end
end)


Citizen.CreateThread(function()
	while true do
        Wait(10)
        if inEditMode == true then

            if PromptIsJustPressed(prompts[1]) then -- Down
                if pMove == 8 then
                    pMove = 1
                    moveJumps:case(pMove)
                    PromptSetText(prompts[3], CreateVarString(10, "LITERAL_STRING", "UP "..posMove))
                    PromptSetText(prompts[4], CreateVarString(10, "LITERAL_STRING", "DOWN "..posMove))
                else
                    pMove += 1
                    moveJumps:case(pMove)
                    PromptSetText(prompts[3], CreateVarString(10, "LITERAL_STRING", "UP "..posMove))
                    PromptSetText(prompts[4], CreateVarString(10, "LITERAL_STRING", "DOWN "..posMove))
                end
                --updateOL()
            end

            if PromptIsJustPressed(prompts[2]) then -- Up
                if editPos == 6 then
                    editPos = 1
                else
                    editPos += 1
                end
                --updateOL()
            end
            
            if PromptIsJustPressed(prompts[3]) then -- Left
                plus:case(editPos)
                updateOL()
            end

            if PromptIsJustPressed(prompts[4]) then -- Right
                minus:case(editPos)
                updateOL()
            end

            

        end
    end
end)

--------------------------------------
------------ Functions ---------------
--------------------------------------

function DrawText3D(x, y, z, text)
    local onScreen,_x,_y=GetScreenCoordFromWorldCoord(x, y, z)
    SetTextScale(0.35, 0.35)
    SetTextFontForCurrentCommand(9)
    SetTextColor(255, 255, 255, 215)
    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    SetTextCentre(1)
    DisplayText(str,_x,_y)
end


function LoadAnimationDic(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Citizen.Wait(0)
        end
    end
  end

function updateOL()
    local player = PlayerPedId()
    local x,y,z = table.unpack(GetEntityCoords(player, true))
    DeleteEntity(objectEdit)
    Wait(100)
    objectEdit = CreateObject(GetHashKey(editData.model), x, y, z + 0.2, true, true, true) -- Object
    AttachEntityToEntity(objectEdit, player, editData.bone, editData.posx, editData.posy, editData.posz, editData.rotx,editData.roty, editData.rotz, true,true, false, true, 1, true)
end

function switch(t)
    t.case = function (self,x)
      local f=self[x] or self.default
      if f then
        if type(f)=="function" then
          f(x,self)
        else
          error("case "..tostring(x).." not a function")
        end
      end
    end
    return t
  end

  function GetEditPosition(pos)
    if pos == 1 then
        return "X"
    elseif pos == 2 then
        return "Y"
    elseif pos == 3 then
        return "Z"
    elseif pos == 4 then
        return "RX"
    elseif pos == 5 then
        return "RY"
    elseif pos == 6 then
        return "RZ"
    end
  end


----------------------------------------
------------Switchs----------------------
----------------------------------------




plus = switch {
    [1] = function () editData.posx+=posMove end,
    [2] = function () editData.posy+=posMove end,
    [3] = function () editData.posz+=posMove end,
    [4] = function () editData.rotx+=posMove end,
    [5] = function () editData.roty+=posMove end,
    [6] = function () editData.rotz+=posMove end,
    default = function () print("Nothing") end,
  }

  minus = switch {
    [1] = function () editData.posx-=posMove end,
    [2] = function () editData.posy-=posMove end,
    [3] = function () editData.posz-=posMove end,
    [4] = function () editData.rotx-=posMove end,
    [5] = function () editData.roty-=posMove end,
    [6] = function () editData.rotz-=posMove end,
    default = function () print("Nothing") end,
  }


  moveJumps = switch {
    [1] = function () posMove=1.0 end,
    [2] = function () posMove=1.5 end,
    [3] = function () posMove=2.0 end,
    [4] = function () posMove=5.0 end,
    [5] = function () posMove=0.01 end,
    [6] = function () posMove=0.05 end,
    [7] = function () posMove=0.1 end,
    [8] = function () posMove=0.5 end,
    default = function () print("Nothing") end,
  }
