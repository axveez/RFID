class SecprocSpb5 < SipDbBase
  belongs_to :hrd_work_shift
  has_many :secproc_spb5_items
  
  belongs_to :account_creator, :foreign_key => 'created_by', :class_name => "SysAccount",  optional: true
  belongs_to :account_updator, :foreign_key => 'updated_by', :class_name => "SysAccount",  optional: true
  belongs_to :account_approved1, :foreign_key => 'approve_1_by', :class_name => "SysAccount",  optional: true
  belongs_to :account_approved2, :foreign_key => 'approve_2_by', :class_name => "SysAccount",  optional: true
  belongs_to :account_approved3, :foreign_key => 'approve_3_by', :class_name => "SysAccount",  optional: true
  belongs_to :account_voided, :foreign_key => 'voided_by', :class_name => "SysAccount",  optional: true
  belongs_to :account_locked, :foreign_key => 'edit_lock_by', :class_name => "SysAccount",  optional: true
  belongs_to :account_canceled1, :foreign_key => 'approve_1_by', :class_name => "SysAccount",  optional: true
  belongs_to :account_canceled3, :foreign_key => 'approve_3_by', :class_name => "SysAccount",  optional: true
  belongs_to :account_canceled2, :foreign_key => 'approve_2_by', :class_name => "SysAccount",  optional: true
  belongs_to :account_void_canceled, :foreign_key => 'approve_3_by', :class_name => "SysAccount",  optional: true

end
