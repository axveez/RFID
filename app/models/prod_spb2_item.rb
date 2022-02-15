class ProdSpb2Item < SipDbBase
  belongs_to :prod_spb2
  # belongs_to :qc_bqics
  belongs_to :eng_packaging ,  optional: true
  belongs_to :eng_product, :foreign_key => 'internal_part_id', :primary_key => 'internal_part_id',  optional: true

end
