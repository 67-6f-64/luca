--
--   This file is part of luca.
--
--   luca is free software: you can redistribute it and/or modify
--   it under the terms of the GNU General Public License as published by
--   the Free Software Foundation, either version 3 of the License, or
--   (at your option) any later version.
--
--   luca is distributed in the hope that it will be useful,
--   but WITHOUT ANY WARRANTY; without even the implied warranty of
--   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--   GNU General Public License for more details.
--
--   You should have received a copy of the GNU General Public License
--   along with luca.  If not, see <http://www.gnu.org/licenses/>.
--

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

-- debug
-------------------------------------
-- Set the type of debugger to use
-- @param type (1=windows, 2=VEH 3=Kernel, nil=no debugging active)
-------------------------------------
function util.debug(type)
    debugProcess(type)
end

local luca = {}

luca.p_image_memory = 0x0
luca.m_image_base = 0x0
luca.m_image_size = 0x0
luca.m_image_end = 0x0
luca.m_macro_crc = 0x0
luca.m_read_crc = 0x0
-- GMS v182.2
-- https://gist.github.com/f-ve/51b1286bcc835e2eccce38e91b24320b

-- Init
-------------------------------------
-- Sets image calculations
-- @param module to set image sizes
-------------------------------------
function luca.Init(module)
    util.debug(2)
    luca.SetImageBase(module)
    luca.SetImageSize(module)
    luca.SetImageEnd(module)
    luca.FindMacroCRC()
    luca.FindReadCRC()
    luca.Copy()
    -- TODO: should i add tramps?
    luca.MacroCRC()
    luca.ReadCRC()
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
    autoAssemble(string.format([[
        globalalloc(luca.p_image_memory, (luca.m_image_end - luca.m_image_base))
        readmem(luca.p_image_memory, (luca.m_image_end - luca.m_image_base))
    ]]))
end

-- FindMacroCRC
-------------------------------------
-- Finds MacroCRC address
-------------------------------------
function luca.FindMacroCRC() 
    -- TODO: bp 00401000 - debug_setBreakpoint is bugged.
    -- TBreakOption = (bo_Break = 0, bo_ChangeRegister = 1, bo_FindCode = 2,
    -- TBreakpointTrigger = (bptExecute=0, bptAccess=1, bptWrite=2);
    debug_setBreakpoint(luca.m_image_base, )
end


-- FindReadCRC
-------------------------------------
-- Finds ReadCRC address
-------------------------------------
function luca.FindMacroCRC() 
    -- TODO: bp luca.m_macro_crc
     debug_setBreakpoint(luca.m_macro_crc)
end


-- MacroCRC
-------------------------------------
-- Simulates MacroCRC
-------------------------------------
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
        // add al, [ecx]
        // pop ecx
        // push ecx
        jmp dword ptr[luca.m_macro_crc]
    ]]))
end

-- ReadCRC
-------------------------------------
-- Simulates ReadCRC
-------------------------------------
function luca.ReadCRC()
    autoAssemble(string.format([[
        cmp edx, [luca.m_image_base]
        jb Return
        cmp edx, [luca.m_image_end]
        ja Return
        sub edx, [luca.m_image_base]
        add edx, [luca.p_image_memory]
        jmp Return

        Return:
	// mov eax, [eax]
	// add [ecx], eax
	// mov esi, ebp
        jmp dword ptr[luca.m_read_crc]
    ]]))
end
