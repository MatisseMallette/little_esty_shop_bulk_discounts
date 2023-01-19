require 'rails_helper'

RSpec.describe InvoiceItem, type: :model do
  describe "validations" do
    it { should validate_presence_of :invoice_id }
    it { should validate_presence_of :item_id }
    it { should validate_presence_of :quantity }
    it { should validate_presence_of :unit_price }
    it { should validate_presence_of :status }
  end
  describe "relationships" do
    it { should belong_to :invoice }
    it { should belong_to :item }
  end

  describe "class methods" do
    before(:each) do
      @m1 = Merchant.create!(name: 'Merchant 1')
      @c1 = Customer.create!(first_name: 'Bilbo', last_name: 'Baggins')
      @c2 = Customer.create!(first_name: 'Frodo', last_name: 'Baggins')
      @c3 = Customer.create!(first_name: 'Samwise', last_name: 'Gamgee')
      @c4 = Customer.create!(first_name: 'Aragorn', last_name: 'Elessar')
      @c5 = Customer.create!(first_name: 'Arwen', last_name: 'Undomiel')
      @c6 = Customer.create!(first_name: 'Legolas', last_name: 'Greenleaf')
      @item_1 = Item.create!(name: 'Shampoo', description: 'This washes your hair', unit_price: 10, merchant_id: @m1.id)
      @item_2 = Item.create!(name: 'Conditioner', description: 'This makes your hair shiny', unit_price: 8, merchant_id: @m1.id)
      @item_3 = Item.create!(name: 'Brush', description: 'This takes out tangles', unit_price: 5, merchant_id: @m1.id)
      @i1 = Invoice.create!(customer_id: @c1.id, status: 2)
      @i2 = Invoice.create!(customer_id: @c1.id, status: 2)
      @i3 = Invoice.create!(customer_id: @c2.id, status: 2)
      @i4 = Invoice.create!(customer_id: @c3.id, status: 2)
      @i5 = Invoice.create!(customer_id: @c4.id, status: 2)
      @ii_1 = InvoiceItem.create!(invoice_id: @i1.id, item_id: @item_1.id, quantity: 1, unit_price: 10, status: 0)
      @ii_2 = InvoiceItem.create!(invoice_id: @i1.id, item_id: @item_2.id, quantity: 1, unit_price: 8, status: 0)
      @ii_3 = InvoiceItem.create!(invoice_id: @i2.id, item_id: @item_3.id, quantity: 1, unit_price: 5, status: 2)
      @ii_4 = InvoiceItem.create!(invoice_id: @i3.id, item_id: @item_3.id, quantity: 1, unit_price: 5, status: 1)
    end
    it 'incomplete_invoices' do
      expect(InvoiceItem.incomplete_invoices).to eq([@i1, @i3])
    end
  end

  describe 'instance methods' do 
    before :each do 
      @merchant1 = Merchant.create!(name: 'Hair Care')
      @merchant2 = Merchant.create!(name: 'Bob')
      @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)      
      @item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: @merchant1.id)
      @item_2 = Item.create!(name: "ASDF", description: "asdf", unit_price: 10, merchant_id: @merchant2.id)

      @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
      
      @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 9, unit_price: 10, status: 2) # discount
      @ii_111 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 10, unit_price: 1, status: 2) # discount
      @ii_11 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_8.id, quantity: 1, unit_price: 10, status: 1)
      
      @ii_1111 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_2.id, quantity: 100, unit_price: 10, status: 2)
    
      
    end

    it 'applied_discount' do 
      bd1 = BulkDiscount.create!(percentage: 50, threshold: 8, merchant_id: @merchant1.id)
      bd2 = BulkDiscount.create!(percentage: 70, threshold: 8, merchant_id: @merchant1.id)
      expect(@ii_1.applied_discount).to eq(bd2)
      expect(@ii_1111.applied_discount).to eq(nil)
    end

    it 'has_applicable_discount?' do 
      bd1 = BulkDiscount.create!(percentage: 50, threshold: 8, merchant_id: @merchant1.id)
      expect(@ii_1.has_applicable_discount?).to eq(true)
      expect(@ii_1111.has_applicable_discount?).to eq(false)
    end

    it 'discounts_exist?' do 
      bd1 = BulkDiscount.create!(percentage: 50, threshold: 8, merchant_id: @merchant1.id)
      expect(@ii_1.discounts_exist?).to eq(true)
      expect(@ii_1111.discounts_exist?).to eq(false)
    end

    it 'cost_after_discount' do 
      bd1 = BulkDiscount.create!(percentage: 50, threshold: 8, merchant_id: @merchant1.id)
      expect(@ii_1.cost_after_discount).to eq(45)
      expect(@ii_1111.cost_after_discount).to eq(1000)
    end

    it 'cost_before_discount' do 
      bd1 = BulkDiscount.create!(percentage: 50, threshold: 8, merchant_id: @merchant1.id)
      expect(@ii_1.cost_before_discount).to eq(90)
    end

    it 'absolute_cost' do 
      bd1 = BulkDiscount.create!(percentage: 50, threshold: 8, merchant_id: @merchant1.id)
      expect(@ii_1.absolute_cost).to eq(45)
      expect(@ii_1111.absolute_cost).to eq(1000)
    end
  end
end
