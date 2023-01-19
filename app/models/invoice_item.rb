class InvoiceItem < ApplicationRecord
  validates_presence_of :invoice_id,
                        :item_id,
                        :quantity,
                        :unit_price,
                        :status

  belongs_to :invoice
  belongs_to :item
  has_many :merchants, through: :item
  has_many :bulk_discounts, through: :merchants

  enum status: [:pending, :packaged, :shipped]

  def self.incomplete_invoices
    invoice_ids = InvoiceItem.where("status = 0 OR status = 1").pluck(:invoice_id)
    Invoice.order(created_at: :asc).find(invoice_ids)
  end

  def applied_discount(merchant)
    bulk_discount = bulk_discounts
    .where('threshold < ? AND bulk_discounts.merchant_id = ?', quantity, merchant.id)
    .group(:id)
    .order('bulk_discounts.percentage DESC')
    .first

    return bulk_discount
  end

  def cost_after_discount 
    ((quantity * unit_price).to_f / 100) * (100 - applied_discount.percentage) 
  end
end
