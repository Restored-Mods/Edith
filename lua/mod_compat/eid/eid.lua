if not EID then return end

-- Mod Icon (TODO)
EID:setModIndicatorName("Edith")
local iconSprite = Sprite()
iconSprite:Load("gfx/ui/eid_edith_icon.anm2", true)
EID:addIcon("Edith Icon", "EdithIcon", 0, 15, 24, 6, 6, iconSprite)
EID:setModIndicatorIcon("Edith Icon")

-- Birthright Icons
PlayerIconSprite = Sprite()
PlayerIconSprite:Load("gfx/ui/eid_edith_players_icons.anm2", true)
EID:addIcon("Player"..EdithRestored.Enums.PlayerType.EDITH, "Edith", 0, 12, 12, -1, 1, PlayerIconSprite)
--EID:addIcon("Player"..EdithRestored.Enums.PlayerType.EDITH_B, "EdithB", 0, 12, 12, -1, 1, PlayerIconSprite)

-- Edith
EID:addBirthright(EdithRestored.Enums.PlayerType.EDITH, "Jump charges faster and not stops charging when moving#Stomp has increased knockback that damages enemies when they collide with obstacles", "Edith", "en_us")
EID:addBirthright(EdithRestored.Enums.PlayerType.EDITH, "Прыжок заряжается быстрее и также заряжатеся при движении#Отбрасывание от презимления увеличено и наносит урон врагам, когда они сталкиваются со стеной/препятствием", "Эдит", "ru")
--EID:addBirthright(EdithRestored.Enums.PlayerType.EDITH, "La carga del salto será más rápida y no se detendrá al moverse", "Edith", "spa")

-- Tainted Edith
--[[EID:addBirthright(EdithRestored.Enums.PlayerType.EDITH_B, "All enemies that get near you will become slowed", "Tainted Edith", "en_us")
EID:addBirthright(EdithRestored.Enums.PlayerType.EDITH_B, "Todos los enemigos cercanos serán ralentizados", "Edith Contaminada", "spa")]]

-- Items

--The Chisel
--[[EID:addCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_THE_CHISEL, "When used, it will spawn on top of you and fall down, removing 1 stage of tranforming into a pepper statue.#After she's freed from being a statue, she will have a black powder-like effect for a short time.", "The Chisel")
EID:addCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_THE_CHISEL, "При использовании долото появится над вами и упадет на вас, удаляя 1 этап превращения в перцовую статую.#После удаления уровня на короткое время будет иметь эффект черного порошка.", "The Chisel", "ru")
EID:addCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_THE_CHISEL, "Al usarlo, un cincél caerá sobre ti, removiendo una fase de la transformación a una estatua de pimienta#Cuando Edith Contaminada se libera de ser una estatua, dejará un rastro de polvo por un corto tiempo", "El Cincel", "spa")]]


--Salt Shaker
EID:addCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_SALT_SHAKER, "On use creates ring of salt creep near Isaac#Enemies coming close to it get {{Fear}} fear effect", "​Salt Shaker")
EID:addCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_SALT_SHAKER, "При использовании создает круг из соли рядом с Айзеком#Враги, приближающиеся к нему, получают {{Fear}} эффект страха", "Солонка", "ru")

--Gorgon Mask
EID:addCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_GORGON_MASK, "On use puts on/off Gorgon mask#When mask is on, Isaac can't shoot#{{Freezing}} Looking at enemies, when Isaac has mask on, freezes them", "Gorgon Mask")
EID:addCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_GORGON_MASK, "При использовании одевает/снимает маску Горгоны#Когда маска одета, Айзек не может стрелять#{{Freezing}} Глядя на врагов, когда Айзек в маске, они каменеют", "Маска Горгоны", "ru")

--Lithium Salts
--EID:addCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_LITHIUM, "Todas las píldoras reducirán el daño y las lágrimas, pero aumentarán el tiempo de invencibilidad", "Sales de litio", "spa")
EID:addCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_LITHIUM, "Adds extra lithium pill that has 10% replace normal pill", "​Lithium Salts")
EID:addCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_LITHIUM, "Добовляет дополнительную пилюлю, которая может с шансом в 10% заменить обычную", "Литивые соли", "ru")

--Thunder Bombs
EID:addCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_THUNDER_BOMBS, "{{Battery}} Fully recharges active items#{{Battery}} When Isaac has no bombs, one can be placed at the cost of a charge#Bombs make electricity that spreads to nearby enemies#Electricity deals half of the bomb's damage", "​Thunder Bombs", "en_us")
EID:addCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_THUNDER_BOMBS, "{{Battery}} Полностью заряжает активные предметы#{{Battery}} Когда у Айзека нет бомб, одна может быть использована взамен на заряд#Бомбы создают электричество, которое распространяется на близлежащих врагов#Електричество наносит половину урона от бомб", "Громовые бомбы", "ru")

