object @orders
	attributes :id, :total_price,:is_paid, :status, :read
	attribute :get_order_date => "order_date"
	attribute :get_paid_date => "paid_date"