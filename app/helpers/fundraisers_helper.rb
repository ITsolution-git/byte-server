module FundraisersHelper
	def options_for_status st=nil
		@status = [['Active',1],['Suspended',2]]
		if(st==nil)
			@status
		else
			@status[st-1][0]
		end
	end
end
 