--Blasting Boots
EID:addCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_BLASTING_BOOTS, "Gives explosion immunity#Explosion launches Isaac in the air", "Blasting Boots", "en_us")
EID:addCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_BLASTING_BOOTS, "Дает устойчивость ко взрывам#Взрыв подбрасывет Айзека в воздух", "Взрывостойкие сапоги", "ru")

--Pawn Baby
EID:addCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_PAWN_BABY, "Brother Bobby-like familiar#{{Fear}} 20% chance to shoot fear tear#If enemy is near, stomps it#Regular enemies are killed instantly#Bosses take 20% of maximum HP damage", "​Salt Pawns", "en_us")
EID:addCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_PAWN_BABY, "Фамильяр, cхожий c братиком Бобби#{{Fear}} 20% шанс выстрелить слезой с эффектом страха#Если враг рядом, прыгает на него#Обычные враги убиваются мгновенно#Боссы получают урон, равный 20% от максимального здоровья", "Малыш-пешка", "ru")

--Salty Baby
EID:addCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_SALTY_BABY, "{{Chargeable}} Charges attack that spawns a ring of salt creep#{{Fear}} Creep fears nearby enemies", "​Salty Baby", "en_us")
EID:addCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_SALTY_BABY, "{{Chargeable}} Заряжающаяся атака, которая создает круг из соли#{{Fear}} Соль дает близлежащим врагам эффект страха", "Малыш-солонка", "ru")

--Sodom
EID:addCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_SODOM, "Every second when Isaac moves he shoots opposite his movement direction a red flame#Flame doesn't damage enemies but applies {{Burning}} burn effect on them that deals 80% Isaac's damage#On death with effect enemy shoots flames in 8 directions#These flames can also apply same effect#!!! Effect can be applied on enemy only one time", "​Sodom", "en_us")
EID:addCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_SODOM, "Каждую секунду Айзек, когда передвигается, выстреливает в противоположном направлении движения красное пламя#Пламя не наносит урона врагам, но накладывает на них эффект {{Burning}} горения, который наносит 80% урона Айзека#При смерти с эффектом враг выстреливает пламя в 8 направлениях#Это пламя может наложить этот же эффект#!!! Эффект можно наложить на врага только один раз", "Содом", "ru")

-- Trinkets
--Pepper Grinder
EID:addTrinket(EdithRestored.Enums.TrinketType.TRINKET_PEPPER_GRINDER, "Each time you kill an enemy, there's a 33% chance they will explode into pepper powder, which will leave a stain of black powder-like creep on the ground#It will slowly slide away from the killed enemy and fade away, dealing contact damage", "Pepper Grinder", "en_us")
EID:addTrinket(EdithRestored.Enums.TrinketType.TRINKET_PEPPER_GRINDER, "Каждый раз убивая врагов есть 33% шанс, что они взорвутся в перцовый порошок, который оставляет на земле пятно черного порошка#Он медленно соскальзывает с убитого врага и исчезает, нанося контактный урон", "Мельница для перца", "ru")
EID:addTrinket(EdithRestored.Enums.TrinketType.TRINKET_PEPPER_GRINDER, "Cada vez que mates a un enemigo, tiene un 33% de posibilidad de explotar en una nube de pimienta, la cual dejará una mancha de pimienta en el suelo, hace daño por contacto", "Molinillo de pimienta", "spa")

--Smelling Salts
EID:addTrinket(EdithRestored.Enums.TrinketType.TRINKET_SMELLING_SALTS, "Ignores fatal damage on hit#Destroyed after triggering effect", "Smelling Salts", "en_us")
EID:addTrinket(EdithRestored.Enums.TrinketType.TRINKET_SMELLING_SALTS, "Игнорирует смертельный урон#Уничтожается после срабатывания эффекта", "Нюхательная соль", "ru")

--Salt Rock
EID:addTrinket(EdithRestored.Enums.TrinketType.TRINKET_SALT_ROCK, "Entering new room has 10% chance for rock to become salt rock#Destroying salt rock spawns mini Edith statue that stomp enemies#If there are no enemies left, stomp randrom rock/poop", "Salt Rock", "en_us")
EID:addTrinket(EdithRestored.Enums.TrinketType.TRINKET_SALT_ROCK, "При входе в новую комнату 10% шанс камень может превратиться в соляной камень#Уничтожение соляного камня создает мини-статую Эдит, которая прыгает на врагов#Если врагов не осталось, прыгает на случайные камни/какашки", "Соляной камень", "ru")

