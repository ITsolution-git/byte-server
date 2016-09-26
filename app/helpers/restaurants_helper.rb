module RestaurantsHelper
  def getOrderDay(day_operation)
    day_str = 'xxx'
    if day_operation.empty?
      day_str = EMPTY_DAY
    else
      day_choose = []
      day_operation.each do |day|
          unless day.nil?
            day_choose << DAY[day - 2]
          end
          # if day_choose.count = 1
          #   day_str = day_choose.first
          # else
          #   if day_choose.count = 2
          #     day_str = day_choose[0] + ', ' + day_choose[1]
          #   else
          #     if day_choose.count > 2
          #       day_str = day_str + JOIN_MULTIPLE_DAY
          #     end
          #   end
          # end
          if day_choose.count > 1
            if day_choose.count == 7
              day_str = 'All days'
            else
              if day_choose.count == 2
                day_str = day_choose[0] + ', ' + day_choose[1]
              else
                day_str = day_choose[0] + ', ' + day_choose[1] + JOIN_MULTIPLE_DAY
              end
            end

            # if day_operation.last == 10
            #   if day_operation.first == 9
            #     day_str = day_choose.last
            #   else
            #     day_str = day_choose.first
            #   end
            # elsif day_operation.last == 9
            #   day_str = day_choose.last
            # else
            #   day_str = day_choose.first
            # end
            # day_str = day_str + JOIN_MULTIPLE_DAY
          else
            day_str = day_choose.first
          end

      end
    end
    return day_str
  end
end
