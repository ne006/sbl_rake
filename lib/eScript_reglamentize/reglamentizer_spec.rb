#!/usr/bin/env ruby

require 'rspec'
require './reglamentizer.rb'

describe Reglamentizer do	
	describe "#new" do
		it "detects single variable declarations" do		
			regl = Reglamentizer.new <<~SCRIPT
				var   lorem =    "ipsum"
			SCRIPT
			
			regl.format
			expect(regl.variables).to include("lorem")
		end
		
		it "detects multiple variable declarations" do		
			regl = Reglamentizer.new <<~SCRIPT
				var    lorem,    abra    =    "ipsum",   "cadabra"
			SCRIPT
			
			regl.format
			expect(regl.variables).to include("lorem")
			expect(regl.variables).to include("abra")
		end
		
		it "detects multiline variable declarations" do
			regl = Reglamentizer.new <<~SCRIPT
				var    lorem,    abra    =    "ipsum",   "cadabra"
				var  opus  =   "magnum";
				
				var per_aspera
			SCRIPT
			
			regl.format
			expect(regl.variables).to include("lorem")
			expect(regl.variables).to include("abra")
			expect(regl.variables).to include("opus")
			expect(regl.variables).to include("per_aspera")
		end
		
		it "strips type if present" do
			regl = Reglamentizer.new <<~SCRIPT
				var    lorem : BusComp,    abra:chars    =    "ipsum",   "cadabra"
				var  opus  =   "magnum";
				
				var per_aspera: BusObject
			SCRIPT
			
			regl.format
			expect(regl.variables).to include("lorem")
			expect(regl.variables).to include("abra")
			expect(regl.variables).to include("opus")
			expect(regl.variables).to include("per_aspera")
		end
	end
	
	describe "#format" do
		it "should format script according to reglament" do
			regl = Reglamentizer.new <<~SCRIPT
				var    lorem,    abra    =    "ipsum",   "cadabra"
				var  opus  =   "magnum";
				
				var per_aspera
				
				per_aspera = lorem.toString() + shuffle(abra);
				return per_aspera;
			SCRIPT
			
			form_script = <<~SCRIPT
				try
				{
					var    lorem,    abra    =    "ipsum",   "cadabra"
					var  opus  =   "magnum";
					
					var per_aspera
					
					per_aspera = lorem.toString() + shuffle(abra);
					return per_aspera;
				}
				catch(e)
				{
					TheApplication().RaiseErrorText(e.message);
				}
				finally
				{
					per_aspera = null;
					opus = null;
					abra = null;
					lorem = null;
				}
			SCRIPT
			
			regl.format
			expect(regl.output).to eql(form_script)
		end
	end
end