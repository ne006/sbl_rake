require_relative '../lib/task_formatter/report.rb'

namespace :task do
	desc "Setup folders for a new task"
	task :new, [:task_id] do |task, args|
		project = CONFIG.project
		release = CONFIG.current_release
		task_id = args.task_id

		work_dir = Pathname.new "C:/Users/#{Helpers.username}"

		#Replace asterisk with current release
		task_id.sub!(/\*/, "#{release}-")

		#Task directory
		task_dir = work_dir.join("Documents", project, release, task_id)
		#Task report filename
		task_file = task_dir.join("#{task_id}.yml")

		#Create directories down to report_dir
		task_dir.descend do |dir|
			unless Dir.exists? dir
				Dir.mkdir dir
				LOG.info "Created '#{dir}'"
			end
		end

		#Create task file template
		username = Helpers.username
		today = Date.today.strftime "%d%m%Y"
		boilerplate = <<~BOILERPLATE
			###{username} #{today} #{task_id}
			---

			...
			BOILERPLATE

		if File.exists? task_file
			LOG.warn "File '#{task_file}' alredy exists. Overwrite?: (Y/N)"
			answer = STDIN.getc
			exit unless answer.match /[YyДд]/
		end

		File.write task_file, boilerplate, encoding: "utf-8"
		LOG.info "Created '#{task_file}'"
	end

	desc "Format report in current dir"
	task :format, [:format] do |task, args|
			#Get current dir
			cur_dir = Dir.new task.application.original_dir
			#Get name of the current dir - task_id
			task_id = cur_dir.path.split("/").last

			#Select YAML (.yml, .yaml, ...) files with name starting with report id
			task_file = cur_dir.entries.select do |file|
				file.match(Regexp.new(task_id+".*\.(yml|yaml)"))
			end.first

			report = Report.new YAML.load_file(Pathname.new(cur_dir).join(task_file))

			puts report.format :table
	end
end
