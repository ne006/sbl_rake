namespace :siebel do
	namespace :open do
		desc "Launch tools for env, user, password"
		task :tools, [:env, :login, :password] do |task, args|
			tools = CONFIG.env.tools
			dir = Pathname.new(tools.dir)
			
			env = args.env || "SIEB496"
			login = args.login || tools&.users[env]&.user || Helpers.username
			password = args.password || tools&.users[env]&.password || Helpers.username
			
			cmd = "'#{dir.join("BIN", "siebdev.exe")}' /c '#{dir.join("BIN", tools.language, tools.config).to_s.gsub("/", "\\")}' /d #{env} /u #{login} /p #{password} /iPackMode"
			
			LOG.info "Launching Siebel Tools for #{login}/#{password}@#{env}"
			Helpers.fork(cmd)
		end
		
		desc "Launch client for env, user, password and app=APP"
		task :client, [:env, :login, :password] do |task, args|
			local = CONFIG.env.local
			dir = Pathname.new(local.app.name).join(local.app.dir)
		
			env = args.env || "SIEB496"
			login = args.login || Helpers.username
			password = args.password || Helpers.username
			app = ENV["app"] || "fins"
			app_cfg = local&.apps&.send(app.to_sym)
			lang = (app_cfg&.language || CONFIG.env.global.language || "RUS").upcase
			browser = ENV["browser"] || "chrome"
			
			browser_paths = {
				"chrome": "C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe",
				"chromium": "C:\\Users\\itikhomirov\\AppData\\Local\\Chromium\\Application\\chrome.exe"
			}
			
			cmd = [
				"'#{dir.join("BIN", "siebel.exe")}' /c '#{dir.join("BIN", lang, app_cfg&.config).to_s.gsub("/", "\\")}' /d #{env} /u #{login} /p #{password} /b #{browser_paths[browser]}"
			]
			
			LOG.info "Launching #{app_cfg&.name || app} #{lang} for #{login}/#{password}@#{env}"
			Helpers.fork(cmd.join(" && "))
		end	
	end
end