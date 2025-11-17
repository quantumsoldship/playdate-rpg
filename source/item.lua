-- Item class
-- Example implementation for item system (expandable)

import "CoreLibs/object"

class('Item').extends()

function Item:init(name, itemType)
    Item.super.init(self)
    
    self.name = name or "Item"
    self.type = itemType or "misc"  -- Types: consumable, weapon, armor, misc
    self.description = ""
    self.value = 0  -- For healing, damage bonus, etc.
    self.price = 0
end

-- Use item
function Item:use(player)
    if self.type == "consumable" then
        if self.effect == "heal" then
            player:heal(self.value)
            return true, self.name .. " healed " .. self.value .. " HP!"
        end
    end
    
    return false, "Can't use this item."
end

-- Create item from template
function Item.fromTemplate(template)
    local item = Item(template.name, template.type)
    
    if template.description then item.description = template.description end
    if template.value then item.value = template.value end
    if template.price then item.price = template.price end
    if template.effect then item.effect = template.effect end
    if template.attackBonus then item.attackBonus = template.attackBonus end
    if template.defenseBonus then item.defenseBonus = template.defenseBonus end
    
    return item
end
