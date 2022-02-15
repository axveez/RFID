class ProdMaterialRequestItem < SipDbBase

  belongs_to :prod_material_request
  belongs_to :eng_material
  belongs_to :eng_packaging
  belongs_to :sys_unit
  has_many :wh_spb1_items

end
