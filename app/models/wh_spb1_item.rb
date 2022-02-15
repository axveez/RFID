class WhSpb1Item < SipDbBase
  belongs_to :wh_spb1
  belongs_to :eng_packaging,  optional: true
  belongs_to :prod_material_request_item,  optional: true
  belongs_to :eng_material,  optional: true
end
