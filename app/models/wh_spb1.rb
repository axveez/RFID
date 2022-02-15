class WhSpb1 < SipDbBase
  belongs_to :sys_department
  belongs_to :hrd_work_shift
  has_many :wh_spb1_items
end
