class QcBqic < SipDbBase
  belongs_to :eng_product
  belongs_to :hrd_work_shift
  # 20210422 - aden
  belongs_to :created, :class_name => "SysAccount", foreign_key: "created_by"
  belongs_to :updated, :class_name => "SysAccount", foreign_key: "updated_by"
end