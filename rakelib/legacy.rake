namespace :legacy do
  namespace :sbl do
  	namespace :get do

  		desc Helpers.legacy_task("Get JavaScript files from server")
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

  		desc Helpers.legacy_task("Get CSS and other files from server")
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
  	end
  end
end
