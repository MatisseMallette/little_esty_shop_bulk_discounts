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

  def applied_discount
    if self.has_applicable_discount?
      bulk_discounts
      .where('threshold < ? AND bulk_discounts.merchant_id = ?', quantity, item.merchant.id)
      .group(:id)
      .order('bulk_discounts.percentage DESC')
      .first
    else 
      return nil 
    end
  end

  def has_applicable_discount?
    if self.discounts_exist?
      bulk_discounts.each do |bd| 
        if quantity > bd.threshold 
          return true
        else  
          return false 
        end
      end
    else 
      return false 
    end
  end

  def discounts_exist? 
    bulk_discounts.count > 0
  end

  def cost_after_discount
    if self.discounts_exist?
      if has_applicable_discount?
        ((quantity * unit_price).to_f / 100) * (100 - applied_discount.percentage) 
      else 
        self.cost_before_discount 
      end
    else 
      self.cost_before_discount 
    end
  end

  def cost_before_discount 
    quantity * unit_price
  end

  def absolute_cost 
    if self.discounts_exist?
      self.cost_after_discount
    else  
      self.cost_before_discount
    end
  end
end
