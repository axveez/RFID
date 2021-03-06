class Spb5Controller < ApplicationController
  # before_action :authenticate_user!
  skip_before_action :verify_authenticity_token
  include ApplicationHelper

  def index
    @rfid_config = RfidConfiguration.find_by(:feature=>"spb5")
    @plants = session[:duty_plant_id]
  end

  def stop_ws
    kembali = []
    # identity = EngPackagingIdentity.where(:number=>params[:record].map { |e| e["epc_value"] }).select("eng_packaging_identities.*,eng_packagings.internal_part_id,eng_packagings.name as part_name").joins(:eng_packaging) if params[:record].present?
    
    combine = ProdCombineLabel.where(:rfid_number=>params[:record].map { |e| e["epc_value"] }) if params[:record].present?
              # .where(:qc_label_product=>)
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


    start_month = Date.today.at_beginning_of_month.strftime("%Y-%m-%d")
    end_month = Date.today.end_of_month.strftime("%Y-%m-%d")
    # @bqics = QcBqic.where("date between ? and ?", start_month, end_month)

     # if params[:record].present?
    params[:record].each do |rec|
      combine_detail = combine.find_by(:rfid_number=>rec["epc_value"])
      label_detail =  (combine_detail.qc_label_product if combine_detail.present? and combine_detail.qc_label_product_id.present?)
      kembali += [{:epc=>rec["epc"],
        :epc_value=>rec["epc_value"],
        :antenna_id=>rec["antenna_id"],
        :datetime=>rec["datetime"].to_time,
        :qc_label_product_id=>(combine_detail.qc_label_product_id if combine_detail.present?),
        :label_number=>(combine_detail.label_number if combine_detail.present?),
        :label_number_count=>(combine_detail.label_number.split('-')[1] if combine_detail.present? and combine_detail.label_number.present?),
        :eng_product_id=>(label_detail.eng_product_id if label_detail.present?),
        :internal_part_id=>(label_detail.eng_product.internal_part_id if label_detail.present?),
        :part_name=>(label_detail.eng_product.name if label_detail.present?),
        :quantity_label=>(label_detail.quantity if label_detail.present?),
        :quantity=>(label_detail.quantity_box if label_detail.present?),
        :quantity_last=>(label_detail.quantity_box_last if label_detail.present?).to_i,
        :bqics=>(nil),
        :qty_stock=>1}]
    end  if params[:record].present?
    data = {:status=>"200 OK",:data=>kembali,:msg=>"Akpiiz"}
    render :json  => JSON.pretty_generate(data)
  end

  def cru
    status = "200 OK"
    message1 = ""
    message2 = ""
    if params[:record].present? and params["select_plant"].present?
      if status == "200 OK"
        message1 = "Akpiiz"
        message2 = ""
        record_save = []
        params[:record].each do |record|
          record_save.push({
                          "internal_part_id"=>record["internal_part_id"], 
                          "quantity"=>record["quantity"], 
                          "total_box"=>record["box_total"], 
                          "quantity_box"=>record["qty_box"], 
                          "eng_packaging_id"=> (record["eng_packaging_id"] if record["eng_packaging_id"].present?), 
                          "eng_product_id"=> (record["eng_product_id"] if record["eng_product_id"].present?),
                          "note"=> "spb5 by RFID",
                          "note2"=> "spb5 by RFID",
                          "status"=> "active",
                          "created_by"=>session[:id],
                          "created_at"=>DateTime.now()
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
        params[:header]["sys_plant_id"] = params["select_plant"]
        params[:header]["date"] = DateTime.now()
        params[:header]["special_document"] = 0
        params[:header]["code"] = document_number(params[:header]["sys_plant_id"], nil, nil, nil, "secproc", "spb5", params[:header]["date"], nil )
        params[:header]["hrd_work_shift_id"] = shift_now
        params[:header]["created_by"] = session[:id]
        params[:header]["created_at"] = DateTime.now()

 
        begin
          record = SecprocSpb5.new(params[:header].permit!)
          
          if record.save
            record.secproc_spb5_items.build(record_save)
            
            # record.save
            flash.now[:success] = "Berhasil Save dengan nomor Dokumen #{record.code}, silahkan buka SIP"
          else
            status = "403 Forbidden"
            message1 = "ERROR CREATE"
            message2 = ""
          end

          
            puts record_save
            puts record.save
            puts record.valid?
            puts record.errors.as_json
        rescue StandardError => error
          status = "403 Forbidden"
          message1 = "#{error}"
          message2 = ""
          puts error
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
