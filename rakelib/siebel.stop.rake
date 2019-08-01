namespace :siebel do
	namespace :stop do
		desc "Stop Siebel Tools"
		task :tools do |task, args|		
			cmd = [
				"taskkill /F /IM siebdev.exe",
				"exit"
			]
			
			Helpers.fork(cmd.join(" && "))
		end
		
		desc "Stop Siebel Client"
		task :client do |task, args|
			cmd = [
				"taskkill /F /IM siebel.exe",
				"exit"
			]
			
			Helpers.fork(cmd.join(" && "))
		end
		
		desc "Stop Google Chrome"
		task :chrome do |task, args|
			cmd = [
				"taskkill /F /IM chrome.exe",
				"exit"
			]
			
			Helpers.fork(cmd.join(" && "))
		end
	end
end