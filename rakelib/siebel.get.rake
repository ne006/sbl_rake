namespace :siebel do
	namespace :get do
		desc "Get runtime srf from server"
		task :srf, [:env] do |task, args|
			env = args.env || "dev"

			appserver = CONFIG.env.send(env.to_sym).app
			local = CONFIG.env.local.app
			global = CONFIG.env.global

			srf_path = Pathname.new("objects").join(global.language)
			backup_srf_name = Pathname.new(local.name).join(local.dir, srf_path).realpath.join("siebel_sia_#{Time.now.strftime("%Y%m%d_%H-%M-%S")}.srf")

			if File.exists? Pathname.new(local.name).join(local.dir, srf_path).realpath.join("siebel_sia.srf")
				LOG.info "Backing up current srf to #{backup_srf_name}"
				FileUtils.mv Pathname.new(local.name).join(local.dir, srf_path).realpath.join("siebel_sia.srf"), backup_srf_name
			end

			Net::SFTP.start(appserver.name, appserver.user, password: appserver.password) do |session|
				session.download!(
					Pathname.new(appserver.dir).join(srf_path, "siebel_sia.srf"),
					Pathname.new(local.name).join(local.dir, srf_path).realpath.join("siebel_sia.srf").to_s
				) do |event, downloader, *args|
					case event
					when :open
						LOG.info "Starting download: #{args[0].remote} -> #{args[0].local} (#{args[0].size} bytes)"
					when :get
					when :close
						#LOG.info "finished with #{args[0].remote}"
					when :finish
						LOG.info "SRF downloaded"
					end
				end
			end
			
			Rake::Task["siebel:script:genbs"].reenable
			Rake::Task["siebel:script:genbs"].invoke
		end

		desc "Get JavaScript files from server"
		task :js, [:env] do |task, args|
			env = args.env || "dev"

			appserver = CONFIG.env.send(env.to_sym).app
			local = CONFIG.env.local.app
			global = CONFIG.env.global

			begin
			Net::SFTP.start(appserver.name, appserver.user, password: appserver.password) do |session|
				session.download!(
					Pathname.new(appserver.dir).join("webmaster", "siebel_build", "scripts"),
					Pathname.new(local.name).join(local.dir, "PUBLIC", global.language, global.siebel_build.to_s, "scripts").realpath.to_s,
					recursive: true
				) do |event, downloader, *args|
					case event
					when :open
						#LOG.info "Starting download: #{args[0].remote} -> #{args[0].local} (#{args[0].size} bytes)"
					when :get
					when :close
						#LOG.info "finished with #{args[0].remote}"
					when :finish
						LOG.info "JS files refreshed from webmaster"
					end
				end
			end
			rescue Errno::EACCES => e
				LOG.error e.message
			end
			Dir.chdir(Pathname.new(local.name).join(local.dir, "PUBLIC", global.language, global.siebel_build.to_s, "scripts", "siebel", "custom").realpath.to_s);
			`git add .`
			`git commit -m "Backup commit at #{Time.now.strftime("%Y%m%d %H-%M-%S")}"`			
			LOG.info "Committed files to git repository"
		end

		desc "Get CSS and other files from server"
		task :css, [:env] do |task, args|
			env = args.env || "dev"

			appserver = CONFIG.env.send(env.to_sym).app
			local = CONFIG.env.local.app
			global = CONFIG.env.global

			Net::SFTP.start(appserver.name, appserver.user, password: appserver.password) do |session|
				session.download!(
					Pathname.new(appserver.dir).join("webmaster", "files", global.language),
					Pathname.new(local.name).join(local.dir, "PUBLIC", global.language, "files").realpath.to_s,
					recursive: true
				) do |event, downloader, *args|
					case event
					when :open
						#LOG.info "Starting download: #{args[0].remote} -> #{args[0].local} (#{args[0].size} bytes)"
					when :get
					when :close
						#LOG.info "finished with #{args[0].remote}"
					when :finish
						LOG.info "CSS files refreshed from webmaster"
					end
				end
			end
		end
		
		desc "Get images from server"
		task :images, [:env] do |task, args|
			env = args.env || "dev"

			appserver = CONFIG.env.send(env.to_sym).app
			local = CONFIG.env.local.app
			global = CONFIG.env.global

			Net::SFTP.start(appserver.name, appserver.user, password: appserver.password) do |session|
				session.download!(
					Pathname.new(appserver.dir).join("webmaster", "images", global.language),
					Pathname.new(local.name).join(local.dir, "PUBLIC", global.language, "IMAGES").realpath.to_s,
					recursive: true
				) do |event, downloader, *args|
					case event
					when :open
						#LOG.info "Starting download: #{args[0].remote} -> #{args[0].local} (#{args[0].size} bytes)"
					when :get
					when :close
						#LOG.info "finished with #{args[0].remote}"
					when :finish
						LOG.info "Images refreshed from webmaster"
					end
				end
			end
		end

		desc "Get webtemplates from server"
		task :webtemplates, [:env] do |task, args|
			env = args.env || "dev"

			appserver = CONFIG.env.send(env.to_sym).app
			local = CONFIG.env.local.app
			global = CONFIG.env.global

			Net::SFTP.start(appserver.name, appserver.user, password: appserver.password) do |session|
				session.download!(
					Pathname.new(appserver.dir).join("webtempl"),
					Pathname.new(local.name).join(local.dir, "WEBTEMPL").realpath.to_s,
					recursive: true
				) do |event, downloader, *args|
					case event
					when :open
						#LOG.info "Starting download: #{args[0].remote} -> #{args[0].local} (#{args[0].size} bytes)"
					when :get
					when :close
						#LOG.info "finished with #{args[0].remote}"
					when :finish
						LOG.info "Web templates refreshed from webmaster"
					end
				end
			end
		end

		desc "Get SRF, JavaScript and CSS files from server"
		multitask :regular, [:env] => [:srf, :js, :css, :images]

		desc "Get all files from server"
		multitask :all, [:env] => [:regular, :webtemplates]
	end
end