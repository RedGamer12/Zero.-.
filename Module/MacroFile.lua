local MacroManager = {}
do
	MacroManager.Folder = 'LinoriaLibSettings'
	MacroManager.Ignore = {}

	function MacroManager:SetIgnoreIndexes(list)
		for _, key in next, list do
			self.Ignore[key] = true
		end
	end

	function MacroManager:SetFolder(folder)
		self.Folder = folder;
		self:BuildFolderTree()
	end

    function MacroManager:SetLibrary(library)
		self.Library = library
	end

    function MacroManager:ParseSettingsFromFile(filePath)
        if not isfile(filePath) then
            return nil
        end
    
        local fileContents = readfile(filePath)
        local settings = {}
    
        for line in fileContents:gmatch("[^\r\n]+") do
            local key, value = line:match("(.+)%s*:%s*(%S+)")
            if key and value then
                settings[key] = value
            end
        end
    
        return settings
    end

	function MacroManager:BuildFolderTree()
		local paths = {
			self.Folder .. '/macros'
		}

		for i = 1, #paths do
			local str = paths[i]
			if not isfolder(str) then
				makefolder(str)
			end
		end
	end

	function SaveManager:RefreshConfigList()
		local list = listfiles(self.Folder .. '/macros')
	
		local out = {}
		for i = 1, #list do
			local file = list[i]
			if file:sub(-4) == '.txt' then -- Thay đổi độ dài của chuỗi kiểm tra
				-- i hate this but it has to be done ...
	
				local pos = file:find('.txt', 1, true)
				local start = pos
	
				local char = file:sub(pos, pos)
				while char ~= '/' and char ~= '\\' and char ~= '' do
					pos = pos - 1
					char = file:sub(pos, pos)
				end
	
				if char == '/' or char == '\\' then
					table.insert(out, file:sub(pos + 1, start - 1))
				end
			end
		end
		
		return out
	end	

	function MacroManager:LoadAutoloadConfig()
		if isfile(self.Folder .. '/macros/autoload.txt') then
			local name = readfile(self.Folder .. '/macros/autoload.txt')

			local success, err = self:Load(name)
			if not success then
				return self.Library:Notify('Failed to load autoload macro config: ' .. err)
			end

			self.Library:Notify(string.format('Auto loaded macro config %q', name))
		end
	end

	function MacroManager:BuildConfigSection(tab)
		assert(self.Library, 'Must set MacroManager.Library')

		local section = tab:AddRightGroupbox('Settings')

		section:AddDropdown('MacroManager_ConfigList',
			{ Text = 'Macro File', Values = self:RefreshConfigList(), AllowNull = true })

		section:AddToggle('MacroManager_Enabled',
			{ Text = 'Macro Enabled' }):AddKeyPicker('MacroKeybind', { Default = 'B', NoUI = true, Text = 'Active Macro' })

		section:AddDivider()

		section:AddButton('Refresh list', function()
			Options.MacroManager_ConfigList:SetValues(self:RefreshConfigList())
			Options.MacroManager_ConfigList:SetValue(nil)
		end)

		section:AddButton('Set as autoload', function()
			local name = Options.MacroManager_ConfigList.Value
			writefile(self.Folder .. '/macros/autoload.txt', name)
			MacroManager.AutoloadLabel:SetText('Current autoload macro config: ' .. name)
			self.Library:Notify(string.format('Set %q to auto load', name))
		end)

		MacroManager.AutoloadLabel = section:AddLabel('Current autoload macro config: none', true)

		if isfile(self.Folder .. '/macros/autoload.txt') then
			local name = readfile(self.Folder .. '/macros/autoload.txt')
			MacroManager.AutoloadLabel:SetText('Current autoload macro config: ' .. name)
		end

		MacroManager:SetIgnoreIndexes({ 'MacroManager_ConfigList', 'MacroManager_ConfigName' })
	end

	MacroManager:BuildFolderTree()
end

return MacroManager
