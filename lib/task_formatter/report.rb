class Report
	def initialize data
		@data = data
	end
	
	def format format = :yml
		case format
		when :yml
			YAML.dump(@data)
		when :table
			[[nil, "Name", "Type", nil].join("||")]
			.push(@data.reduce([]) do |table, type|
				type.last.each do |member|
					table.push([nil, member,type.first, nil].join("|"))
				end
				table
			end)
		end
	end
end