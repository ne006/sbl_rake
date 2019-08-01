namespace :sbl do
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

    desc "Pull Git-versioned files from server"
    task :files, [:env] do |task, args|
      env = args.env || "dev"

      appserver = CONFIG.env.send(env.to_sym).app
      local = CONFIG.env.local.app
      global = CONFIG.env.global

      git = Git.open(global.git_repo, :log => LOG)
      git.pull
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

		desc "Get SRF and files from server"
		multitask :regular, [:env] => [:srf, :files, :images]
	end
end
