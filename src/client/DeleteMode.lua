local DeleteMode = {}

local active = false

function DeleteMode.isActive()
    return active
end

function DeleteMode.setState(state)
    active = state and true or false
    if DeleteMode._listener then
        DeleteMode._listener(active)
    end
end

function DeleteMode.toggle()
    DeleteMode.setState(not active)
end

function DeleteMode.bind(callback)
    DeleteMode._listener = callback
end

return DeleteMode 