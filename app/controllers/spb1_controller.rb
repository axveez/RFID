class Spb1Controller < ApplicationController
  # before_action :authenticate_user!
  skip_before_action :verify_authenticity_token
  include ApplicationHelper

  def index
    @rfid_config = RfidConfiguration.find_by(:feature=>"spb1")
    @plants = session[:duty_plant_id]
    # @requests = ProdMaterialRequest.where(:sys_plant_id=>params[:plant_id],:status=>"app3").where("outstanding >= 0")
    # @request_items =  ProdMaterialRequestItem.where("outstanding_item >= 0").where(:prod_material_request_id=>params[:request_id])
                      # .joins("LEFT join wh_item_stocks on wh_item_stocks.internal_part_id = prod_material_request_items.internal_part_id AND wh_item_stocks.id = ( SELECT id FROM wh_item_stocks WHERE sys_plant_id = #{params[:plant_id]} AND prod_material_request_items.internal_part_id = wh_item_stocks.internal_part_id ORDER BY id DESC LIMIT 1)")
                      # .select("prod_material_request_items.*, wh_item_stocks.quantity as qty_stock") if params[:request_id].present?
    # @stock = (WhItemStock.where(:sys_plant_id=> plant, :internal_part_id=> params[:part_id]).last.quantity 
  end

  def stop_ws
    kembali = []
    identity = EngPackagingIdentity.where(:number=>params[:record].map { |e| e["epc_value"] })
    .joins(:eng_packaging)
    .joins("LEFT join wh_item_stocks on wh_item_stocks.internal_part_id = eng_packagings.internal_part_id AND wh_item_stocks.id = ( SELECT id FROM wh_item_stocks WHERE sys_plant_id = #{params[:plant_id]} AND eng_packagings.internal_part_id = wh_item_stocks.internal_part_id ORDER BY id DESC LIMIT 1)")
    .select("eng_packaging_identities.*,eng_packagings.internal_part_id,eng_packagings.name as part_name, wh_item_stocks.quantity as qty_stock") if params[:record].present? and params[:plant_id].present?
    params[:record].each do |rec|
      part = identity.select { |e| e["number"]==rec["epc_value"]  }.as_json[0]
      kembali += [{:epc=>rec["epc"],
        :epc_value=>rec["epc_value"],
        :antenna_id=>rec["antenna_id"],
        :datetime=>rec["datetime"].to_time,
        :packaging_id=>(part["eng_packaging_id"] if part.present?),
        :identity_id=>(part["id"] if part.present?),
        :internal_part_id=>(part["internal_part_id"] if part.present?),
        :part_name=>(part["part_name"] if part.present?),
        :quantity=>1,
        :qty_stock=>(part["qty_stock"] if part.present?)}]
    end  if params[:record].present?
    data = {:status=>"200 OK",:data=>kembali,:msg=>"PT. Tri-Saudara Sentosa Industri"}
    render :json  => JSON.pretty_generate(data)
  end

  def cru
    status = "200 OK"
    message1 = ""
    message2 = ""
    if params[:record].present?
      params[:record].each do |record|
        # puts record["quantity"]
        if record["quantity"].to_f > record["qty_stock"].to_f
          message1 = "Quantity tidak boleh lebih dari Stock"
          status = "403 Forbidden"
        end

        # if record["quantity"].to_f > record["outstanding"].to_f
        #   message2 = ", Quantity tidak boleh lebih dari Outstanding"
        #   status = "403 Forbidden"
        # end

      end
      if status == "200 OK"
        message1 = "PT. Tri-Saudara Sentosa Industri"
        message2 = ""
        record_save = []
        params[:record].each do |record|
          cek = ProdCombineLabel.where(:rfid_number=>record["epc_value"].split(','))
          cek.update_all({
            :qc_label_product_id=> nil,
            :label_number=> nil,
            :updated_at=>DateTime.now(),
            :updated_by=>session[:id]
          }) if cek.present?

          record_save.push({
                          "internal_part_id"=>record["internal_part_id"], 
                          "quantity"=>record["quantity"], 
                          "eng_packaging_id"=> (record["eng_packaging_id"] if record["eng_packaging_id"].present?), 
                          "eng_material_id"=> (record["eng_material_id"] if record["eng_material_id"].present?),
                          "created_by" => session[:id],
                          "created_at" => DateTime.now(),
                          # "prod_material_request_item_id"=> record["prod_material_request_item_id"]
                        })
        end

        # ------------Menentukan Shift------------------------------- 
        now = Time.now
        hour = now.hour
        min = now.min
        sec = now.sec
        if hour >= 8 and min >= 00 and sec >= 00 and hour <= 15 and min <= 59 and sec <= 59 
          shift_now = 2
        elsif hour >= 16 and min >= 00 and sec >= 00 and hour <= 23 and min <= 59 and sec <= 59 
          shift_now = 3
        elsif hour >= 00 and min >= 00 and sec >= 00 and hour <= 7 and min <= 59 and sec <= 59 
          shift_now = 4
        end 
      # -----------------------------------------------------------
        params[:header]["date"] = DateTime.now()
        params[:header]["code"] = document_number(params[:header]["sys_plant_id"], nil, nil, params[:header]["sys_department_id"], "wh", "spb1", params[:header]["date"], nil )
        params[:header]["hrd_work_shift_id"] = shift_now
        params[:header]["created_by"] = session[:id]
        params[:header]["created_at"] = DateTime.now()

        puts params[:header].permit!
        puts record_save
        begin
          record = WhSpb1.new(params[:header].permit!)
          record.send("wh_spb1_items").build(record_save)
          record.save
          puts record.errors.as_json

          flash.now[:success] = "Berhasil Save dengan nomor Dokumen #{record.code}, silahkan buka SIP"
        rescue StandardError => error
          status = "403 Forbidden"
          message1 = "#{error}"
          message2 = ""
          
        end
      end
        
    else
      status = "403 Forbidden"
      message1 = "Check Ulang Form Anda"
      message2 = ""
    end

    if status == "403 Forbidden"
      flash.now[:error] = "#{message1}#{message2}"
    end
    data = {:status=>"#{status}",:data=>"",:msg=>"#{message1}#{message2}"}
    # render :json  => JSON.pretty_generate(data)
  end
end
