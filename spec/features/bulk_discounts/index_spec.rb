require 'rails_helper'

RSpec.describe 'bulk discount index' do 
  before :each do
    @merchant1 = Merchant.create!(name: 'Hair Care')

    @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
    @customer_2 = Customer.create!(first_name: 'Cecilia', last_name: 'Jones')
    @customer_3 = Customer.create!(first_name: 'Mariah', last_name: 'Carrey')
    @customer_4 = Customer.create!(first_name: 'Leigh Ann', last_name: 'Bron')
    @customer_5 = Customer.create!(first_name: 'Sylvester', last_name: 'Nader')
    @customer_6 = Customer.create!(first_name: 'Herber', last_name: 'Kuhn')

    @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2)
    @invoice_2 = Invoice.create!(customer_id: @customer_1.id, status: 2)
    @invoice_3 = Invoice.create!(customer_id: @customer_2.id, status: 2)
    @invoice_4 = Invoice.create!(customer_id: @customer_3.id, status: 2)
    @invoice_5 = Invoice.create!(customer_id: @customer_4.id, status: 2)
    @invoice_6 = Invoice.create!(customer_id: @customer_5.id, status: 2)
    @invoice_7 = Invoice.create!(customer_id: @customer_6.id, status: 1)

    @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id)
    @item_2 = Item.create!(name: "Conditioner", description: "This makes your hair shiny", unit_price: 8, merchant_id: @merchant1.id)
    @item_3 = Item.create!(name: "Brush", description: "This takes out tangles", unit_price: 5, merchant_id: @merchant1.id)
    @item_4 = Item.create!(name: "Hair tie", description: "This holds up your hair", unit_price: 1, merchant_id: @merchant1.id)

    @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 1, unit_price: 10, status: 0)
    @ii_2 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_2.id, quantity: 1, unit_price: 8, status: 0)
    @ii_3 = InvoiceItem.create!(invoice_id: @invoice_2.id, item_id: @item_3.id, quantity: 1, unit_price: 5, status: 2)
    @ii_4 = InvoiceItem.create!(invoice_id: @invoice_3.id, item_id: @item_4.id, quantity: 1, unit_price: 5, status: 1)
    @ii_5 = InvoiceItem.create!(invoice_id: @invoice_4.id, item_id: @item_4.id, quantity: 1, unit_price: 5, status: 1)
    @ii_6 = InvoiceItem.create!(invoice_id: @invoice_5.id, item_id: @item_4.id, quantity: 1, unit_price: 5, status: 1)
    @ii_7 = InvoiceItem.create!(invoice_id: @invoice_6.id, item_id: @item_4.id, quantity: 1, unit_price: 5, status: 1)

    @transaction1 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: @invoice_1.id)
    @transaction2 = Transaction.create!(credit_card_number: 230948, result: 1, invoice_id: @invoice_3.id)
    @transaction3 = Transaction.create!(credit_card_number: 234092, result: 1, invoice_id: @invoice_4.id)
    @transaction4 = Transaction.create!(credit_card_number: 230429, result: 1, invoice_id: @invoice_5.id)
    @transaction5 = Transaction.create!(credit_card_number: 102938, result: 1, invoice_id: @invoice_6.id)
    @transaction6 = Transaction.create!(credit_card_number: 879799, result: 1, invoice_id: @invoice_7.id)
    @transaction7 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: @invoice_2.id)

    @bulk_discount1 = @merchant1.bulk_discounts.create!(percentage: 20, threshold: 10)
    @bulk_discount2 = @merchant1.bulk_discounts.create!(percentage: 30, threshold: 15)
    @bulk_discount3 = @merchant1.bulk_discounts.create!(percentage: 40, threshold: 20)

    visit merchant_bulk_discounts_path(@merchant1)
  end

  it 'displays a list of bulk discounts for the merchant' do 
    expect(page).to have_content("20% off orders of more than 10")
    expect(page).to have_content("30% off orders of more than 15")
    expect(page).to have_content("40% off orders of more than 20")
  end

  it 'displays a list of bulk discounts for the merchant as links' do 
    expect(page).to have_link("20% off orders of more than 10")
    expect(page).to have_link("30% off orders of more than 15")
    expect(page).to have_link("40% off orders of more than 20")

    click_link("20% off orders of more than 10")

    expect(current_path).to eq("/merchant/#{@merchant1.id}/bulk_discounts/#{@bulk_discount1.id}")
  end

  it 'displays a link to create a new discount' do 
    expect(page).to have_link("Create Discount")
  end

  it 'redirects to merchant bulk discount new page upon clicking link' do 
    click_link 'Create Discount'
    expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant1))
  end

  it 'displays a link to delete discount next to each discount' do 
    expect(page).to have_link('Delete', id: @bulk_discount1.id)
    expect(page).to have_link('Delete', id: @bulk_discount2.id)
    expect(page).to have_link('Delete', id: @bulk_discount3.id)
  end

  it 'deletes discount upon clicking delete' do 
    click_link('Delete', id: @bulk_discount1.id)
    expect(current_path).to eq(merchant_bulk_discounts_path(@merchant1))
    expect(page).to_not have_content("20% off orders of more than 10")
    expect(page).to have_content("30% off orders of more than 15")
    expect(page).to have_content("40% off orders of more than 20")
  end

  it 'displays upcoming holidays' do 
    visit merchant_bulk_discounts_path(@merchant1.id)
    holidays = DateService.next_three_holidays
    # obviously this is a pretty bad test
    expect(DateService.next_three_holidays).to eq(holidays)
    expect(page).to have_content(holidays[0])
    expect(page).to have_content(holidays[1])
    expect(page).to have_content(holidays[2])
  end
end