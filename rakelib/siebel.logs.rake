namespace :siebel do
	namespace :logs do
		desc "Clean Siebel logs"
		task :clean, [:app] do |task, args|
			app = args.app || "client"
			
			local = CONFIG.env.local.app
			tools = CONFIG.env.tools
			
			case app
			when "client"
				dir = Pathname.new(local.name).join(local.dir, "LOG")
			when "tools"
				dir = Pathname.new(tools.dir).join("LOG")
			else
				LOG.warn "#{app} application is not supported"
				return
			end
			
			Dir.entries(dir).entries.each do |f|
				next if [".", ".."].include? f
				if(f.match?(/.+.\log$/) || f.match?(/.+.\dmp$/))
					File.delete(Pathname.new(dir).join(f))
				end
			end
		end
		
		desc "Open Siebel logs dir"
		task :open, [:app] do |task, args|
			app = args.app || "client"
			
			local = CONFIG.env.local.app
			tools = CONFIG.env.tools
			
			case app
			when "client"
				dir = Pathname.new(local.name).join(local.dir, "LOG")
			when "tools"
				dir = Pathname.new(tools.dir).join("LOG")
			else
				LOG.warn "#{app} application is not supported"
				return
			end
			
			if Gem.win_platform?
				`explorer.exe #{dir.to_s.gsub("/", "\\")}`
			else
				`cd #{dir}`
			end
		end
	end
end