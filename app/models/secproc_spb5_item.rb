class SecprocSpb5Item < SipDbBase
  belongs_to :secproc_spb5
  belongs_to :eng_packaging ,  optional: true
  belongs_to :eng_product, :foreign_key => 'internal_part_id', :primary_key => 'internal_part_id',  optional: true
end
