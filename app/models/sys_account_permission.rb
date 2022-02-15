class SysAccountPermission < SipDbBase
  belongs_to :sys_account
  belongs_to :sys_account_permission_base
end
