local ffi = require('cdef')

local M = {}
M.Null			= 0x00
M.Turf			= 0x01
M.Obj			= 0x02
M.Mob			= 0x03
M.Area			= 0x04
M.Client		= 0x05
M.Image			= 0x0D
M.World			= 0x0E
M.Global		= 0x0E
M.Datum			= 0x21
M.Savefile		= 0x23
M.Path			= 0x26
M.Null			= 0x00
M.Turf			= 0x01
M.Obj			= 0x02
M.Mob			= 0x03
M.Area			= 0x04
M.String		= 0x06
M.World			= 0x0E
M.List			= 0x0F
M.Datum			= 0x21
M.Path			= 0x26
M.Number 		= 0x2A

M.types = {
	[0x00] = "Null"        ,
	[0x01] = "Turf"        ,
	[0x02] = "Obj"         ,
	[0x03] = "Mob"         ,
	[0x04] = "Area"        ,
	[0x05] = "Client"      ,
	[0x0D] = "Image"       ,
	[0x0E] = "World"       ,
	[0x0E] = "Global"      ,
	[0x21] = "Datum"       ,
	[0x23] = "Savefile"    ,
	[0x26] = "Path"        ,
	[0x06] = "String"      ,
	[0x0E] = "World"       ,
	[0x0F] = "List"        ,
	[0x21] = "Datum"       ,
	[0x26] = "Path"        ,
	[0x2A] = "Number"      ,
	["Null"] = 0x00        ,
	["Turf"] = 0x01        ,
	["Obj"] = 0x02         ,
	["Mob"] = 0x03         ,
	["Area"] = 0x04        ,
	["Client"] = 0x05      ,
	["Image"] = 0x0D       ,
	["World"] = 0x0E       ,
	["Global"] = 0x0E      ,
	["Datum"] = 0x21       ,
	["Savefile"] = 0x23    ,
	["Path"] = 0x26        ,
	["String"] = 0x06      ,
	["World"] = 0x0E       ,
	["List"] = 0x0F        ,
	["Datum"] = 0x21       ,
	["Path"] = 0x26        ,
	["Number"] = 0x2A
}

M.null = ffi.new('Value', {type = M.Null, value = 0})
M.world = setmetatable({handle={type = M.World, value = 0x0}}, datumM)
M.global = setmetatable({handle={type = M.World, value = 0x1}}, datumM)

return M