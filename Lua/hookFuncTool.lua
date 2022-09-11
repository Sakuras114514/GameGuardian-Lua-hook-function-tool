bs = print
funcTable = {}
for k, v in pairs(_ENV) do
	if (type(v) == 'function') then
		funcTable[#funcTable + 1] = k
	end
	if (type(v) == 'table' and k ~= 'package' and k ~= '_G' and k ~= 'funcTable') then
		for key, value in pairs(_ENV[k]) do
			funcTable[#funcTable + 1] = k .. '.' .. key
		end
	end
end

function saveCallFunc(...)
	n = n + 1
	if (debug.getinfo(3).name == 'dofile' and isDofile == nil) then
		isDofile = true
		return 0
	end
	if (debug.getinfo(3).name == 'sethook' and isSetHook == nil) then
		isSetHook = true
		return 0
	end
	funcTable[#funcTable + 1] = debug.getinfo(3).name
end

function runScriptMenu()
	local file = gg.prompt({'运行脚本路径'},{'/sdcard/'},{'file'})
	if (file) then
		if (io.open(file[1]) == nil) then
			gg.alert('文件不存在或无访问权限')
			return 0
		end
		if (loadfile(file[1]) == nil) then
			gg.alert('脚本编译错误')
			return 0
		end
		pathname = file[1]
		pathname2 = file[1]
	end
end

function getFunc()
	if (pathname == nil) then
		gg.alert('未设置脚本')
		return 0
	end
	debug.sethook(saveCallFunc, 'c')
	dofile(pathname)
	debug.sethook()
	gg.alert('获取完毕')
	table.sort(funcTable)
end

function chooseHookFunc()
	local chooseFunc = {}
	if (pathname == nil) then
		gg.alert('未设置脚本')
		return 0
	end
	local SN = gg.multiChoice(funcTable, nil, '请选择要hook的func')
	if (SN) then
		for k, v in pairs(SN) do
			if (v == true) then
				chooseFunc[#chooseFunc + 1] = funcTable[k]
			end
		end
		io.open('/sdcard/tmp.tmp', 'w')
		files = io.open('/sdcard/tmp.tmp', 'a+')
		for k, v in ipairs(chooseFunc) do
			writeNewFunc(v)
		end
	end
end

function writeNewFunc(func)
	while true do
		::last::
		local hook = gg.prompt({'请输入要Hook的代码\n当前函数: ' .. func, '是否输出参数'}, {'return', false}, {'text', 'checkbox'})
		if (hook) then
			if (hook[2]) then
				files:write('function ' .. func .. '(...)\nbs(...)\n' .. hook[1] .. '\nend\n')
			else
				files:write('function ' .. func .. '(...)\n' .. hook[1] .. '\nend\n')
			end
			if (loadfile('/sdcard/tmp.tmp') == nil) then
				gg.alert('代码编写错误，清重写编写')
				io.open('/sdcard/tmp.tmp', 'w')
				goto last
			else
				dofile('/sdcard/tmp.tmp')
				dofile(pathname)
				break
			end
		end
	end
end
local pathname
pathname2 = '无'
n = 1
function main()
	local SN = gg.choice({
		'获取函数',
		'设置脚本',
		'hook函数',
		'退出脚本'
	}, nil, 'By.Sakuras\n当前设置运行脚本为: ' .. pathname2)
	if (SN == nil) then
	else
		if (SN == 1) then
			getFunc()
		elseif (SN == 2) then
			runScriptMenu()
		elseif (SN == 3) then
			chooseHookFunc()
		else
			os.exit()
		end
	end
end

gg.showUiButton()
while true do
	if (gg.isClickedUiButton()) then
		main()
	end
end