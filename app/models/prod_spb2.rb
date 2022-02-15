class ProdSpb2 < SipDbBase
  belongs_to :hrd_work_shift
  belongs_to :sys_department
  has_many :prod_spb2_items

  def creator
    SysAccount.find(self.created_by).name
  end
  def void
    SysAccount.find(voided_by).name if SysAccount.find(voided_by).present?
  end
  def unvoid
    SysAccount.find(cancel_void_by).name if SysAccount.find(cancel_void_by).present?
  end
  def app1
    SysAccount.find(approve_1_by).name
  end
  def app2
    SysAccount.find(approve_2_by).name
  end
  def app3
    SysAccount.find(approve_3_by).name
  end
  def capp1
    SysAccount.find(cancel_approve_1_by).name
  end
  def capp2
    SysAccount.find(cancel_approve_2_by).name
  end
  def capp3
    SysAccount.find(cancel_approve_3_by).name
  end
  def update_by
    SysAccount.find(updated_by).name
  end
  def edit_lock
    SysAccount.find(edit_lock_by).name
  end
  
  def spb_item
    ProdSpb2Item.where(:prod_spb2_id=>id)
  end
end
