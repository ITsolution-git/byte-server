require 'rails_helper'

describe OrderItem, type: :model do

  describe 'associations' do
    it { is_expected.to belong_to(:build_menu) }
    it { is_expected.to belong_to(:order) }
    it { is_expected.to belong_to(:combo_item) }
    it { is_expected.to have_many(:order_item_combos) }
    it { is_expected.to have_many(:order_item_options) }

    xcontext 'destroys dependent' do
      it 'order item combos' do
      end
      it 'order item options' do
      end
    end
  end

  it 'has a valid factory' do
    expect(build :order_item).to be_valid
  end

  describe 'allow mass assignment of' do
    it { is_expected.to allow_mass_assignment_of(:build_menu_id) }
    it { is_expected.to allow_mass_assignment_of(:order_id) }
    it { is_expected.to allow_mass_assignment_of(:quantity) }
    it { is_expected.to allow_mass_assignment_of(:note) }
    it { is_expected.to allow_mass_assignment_of(:use_point) }
    it { is_expected.to allow_mass_assignment_of(:status) }
    it { is_expected.to allow_mass_assignment_of(:paid_type) }
    it { is_expected.to allow_mass_assignment_of(:price) }
    it { is_expected.to allow_mass_assignment_of(:redemption_value) }
    it { is_expected.to allow_mass_assignment_of(:rating) }
    it { is_expected.to allow_mass_assignment_of(:comment) }
  end

  describe 'OrderItem methods' do
    let!(:order) { create :order }
    let!(:item) { create :order_item }
    let!(:combo) { create :order_item_combo }
    let(:combos) { ActiveSupport::JSON.decode({ id: combo.id.to_s,
                                                quantity: 1,
                                                price: 2,
                                                note: 'note',
                                                use_point: 3,
                                                paid_quantity: 4 }.to_json) }
    let!(:order_item) { ActiveSupport::JSON.decode({ id: item.id,
                                                     quantity: 5,
                                                     note: 'note',
                                                     use_point: 7.0,
                                                     status: 1,
                                                     order_item_combos: [combos] }.to_json) }

    context '.delete_item' do
      subject { lambda { |item_id| OrderItem.delete_item(item_id) } }

      it { expect{ subject.call(order_item) }.to change{OrderItem.count}.by(-1) }
      it {
            order_item['id'] = order_item['id'] + 1
            expect{ subject.call(order_item) }.not_to change{OrderItem.count}
         }
    end

    context '.update_an_item' do
      subject { lambda { |item, status, is_paid| OrderItem.update_an_item(item, status, is_paid) } }

      it 'is found' do
        subject.call(order_item, true, true)
        item.reload
        expect(item.status).to be_eql(order_item['status'])
        expect(item.quantity).to be_eql(order_item['quantity'].to_i)
        expect(item.use_point).to be_eql(order_item['use_point'])
        expect(item.note).to be_eql(order_item['note'])
      end
    end

    context '.update_items' do
      subject { lambda { |items, order, is_paid| OrderItem.update_items([items], order, is_paid) } }

      it 'removes item when "is_delete" is set' do
        order_item['is_delete'] = 1
        expect { subject.call(order_item, item, true) }.to change{ OrderItem.count }.by(-1)
      end

      it 'updates item when "is_delete" unset' do
        order_item['is_delete'] = 0
        expect { subject.call(order_item, item, true) }.to change{ OrderItem.count }.by(0)
        item.reload
        expect(item.status).to be_eql(order_item['status'])
        expect(item.quantity).to be_eql(order_item['quantity'].to_i)
        expect(item.use_point).to be_eql(order_item['use_point'])
        expect(item.note).to be_eql(order_item['note'])
      end
    end

    xdescribe '.add_new_item' do
      context 'v0' do
        subject { lambda { |item, order| OrderItem.add_new_item(item, order) } }

        it 'creates new item with OrderItemCombo' do
          expect { subject.call(order_item, order) }.to change{ OrderItem.count }.by(1)
          item.reload
          expect(item.status).to be_eql(order_item['status'])
          expect(item.quantity).to be_eql(order_item['quantity'].to_i)
          expect(item.use_point).to be_eql(order_item['use_point'])
          expect(item.note).to be_eql(order_item['note'])
        end

        it 'creates new item without OrderItemCombo' do
          order_item['order_item_combos'] = ''
        end
      end

      context 'v1' do
      end
    end

    xdescribe '.update_items' do
      context 'v0' do
      end

      context 'v1' do
      end
    end
  end
end
