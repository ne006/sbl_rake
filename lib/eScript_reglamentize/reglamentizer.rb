#!/usr/bin/env ruby

class Reglamentizer

	attr_reader :source
	attr_accessor :output
	attr_accessor :variables
	
	def initialize source
		@source = source
		@variables = []
		@output = ""
	end
	
	def format
		detect_variables
		wrap_in_catch
	end
	
	private
	
	def detect_variables
		source.each_line do |line|
			match = line.match /.*var\s*(?<var_names>[^=;]+)(\s*?=\s?.?)?/
			self.variables += match[:var_names].split(/\s*,\s*/).map do |var| 
				var.split(/\s*:\s*/).first
			end.map(&:strip) if match
		end
	end
	
	def wrap_in_catch
		self.output = <<~SCRIPT
			try
			{
			#{ @source.lines.map { |l| "\t"+l }.join() }}
			catch(e)
			{
				TheApplication().RaiseErrorText(e.message);
			}
			finally
			{
			#{self.variables.reverse.map{ |var| "\t#{var} = null;" }.join("\n") }
			}
		SCRIPT
	end
end