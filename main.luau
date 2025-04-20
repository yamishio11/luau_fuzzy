local BLOCKSIZE_MIN = 3
local SPAMSUM_LENGTH = 64
local _DEBUG = false

local function spamsum(data: string, slen: number): string
    local HASH_PRIME = 0x01000193 --magic number pulled from ppdeep
    local HASH_INIT = 0x28021967 --another magic number pulled from ppdeep
    local ROLL_WINDOW = 7 --i dont recomend changing this as it will end up trying to go out of bounds or subbing on a nil value
    local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

    local roll_win = {0, 0, 0, 0, 0, 0, 0}
    local roll_h1, roll_h2, roll_h3, roll_n = 0, 0, 0, 0
    local block_hash1, block_hash2 = HASH_INIT, HASH_INIT
    local hash_string1, hash_string2 = "", ""
    local block_size = BLOCKSIZE_MIN

    while (block_size * SPAMSUM_LENGTH) < slen do
        block_size *= 2
    end

    while true do
        if block_size < BLOCKSIZE_MIN then
            error("Calculated block size is too small")
        end

        for index = 1, #data do
            local b = data:byte(index)
            block_hash1 = bit32.bxor(bit32.band(block_hash1 * HASH_PRIME, 0xFFFFFFFF), b) --32
            block_hash2 = bit32.bxor(bit32.band(block_hash2 * HASH_PRIME, 0xFFFFFFFF), b) --32

            roll_h2 = roll_h2 - roll_h1 + (ROLL_WINDOW * b)
            roll_h1 = roll_h1 + b - roll_win[(roll_n % ROLL_WINDOW) + 1]
            roll_win[(roll_n % ROLL_WINDOW) + 1] = b
            roll_n = roll_n + 1
            roll_h3 = bit32.lshift(roll_h3, 5) % 0xFFFFFFFF
            roll_h3 = bit32.bxor(roll_h3, b)

            if _DEBUG then
                print(string.format("[[-%d-]]\nroll_h1: %d, roll_h2: %d, roll_h3: %d\nblock_hash1: %d, block_hash2: %d\nroll_win: %s\nroll_n: %d\nblock_size: %d\n---",
                index, roll_h1, roll_h2, roll_h3, block_hash1, block_hash2, table.concat(roll_win, ", "), roll_n, block_size)) --lol
            end

            local rh = roll_h1 + roll_h2 + roll_h3

            if (rh % block_size) == (block_size - 1) then
                if #hash_string1 < SPAMSUM_LENGTH - 1 then
                    hash_string1 = hash_string1 .. B64:sub((block_hash1 % 64) + 1, (block_hash1 % 64) + 1)
                    block_hash1 = HASH_INIT
                end
                if (rh % (block_size * 2)) == ((block_size * 2) - 1) then
                    if #hash_string2 < SPAMSUM_LENGTH // 2 - 1 then
                        hash_string2 = hash_string2 .. B64:sub((block_hash2 % 64) + 1, (block_hash2 % 64) + 1)
                        block_hash2 = HASH_INIT
                    end
                end
            end
        end

        if block_size > BLOCKSIZE_MIN and #hash_string1 < SPAMSUM_LENGTH // 2 then
            block_size //= 2
            roll_win = {0, 0, 0, 0, 0, 0, 0}
            roll_h1, roll_h2, roll_h3, roll_n = 0, 0, 0, 0
            block_hash1, block_hash2 = HASH_INIT, HASH_INIT
            hash_string1, hash_string2 = "", ""
        else
            local rh = roll_h1 + roll_h2 + roll_h3
            if rh ~= 0 then
                hash_string1 = hash_string1 .. B64:sub((block_hash1 % 64) + 1, (block_hash1 % 64) + 1)
                hash_string2 = hash_string2 .. B64:sub((block_hash2 % 64) + 1, (block_hash2 % 64) + 1)
            end
            break
        end
    end
    return string.format("%d:%s:%s", block_size, hash_string1, hash_string2)
end

local function hash(str) --might add proper buffer support another time
    if type(str) ~= "string" then
        error(string.format("Argument must be of string type, not %s", type(str)))
    end
    return spamsum(str, #str)
end

local function toHex(str: string): string
	return (str:gsub(".", function(c)
        return string.format("%02x", c:byte())
    end))
end

return setmetatable({ --makes it easier to call, just require this file and call it like a function
    spamsum = spamsum,
    toHex = toHex,
    hash = hash
}, {
    __call = function(_, ...)
        return toHex(hash(...))
    end
})