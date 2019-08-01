namespace :sbl do
	namespace :script do
		desc "Reglamentize script"
		task :regl do |task, args|
			require(Pathname.new(task.application.find_rakefile_location.last).join("lib/eScript_reglamentize/reglamentizer.rb"))
			require 'win32/clipboard'

			regl = Reglamentizer.new(Win32::Clipboard.data)
			regl.format
			puts regl.output
			Win32::Clipboard.set_data(regl.output)
		end

		desc "Generate browser scripts"
		task :genbs, [:env] do |task, args|
			env = args.env || "dev"

			appserver = CONFIG.env.send(env.to_sym).app
			local = CONFIG.env.local.app
			global = CONFIG.env.global

			LOG.info "Generating browser scripts:"

			system("#{Pathname.new(local.name).join(local.dir, "BIN", "genbscript.exe")} #{Pathname.new(local.name).join(local.dir, "BIN", global.language, "fins_oui.cfg")} #{Pathname.new(local.name).join(local.dir, "PUBLIC", global.language)} #{global.language}")
		end
	end
end
