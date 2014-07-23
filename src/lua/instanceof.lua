-- Hack to get table address as unique id
function gettableid(obj)
    -- Check if is table
    if type(obj) == "table" then
        -- If obj has a metatable we have to temporary
        -- save the potential tostring function
        if getmetatable(obj) then
            local save = getmetatable(obj).__tostring
            getmetatable(obj).__tostring = nil
            -- native tostring which returns "table: 0x..."
            local id = tostring(obj)
            -- restore tostring function
            getmetatable(obj).__tostring = save
            return id
        else
            -- else simply return native tostring
            return tostring(obj)
        end
    end
 
    return nil
end

function instanceof (object, class)
    if type(object) == "table" then
        local classid = gettableid(class)
        local mt = getmetatable(object).__index
 
        while mt do
            if gettableid(mt) == classid then
                return true
            end
 
            if getmetatable(mt) then
                mt = getmetatable(mt).__index
            else
                mt = nil
            end
        end
    end
 
    return false
end
 
