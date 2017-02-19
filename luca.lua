--
-- luca
-- Lua Updates CRC Automatically
--
-- @author FIVE (i.f-ve@ya.ru)
-- @version (2/19/2017)



local util = {} 

-- tohex
-------------------------------------
-- Converts integers to hex numbers
-- @param module to set image sizes
-------------------------------------
function util.tohex(number)
    local hexstr = '0123456789abcdef'
    local sout = ''
    while number > 0 do
        local mod = math.fmod(number, 16)
        sout = string.sub(hexstr, mod + 1, mod + 1) .. sout
        number = math.floor(number / 16)
    end
    if sout == '' then
        sout = '0'
    end
    return '0x' .. tonumber(sout)
end


local luca = {}

luca.p_image_memory = 0x0
luca.m_image_base = 0x0
luca.m_image_size = 0x0
luca.m_image_end = 0x0
luca.m_macro_crc = 0x0
luca.m_read_crc = 0x0


-- Inits
-------------------------------------
-- Sets image calculations
-- @param module to set image sizes
-------------------------------------
function luca.Init(module)
    luca.SetImageBase(module)
    luca.SetImageSize(module)
    luca.SetImageEnd(module)
end

-- SetImageBase
-------------------------------------
-- Sets image base address 
-- @param module get base address of
-------------------------------------
function luca.SetImageBase(module) 
    luca.m_image_base = (tohex(getAddress(module)))
end

-- SetImageSize
-------------------------------------
-- Sets image size address 
-- @param module get size of 
-------------------------------------
function luca.SetImageSize(module) 
    luca.m_image_size = (tohex(getModuleSize(module)))
end

-- SetImageEnd
-------------------------------------
-- Gets image end address 
-------------------------------------
function luca.SetImageEnd() 
    luca.m_image_end = (tohex(luca.m_image_base + luca.m_image_size))
end

-- Copy
-------------------------------------
-- Copies image
-------------------------------------
function luca.Copy() 
    globalalloc(luca.p_image_memory, (luca.m_image_end - luca.m_image_base))
    readmem(luca.p_image_memory, (luca.m_image_end - luca.m_image_base))
    -- TODO:
end

function luca.MacroCRC()
    autoAssemble(string.format([[
		cmp edx, [luca.m_image_base]
		jb Return
		cmp edx, [luca.m_image_end]
		ja Return
		sub edx, [luca.m_image_base]
		add edx, [luca.p_image_memory]
		jmp Return

		Return:
		/*
		add al, [edx]
		pop edx
		pop ebx
		push ecx
		*/
		jmp dword ptr[luca.m_macro_crc]

end

