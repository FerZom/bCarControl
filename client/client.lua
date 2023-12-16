local QBCore = exports['qb-core']:GetCoreObject()

local HasNuiFocus = false

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        SetCustomNuiFocus(false, false)
    end
end)


RegisterNUICallback('kapat', function(data, cb)
    Citizen.Wait(100)
    SetCustomNuiFocus(false, false)
end)

RegisterCommand("carcontrol", function()
TriggerEvent("bCarControl:open")
end)

RegisterNetEvent('bCarControl:open')
AddEventHandler('bCarControl:open', function(hasFocus, hasKeyboard, hasMouse, allControl)
    Citizen.Wait(100)
    SendNUIMessage({type = "open"})
    SetCustomNuiFocus(true, true)
    QBCore.Functions.Notify('Araç Etkileşim Menüsü Açıldı. "ESC" veya "BACKSPACE" Tuşları İle Menüyü Kapatabilirsin.', "info")

end)

function SetCustomNuiFocus(hasKeyboard, hasMouse)
    HasNuiFocus = hasKeyboard or hasMouse
    SetNuiFocus(hasKeyboard, hasMouse)
    SetNuiFocusKeepInput(HasNuiFocus)
--[[     TriggerEvent("tgiann-menuv3:nui-focus", HasNuiFocus, hasKeyboard, hasMouse, true) ]]
end

local checkCar = true
local lastvehicle = 0

local onsolcam = false
local onsagcam = false
local arkasolcam = false
local arkasagcam = false

local inDriveSeat = false

Citizen.CreateThread(function()
    while true do 
        local time = 100
        local playerPed = PlayerPedId()
        local inVeh = IsPedInAnyVehicle(playerPed)
        if inVeh then
            local veh = GetVehiclePedIsIn(playerPed)
            if lastvehicle ~= veh then
                lastvehicle = veh
                for i=0, 3 do
                    RollUpWindow(lastvehicle, i)
                end
                onsolcam = false
                onsagcam = false
                arkasolcam = false
                arkasagcam = false
            end
        end

        if HasNuiFocus then
            time = 1
            
            if inVeh then
                SetPauseMenuActive(false)
                if IsControlJustReleased(0, 177) then
                    SendNUIMessage({type = "close"})
                end

                inDriveSeat = GetPedInVehicleSeat(lastvehicle, -1) == playerPed

                local data = {
                    onsolkoltuk = checkSeat(-1),
                    onsagkoltuk = checkSeat(0),
                    arkasolkoltuk = checkSeat(1),
                    arkasagkoltuk = checkSeat(2),

                    start = checkInDriveSeat(GetIsVehicleEngineRunning(lastvehicle)),

                    neon = checkInDriveSeat(IsVehicleNeonLightEnabled(lastvehicle, 0)),
                    isiklar = checkInDriveSeat(SetVehicleLights(lastvehicle, 2)),

                    bagaj = checkInDriveSeat(GetVehicleDoorAngleRatio(lastvehicle, 5) > 0),
                    kaput = checkInDriveSeat(GetVehicleDoorAngleRatio(lastvehicle, 4) > 0),

                    onsolcam = checkInDriveSeat(onsolcam),
                    onsagcam = checkInDriveSeat(onsagcam),
                    arkasolcam = checkInDriveSeat(arkasolcam),
                    arkasagcam = checkInDriveSeat(arkasagcam),
                    
                    tumkapilar = checkInDriveSeat(GetVehicleDoorAngleRatio(lastvehicle, 0) and GetVehicleDoorAngleRatio(lastvehicle, 1) and GetVehicleDoorAngleRatio(lastvehicle, 2) and GetVehicleDoorAngleRatio(lastvehicle, 3) > 0),

                    onsolkapi = checkInDriveSeat(GetVehicleDoorAngleRatio(lastvehicle, 0) > 0),
                    onsagkapi = checkInDriveSeat(GetVehicleDoorAngleRatio(lastvehicle, 1) > 0),
                    arkasolkapi = checkInDriveSeat(GetVehicleDoorAngleRatio(lastvehicle, 2) > 0),
                    arkasagkapi = checkInDriveSeat(GetVehicleDoorAngleRatio(lastvehicle, 3) > 0),

                }
                SendNUIMessage({type = "update", data = data})
            else
                SendNUIMessage({type = "close"})
            end
        end
        Citizen.Wait(time)
    end
end)

function checkSeat(no)
    if IsVehicleSeatFree(lastvehicle, no) then
        return false
    elseif GetPedInVehicleSeat(lastvehicle, no) == PlayerPedId() and not IsVehicleSeatFree(lastvehicle, no) then
        return true
    else
        return "pasif"
    end
end

function checkInDriveSeat(firstData)
    if inDriveSeat then
        return firstData
    else
        return "pasif"
    end
end

