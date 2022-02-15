class WhItemStock < SipDbBase
  belongs_to :eng_product, :foreign_key => 'internal_part_id', :primary_key => 'internal_part_id' 
  belongs_to :eng_material, :foreign_key => 'internal_part_id', :primary_key => 'internal_part_id'
  belongs_to :eng_packaging, :foreign_key => 'internal_part_id', :primary_key => 'internal_part_id'
  belongs_to :eng_general_supply, :foreign_key => 'internal_part_id', :primary_key => 'internal_part_id'
  belongs_to :eng_asset, :foreign_key => 'internal_part_id', :primary_key => 'internal_part_id'
end