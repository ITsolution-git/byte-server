class City < ActiveRecord::Base
  attr_accessible :name, :state_code, :country_code

  belongs_to :state, foreign_key: 'state_code', class_name: 'State'
  belongs_to :country, foreign_key: 'country_code', class_name: 'Country'

  def self.find_city_by_name(text)
    sql = "SELECT *, char_length(name) as len FROM cities
           WHERE MATCH (name) AGAINST (? IN BOOLEAN MODE) order by len desc"
    completed_sql = ActiveRecord::Base.send(:sanitize_sql_array, [sql, text])
    return self.find_by_sql(completed_sql)
  end
end
