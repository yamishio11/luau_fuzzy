local function levenshtein(s,t)
    if s == t then return 0 end
    if string.len(s) == 0 then return string.len(t) end
    if string.len(t) == 0 then return string.len(s) end
    local v0 = {}
    local v1 = {}
    for i = 0, string.len(t) do
        v0[i] = i
        v1[i] = 0
    end
    for i = 0, string.len(s) - 1 do
        v1[0] = i + 1
        for j = 0, string.len(t) - 1 do
            local cost = s:sub(i + 1, i + 1) == t:sub(j + 1, j + 1) and 0 or 1
            v1[j + 1] = math.min(v1[j] + 1, v0[j + 1] + 1, v0[j] + cost)
        end
        for j = 0, string.len(t) do
            v0[j] = v1[j]
        end
    end
    return v1[string.len(t)]
end