-- Cards/Runes/Pills

local Lithium = {
    DAMAGE_DECREASE_AMOUNT = -0.20,
    FALSEPHD_DAMAGE_DECREASE_AMOUNT = -0.05,
    TEARS_DECREASE_AMOUNT = -0.12,
    FALSEPHD_TEARS_DECREASE_AMOUNT = -0.01,
    IFRAME_INCREASE_AMOUNT = 20,
    FALSEPHD_IFRAME_INCREASE_AMOUNT = 5,
}

EID:addPill(EdithRestored.Enums.Pickups.PillEffects.PILLEFFECT_LITHIUM, "#{{ArrowDown}} {{Blank}}{{Damage}} DAMAGE_DECREASE_AMOUNT Damage for every consumed pill#{{ArrowDown}} {{Blank}}{{Tears}} TEARS_DECREASE_AMOUNT Tear rate for every consumed pill#{{ArrowUp}} IFRAME_INCREASE_AMOUNT frames of invinsibility for every consumed pill", "Lithium")
EID:addPill(EdithRestored.Enums.Pickups.PillEffects.PILLEFFECT_LITHIUM, "#{{ArrowDown}} {{Blank}}{{Damage}} DAMAGE_DECREASE_AMOUNT к урону за каждую использованную пилюлю#{{ArrowDown}} {{Blank}}{{Tears}} TEARS_DECREASE_AMOUNT к скорострельности за каждую использованную пилюлю#{{ArrowUp}} IFRAME_INCREASE_AMOUNT кадров неуязвимости за каждую использованную пилюлю", "Литий", "ru")
EID:addHorsePill(EdithRestored.Enums.Pickups.PillEffects.PILLEFFECT_LITHIUM, "#{{ArrowDown}} {{Blank}}{{Damage}} DAMAGE_DECREASE_AMOUNT Damage for every consumed pill#{{ArrowDown}} {{Blank}}{{Tears}} TEARS_DECREASE_AMOUNT Tears for every consumed pill#{{ArrowUp}} IFRAME_INCREASE_AMOUNT frames of invinsibility for every consumed pill", "Lithium")
EID:addHorsePill(EdithRestored.Enums.Pickups.PillEffects.PILLEFFECT_LITHIUM, "#{{ArrowDown}} {{Blank}}{{Damage}} DAMAGE_DECREASE_AMOUNT к урону за каждую использованную пилюлю#{{ArrowDown}} {{Blank}}{{Tears}} TEARS_DECREASE_AMOUNT к скорострельности за каждую использованную пилюлю#{{ArrowUp}} IFRAME_INCREASE_AMOUNT кадров неуязвимости за каждую использованную пилюлю", "Литий", "ru")

local function LithiumCondition(descObj)
    if descObj.ObjType == 5 and descObj.ObjVariant == 70 and descObj.ObjSubType % 2048 == EdithRestored.Enums.Pickups.Pills.PILL_LITHIUM then
        return true
    end
    return false
end

local function LithiumCallback(descObj)
    local player = EdithRestored.Game:GetNearestPlayer(descObj.Entity.Position)
    local horseMul = descObj.ObjSubType > 2048 and 2 or 1
    if player:HasCollectible(CollectibleType.COLLECTIBLE_PHD) and not player:HasCollectible(CollectibleType.COLLECTIBLE_FALSE_PHD) then
        descObj.Description = descObj.Description:gsub(".*%#", "")
        descObj.Description = descObj.Description:gsub("IFRAME_INCREASE_AMOUNT", "+"..(Lithium.IFRAME_INCREASE_AMOUNT * horseMul))
    else
        local extra = nil
        for idx,_ in pairs(Lithium) do
            if idx:sub(1,9) ~= "FALSEPHD_" then
                if player:HasCollectible(CollectibleType.COLLECTIBLE_FALSE_PHD) then
                    if type(extra) == "nil" then extra = descObj.Description end
                    local amount = Lithium["FALSEPHD_"..idx] * horseMul
                    extra = extra:gsub(idx, amount > 0 and "+"..amount or amount)
                end
                local amount = Lithium[idx] * horseMul
                descObj.Description = descObj.Description:gsub(idx, amount > 0 and "+"..amount or amount)
            end
        end
        if type(extra) ~= "nil" then descObj.Description = descObj.Description..extra:gsub("#", "#{{Collectible654}} {{Blank}}") end
    end
    return descObj
end

EID:addDescriptionModifier("LithiumPHDFalsePHD", LithiumCondition, LithiumCallback)