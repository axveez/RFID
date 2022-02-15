class SipDbBase < ActiveRecord::Base
  self.abstract_class = true
  establish_connection :sip
end