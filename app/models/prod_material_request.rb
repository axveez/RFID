class ProdMaterialRequest < SipDbBase

  belongs_to :sys_department
  belongs_to :hrd_work_shift
  belongs_to :eng_material
  has_many :prod_material_request_items
  belongs_to :account_creator, :foreign_key => 'created_by', :class_name => "SysAccount"

end