RegisterNUICallback('set', function(data)
    if data.tip == "onsolkoltuk" then
        if not checkSeat(-1) then
            QBCore.Functions.Progressbar("oyuncu_iyilestir", "Koltuk Değiştiriliyor", math.random(1500, 2850), false, true, { -- p1: menu name, p2: yazı, p3: ölü iken kullan, p4:iptal edilebilir
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
		}, {
		}, {}, {}, function() -- Done
            SetPedIntoVehicle(PlayerPedId(), lastvehicle, -1)
            QBCore.Functions.Notify("Sürücü Koltuğuna Geçtin", "success")
        end)
        end
    elseif data.tip == "onsagkoltuk" then
        if not checkSeat(0) then
            QBCore.Functions.Progressbar("oyuncu_iyilestir", "Koltuk Değiştiriliyor", math.random(1500, 2850), false, true, { -- p1: menu name, p2: yazı, p3: ölü iken kullan, p4:iptal edilebilir
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
		}, {
		}, {}, {}, function() -- Done
            SetPedIntoVehicle(PlayerPedId(), lastvehicle, 0)
            QBCore.Functions.Notify("2. Koltuğa Geçtin", "success")
        end)
        end
    elseif data.tip == "arkasolkoltuk" then
        if not checkSeat(1) then
            QBCore.Functions.Progressbar("oyuncu_iyilestir", "Koltuk Değiştiriliyor", math.random(1500, 2850), false, true, { -- p1: menu name, p2: yazı, p3: ölü iken kullan, p4:iptal edilebilir
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
		}, {
		}, {}, {}, function() -- Done
            SetPedIntoVehicle(PlayerPedId(), lastvehicle, 1)
            QBCore.Functions.Notify("3. Koltuğa Geçtin", "success")
        end)
        end
    elseif data.tip == "arkasagkoltuk" then
        if not checkSeat(2) then
            QBCore.Functions.Progressbar("oyuncu_iyilestir", "Koltuk Değiştiriliyor", math.random(1500, 2850), false, true, { -- p1: menu name, p2: yazı, p3: ölü iken kullan, p4:iptal edilebilir
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
		}, {
		}, {}, {}, function() -- Done
            SetPedIntoVehicle(PlayerPedId(), lastvehicle, 2)
            QBCore.Functions.Notify("4. Koltuğa Geçtin", "success")
        end)
        end

    elseif data.tip == "onsolkapi" and inDriveSeat then
        if GetVehicleDoorAngleRatio(lastvehicle, 0) == 0 then
            SetVehicleDoorOpen(lastvehicle, 0, false, false)
            QBCore.Functions.Notify("Ön Sol Kapıyı Açtın", "success")
        else
            SetVehicleDoorShut(lastvehicle, 0, false, false)
            QBCore.Functions.Notify("Ön Sol Kapıyı Kapattın", "error")
        end
    elseif data.tip == "onsagkapi" and inDriveSeat then
        if GetVehicleDoorAngleRatio(lastvehicle, 1) == 0 then
            SetVehicleDoorOpen(lastvehicle, 1, false, false)
            QBCore.Functions.Notify("Ön Sağ Kapıyı Açtın", "success")
        else
            SetVehicleDoorShut(lastvehicle, 1, false, false)
            QBCore.Functions.Notify("Ön Sağ Kapıyı Kapattın", "error")
        end
    elseif data.tip == "arkasolkapi" and inDriveSeat then
        if GetVehicleDoorAngleRatio(lastvehicle, 2) == 0 then
            SetVehicleDoorOpen(lastvehicle, 2, false, false)
            QBCore.Functions.Notify("Arka Sol Kapıyı Açtın", "success")
        else
            SetVehicleDoorShut(lastvehicle, 2, false, false)
            QBCore.Functions.Notify("Arka Sol Kapıyı Kapattın", "error")
        end
    elseif data.tip == "arkasagkapi" and inDriveSeat then
        if GetVehicleDoorAngleRatio(lastvehicle, 3) == 0 then
            SetVehicleDoorOpen(lastvehicle, 3, false, false)
            QBCore.Functions.Notify("Arka Sağ Kapıyı Açtın", "success")
        else
            SetVehicleDoorShut(lastvehicle, 3, false, false)
            QBCore.Functions.Notify("Arka Sağ Kapıyı Kapattın", "error")
        end
    elseif data.tip == "tumkapilar" and inDriveSeat then
        if GetVehicleDoorAngleRatio(lastvehicle, 0) and GetVehicleDoorAngleRatio(lastvehicle, 1) and GetVehicleDoorAngleRatio(lastvehicle, 2) and GetVehicleDoorAngleRatio(lastvehicle, 3) == 0  then
            SetVehicleDoorOpen(lastvehicle, 0, false, false)
            SetVehicleDoorOpen(lastvehicle, 1, false, false)
            SetVehicleDoorOpen(lastvehicle, 2, false, false)
            SetVehicleDoorOpen(lastvehicle, 3, false, false)
            QBCore.Functions.Notify("Tüm kapılar açık", "success")
        else
            SetVehicleDoorShut(lastvehicle, 0, false, false)
            SetVehicleDoorShut(lastvehicle, 1, false, false)
            SetVehicleDoorShut(lastvehicle, 2, false, false)
            SetVehicleDoorShut(lastvehicle, 3, false, false)
            QBCore.Functions.Notify("Arka Sağ Kapıyı Kapattın", "error")
        end
    elseif data.tip == "isiklar" and inDriveSeat then
            SetVehicleLights(lastvehicle, 2)
            SetVehicleFullbeam(lastvehicle, true)
            QBCore.Functions.Notify("Farlar Fullendi", "error")
    elseif data.tip == "neon" and inDriveSeat then
        local neoncheck = IsVehicleNeonLightEnabled(lastvehicle, 0)
        if neoncheck then
            SetVehicleNeonLightEnabled(lastvehicle, 0, false)
            SetVehicleNeonLightEnabled(lastvehicle, 1, false)
            SetVehicleNeonLightEnabled(lastvehicle, 2, false)
            SetVehicleNeonLightEnabled(lastvehicle, 3, false)
            QBCore.Functions.Notify('Neonlar Kapatıldı', 'error', 7500)
        else
            SetVehicleNeonLightEnabled(lastvehicle, 0, true)
            SetVehicleNeonLightEnabled(lastvehicle, 1, true)
            SetVehicleNeonLightEnabled(lastvehicle, 2, true)
            SetVehicleNeonLightEnabled(lastvehicle, 3, true)
            QBCore.Functions.Notify('Neonlar Açıldı', 'error', 7500)
        end
    elseif data.tip == "start" and inDriveSeat then
        SetVehicleEngineOn(lastvehicle, (not GetIsVehicleEngineRunning(lastvehicle)), false, true)

    QBCore.Functions.Notify("Araç Motoru Çalıştırıldı", "success")
    elseif data.tip == "otopilot" and inDriveSeat then
        ExecuteCommand("veh pilot")

    elseif data.tip == "bagaj" and inDriveSeat then
        if GetVehicleDoorAngleRatio(lastvehicle, 5) == 0 then
            SetVehicleDoorOpen(lastvehicle, 5, false, false)
            QBCore.Functions.Notify("Araç Bagajı Açıldı", "success")
        else
            SetVehicleDoorShut(lastvehicle, 5, false, false)
            QBCore.Functions.Notify("Araç Bagajı Kapatıldı", "error")
        end
    elseif data.tip == "kaput" and inDriveSeat then
        if GetVehicleDoorAngleRatio(lastvehicle, 4) == 0 then
            SetVehicleDoorOpen(lastvehicle, 4, false, false)
            QBCore.Functions.Notify("Araç Kaputu Açıldı", "success")
        else
            SetVehicleDoorShut(lastvehicle, 4, false, false)
            QBCore.Functions.Notify("Araç Kaputu Kapatıldı", "error")
        end
    elseif data.tip == "onsolcam" and inDriveSeat then
        onsolcam = not onsolcam
        if onsolcam then
            RollDownWindow(lastvehicle, 0)
            QBCore.Functions.Notify("Ön Sol Cam Açıldı", "success")
        else
            RollUpWindow(lastvehicle, 0)
            QBCore.Functions.Notify("Ön Sol Cam Kapatıldı", "error")
        end
    elseif data.tip == "onsagcam" and inDriveSeat then
        onsagcam = not onsagcam
        if onsagcam then
            RollDownWindow(lastvehicle, 1)
            QBCore.Functions.Notify("Ön Sağ Cam Açıldı", "success")
        else
            RollUpWindow(lastvehicle, 1)
            QBCore.Functions.Notify("Ön Sol Cam Kapatıldı", "error")
        end
    elseif data.tip == "arkasolcam" and inDriveSeat then
        arkasolcam = not arkasolcam
        if arkasolcam then
            RollDownWindow(lastvehicle, 2)
            QBCore.Functions.Notify("Arka Sol Cam Açıldı", "success")
        else
            RollUpWindow(lastvehicle, 2)
            QBCore.Functions.Notify("Arka Sol Cam Kapatıldı", "error")
        end
    elseif data.tip == "arkasagcam" and inDriveSeat then
        arkasagcam = not arkasagcam
        if arkasagcam then
            RollDownWindow(lastvehicle, 3)
            QBCore.Functions.Notify("Arka Sağ Cam Açıldı", "info")
        else
            RollUpWindow(lastvehicle, 3)
            QBCore.Functions.Notify("Arka Sol Cam Kapatıldı", "error")
        end
    elseif data.tip == "radio" and inDriveSeat then
        ExecuteCommand("music")
    end
end)
RegisterCommand("farlar", function(source, args)
    local vehicle = GetVehiclePedIsUsing(PlayerPedId())

    if args[1] == "ac" then
        SetVehicleLights(vehicle, 2)
        SetVehicleFullbeam(vehicle, true)
        QBCore.Functions.Notify("Farlar Açıldı", "error")
    elseif args[1] == "kapat" then
        SetVehicleLights(vehicle, 1)
        SetVehicleFullbeam(vehicle, false)
        QBCore.Functions.Notify("Farlar Kapatıldı", "error")
    else
        TriggerEvent('chat:addMessage', { args = { '^1Geçersiz argüman. Kullanım: /farlar [ac/kapat]' } })
    end
end, false)