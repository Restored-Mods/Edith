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
EID:addIcon("Player"..EdithCompliance.Enums.PlayerType.EDITH, "Edith", 0, 12, 12, -1, 1, PlayerIconSprite)
--EID:addIcon("Player"..EdithCompliance.Enums.PlayerType.EDITH_B, "EdithB", 0, 12, 12, -1, 1, PlayerIconSprite)

-- Edith
EID:addBirthright(EdithCompliance.Enums.PlayerType.EDITH, "Jump charges faster and not stops charging when moving#Knockback from stomp increased and damages enemies when they collide with wall/obstacle", "Edith", "en_us")
EID:addBirthright(EdithCompliance.Enums.PlayerType.EDITH, "Прыжок заряжается быстрее и также заряжатеся при движении#Отбрасывание от презимления увеличено и наносит урон врагам, когда они сталкиваются со стеной/препятствием", "Эдит", "ru")
EID:addBirthright(EdithCompliance.Enums.PlayerType.EDITH, "La carga del salto será más rápida y no se detendrá al moverse", "Edith", "spa")

-- Tainted Edith
--[[EID:addBirthright(EdithCompliance.Enums.PlayerType.EDITH_B, "All enemies that get near you will become slowed", "Tainted Edith", "en_us")
EID:addBirthright(EdithCompliance.Enums.PlayerType.EDITH_B, "Todos los enemigos cercanos serán ralentizados", "Edith Contaminada", "spa")]]

-- Items

--The Chisel
--[[EID:addCollectible(EdithCompliance.Enums.CollectibleType.COLLECTIBLE_THE_CHISEL, "When used, it will spawn on top of you and fall down, removing 1 stage of tranforming into a pepper statue.#After she's freed from being a statue, she will have a black powder-like effect for a short time.", "The Chisel")
EID:addCollectible(EdithCompliance.Enums.CollectibleType.COLLECTIBLE_THE_CHISEL, "При использовании долото появится над вами и упадет на вас, удаляя 1 этап превращения в перцовую статую.#После удаления уровня на короткое время будет иметь эффект черного порошка.", "The Chisel", "ru")
EID:addCollectible(EdithCompliance.Enums.CollectibleType.COLLECTIBLE_THE_CHISEL, "Al usarlo, un cincél caerá sobre ti, removiendo una fase de la transformación a una estatua de pimienta#Cuando Edith Contaminada se libera de ser una estatua, dejará un rastro de polvo por un corto tiempo", "El Cincel", "spa")]]


--Lithium salts
EID:addCollectible(EdithCompliance.Enums.CollectibleType.COLLECTIBLE_LITHIUM, "Todas las píldoras reducirán el daño y las lágrimas, pero aumentarán el tiempo de invencibilidad", "Sales de litio")
EID:addCollectible(EdithCompliance.Enums.CollectibleType.COLLECTIBLE_LITHIUM, "All pills lower damage and tears but increase your amount of invincibility time", "Lithium Salts")
EID:addCollectible(EdithCompliance.Enums.CollectibleType.COLLECTIBLE_LITHIUM, "Все пилюли понижают урон и скорострельность, но увеличивают количество времени неуязвимости", "Lithium Salts", "ru")

-- Trinkets
--Pepper Grinder
EID:addTrinket(EdithCompliance.Enums.TrinketType.TRINKET_PEPPER_GRINDER, "Each time you kill an enemy, there's a 33% chance they will explode into pepper powder, which will leave a stain of black powder-like creep on the ground#It will slowly slide away from the killed enemy and fade away, dealing contact damage", "Pepper Grinder", "en_us")
EID:addTrinket(EdithCompliance.Enums.TrinketType.TRINKET_PEPPER_GRINDER, "Каждый раз убивая врагов есть 33% шанс, что они взорвутся в перцовый порошок, который оставляет на земле пятно черного порошка#Он медленно соскальзывает с убитого врага и исчезает, нанося контактный урон", "Мельница для перца", "ru")
EID:addTrinket(EdithCompliance.Enums.TrinketType.TRINKET_PEPPER_GRINDER, "Cada vez que mates a un enemigo, tiene un 33% de posibilidad de explotar en una nube de pimienta, la cual dejará una mancha de pimienta en el suelo, hace daño por contacto", "Molinillo de pimienta", "spa")

-- Cards/Runes
