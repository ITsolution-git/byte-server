module Api
  module V2
    class FundraisersController < Api::BaseController
	  	respond_to :json
	    skip_before_filter :authenticate_user
	    def get_fundraisers
		    # Determine the parameters

		    # Make the parameters more accessible
		    fund_ids = params[:fundraiser_ids]
		    res = []	
		    fund_ids.each do |id| 
		    	fundraiser = Fundraiser.find_by_id(id)#.select(Fundraiser.column_names - ["credit_card_expiration_date", "credit_card_number","credit_card_security_code","credit_card_type"])
		    	if(fundraiser != nil) 
			  	 	fund = {"fundraiser" => fundraiser, "locations" => fundraiser.locations, "fundraiser_types" =>fundraiser.fundraiser_types }
			    	res << fund
			    end
		    end

		    render  :json => {:fundraisers => res}

     	end
	    def get_restaurants
		    # Determine the parameters

		    # Make the parameters more accessible
		    fund_id = params[:fundraiser_id]
		    fund_type = params[:fundraiser_type]
		    res = []	
	    	fundraiser = Fundraiser.find_by_id(fund_id)
	    	if(fundraiser == nil)
		    	render  :json => {:restuarants => [], :message => "No fundraiser found"}
		    else
		    	render  :json => {:restuarants => fundraiser.locations, :message => ""}
		    end
     	 end
    end
  end
end
