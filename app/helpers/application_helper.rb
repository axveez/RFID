module ApplicationHelper
  def controller?(*controller)
    controller.include?(params[:controller])
  end

  def action?(*action)
    action.include?(params[:action])
  end
  
  def document_number(plant_id, customer_id, supplier_id, department_id, prefix, tbl_name, period, kind )
    # sys_plant_id, mkt_customer_id, purch_supplier_id, sys_department_id, params[:controller], params[:tbl], date, params[:kind]
    # prefix code/ Nomor Dokumen
      case prefix
      when "mkt"  
        case tbl_name      
        when "sales_order"   
          case plant_id.to_i
          when 1
            prefix_code = 'SOT/'
          else
            prefix_code = 'SOR/'
          end
          record = (prefix+"_"+tbl_name).camelize.constantize.where("date between ? and ?", period.to_date.beginning_of_day.at_beginning_of_month(),  period.to_date.end_of_day.at_end_of_month()) #filter berdasarkan plant dan range tanggal
          record.last.blank? ? last_number = "001" : last_number = record.order(number: :asc).last.number.last(3).to_i+1
          length_last_number = last_number.to_s.length # nomor dokumen, menghitung jumlah karakter
          length_last_number == 1 ? numz = "00" : length_last_number == 2 ? numz = "0" : numz = ""  

          seq_number = prefix_code+period.strftime("%Y")+"/"+month_to_alphabetic(period.strftime("%m"))+"/"+numz+last_number.to_s
          # SOR/2016/I/374
        when "forecast","spp","do_vir"
          case tbl_name 
          when "forecast"
            prefix_code = "FRC"
            i = 10
          when "spp"
            prefix_code = "SPP"
            i = 10
          when "do_vir"
            prefix_code = "DOV"
            i = 10
          end
          year_yy = period.strftime("%y")
          month_mm = period.strftime("%m")
          records = (prefix+"_"+tbl_name).camelize.constantize.where(:sys_plant_id => plant_id).where('extract(year from date) = ?', period.strftime("%Y").to_i).where('extract(month from date) = ?', period.strftime("%m").to_i)

          seq = (records.present? ? records.last.number.to_s[i,4].to_i+1 : 1)
          length_seq = seq.to_s.length

          if length_seq == 1 
            number = "000"+seq.to_s
          elsif length_seq == 2 
            number = "00"+seq.to_s
          elsif length_seq == 3 
            number = "0"+seq.to_s
          else
            number = seq.to_s
          end
          seq_number = prefix_code+"/"+year_yy+"/"+month_mm+"/"+number
        end
      when "ppic"
        case tbl_name
        when 'pdm'
          year_yyyy = period.strftime("%Y")
          month_mm = period.strftime("%m")
          case plant_id.to_i
          when 3
            prefix_code = "PC."
          when 4
            prefix_code = "PC\\"
          else
            prefix_code = "PC/"
          end
          last = "DM"
          i = 11
          records = (prefix+"_"+tbl_name).camelize.constantize.where(:sys_plant_id=> plant_id).where('extract(year from date) = ?', period.strftime("%Y").to_i).where('extract(month from date) = ?', period.strftime("%m").to_i).order("number desc").limit(1)
          seq = records.present? ? records.first.number.to_s[i,4].to_i+1 : 1
          length_seq = seq.to_s.length
          number = (length_seq == 1 ? "00"+seq.to_s : (length_seq == 2 ? "0"+seq.to_s : seq.to_s))
          seq_number = prefix_code+year_yyyy+"/"+month_mm+"/"+number+"/"+last
        end
      when "purch"
        case tbl_name
        when 'ppb'
          department = SysDepartment.find_by(:id=> department_id)
          year_yyyy = period.strftime("%Y")
          month_mm = period.strftime("%m")
          first = (department.present? ? department.from_erp[0,2] : nil)
          i = 11
          records = (prefix+"_"+tbl_name).camelize.constantize.where(:kind=> kind, :sys_plant_id=> plant_id).where('extract(year from date) = ?', period.strftime("%Y").to_i).where('extract(month from date) = ?', period.strftime("%m").to_i).where("number like ?", "#{first}%").order("number desc").limit(1)
          seq = (records.present? ? records.first.number.to_s[i,3].to_i+1 : 1)
          length_seq = seq.to_s.length
          length_seq == 1 ? number = "00"+seq.to_s : length_seq == 2 ? number = "0"+seq.to_s : number = seq.to_s

          case kind
          when 'mat'
            last = "MR"
          when 'sub'
            last = "SC"
          when 'gen'
            last = "GEN"
          when 'asset'
            last = "AS"
          when 'service'
            last = "SV"
          end
          seq_number = "#{first}/#{year_yyyy}/#{month_mm}/#{number}/#{last}"
        when 'quo'
          year_yyyy = period.strftime("%Y")
          month_mm = period.strftime("%m")
          records = (prefix+"_"+tbl_name).camelize.constantize.where(:kind=> kind, :sys_plant_id=> plant_id).where('extract(year from date) = ?', period.strftime("%Y").to_i).where('extract(month from date) = ?', period.strftime("%m").to_i).order("number desc").limit(1)
          i = 11
          seq = records.present? ? records.first.number.to_s[i,3].to_i+1 : 1
          case kind
          when 'mat'
            last = "MR"
          when 'sub'
            last = "SC"
          when 'gen'
            last = "GS"
          end
          first = "QT"
          length_seq = seq.to_s.length
          length_seq == 1 ? number = "00"+seq.to_s : length_seq == 2 ? number = "0"+seq.to_s : number = seq.to_s
          seq_number = "#{first}/#{year_yyyy}/#{month_mm}/#{number}/#{last}"
        when 'po'
          year = period.strftime("%Y")
          month = period.strftime("%m")
          case plant_id.to_i
          when 3
            first = "PO2-"
            i = 11
          when 4
            first = "PO2/"
            i = 11
          else
            first = "PO/"
            i = 10
          end
          month_abc = month_to_alphabetic(month.to_s)

          # records = table.where(:kind=> kind, :sys_plant_id=> plant).where('extract(year from date) = ?', date.strftime("%Y").to_i).where('extract(month from date) = ?', date.strftime("%m").to_i).order("number desc").limit(1)
          # 20180808 - Aden: dibuat PO pada bulan agustus, 
            # nomor PO otomatis menjadi => PO2-2018/H/008/RMI, 
            # namun ada perubahan field date menjadi 2018-07-30, 
            # pembuatan nomor PO setelahnya mengacu pada field date dan record terakhir berdasarakn field number paling akhir. 
            # hasilnya duplikat penomoran PO. 
          
          # records = table.where(:kind=> kind, :sys_plant_id=> plant).where('extract(year from created_at) = ?', date.strftime("%Y").to_i).where('extract(month from created_at) = ?', date.strftime("%m").to_i).order("number desc").limit(1)
          # 20190227 - Aden: dibuat PO pada bulan februari dan tgl PO bulan januari, nomor PO ngaco

          records = (prefix+"_"+tbl_name).camelize.constantize.where(:kind=> kind, :sys_plant_id=> plant_id).where('extract(year from date) = ?', period.strftime("%Y").to_i).where('extract(month from date) = ?', period.strftime("%m").to_i).order("number desc").limit(1)
          # disable form input tgl PO
          case kind
          when 'virtual','vir'
            kind = 'vir' 
          end
          seq = records.present? ? records.first.number.to_s[i,3].to_i+1 : 1
            
          case kind
          when 'mi','sp' 
            kind== 'sp' ? last = 'RMS' : last = 'RMI'
          when 'sub' 
            last = (department_id == 1 ? 'SCS' : 'SCI')
          when 'gen' 
            last = 'GEN'
          when 'vir' 
            last = 'VIR'    
          end
          length_seq = seq.to_s.length
          length_seq == 1 ? number = "00"+seq.to_s : length_seq == 2 ? number = "0"+seq.to_s : number = seq.to_s
          seq_number = first+year+"/"+month_abc+"/"+number+"/"+last
        when 'ppb_monthly_summary'
          year = period.strftime("%Y").last(2)
          month = period.strftime("%m")
          month_abc = month_to_alphabetic(month)
          case kind.to_s
          when "gen"
            first = "A"
          when "technical"
            first = "C"
          end
          # first = SysDepartment.find_by(:name=>session[:department]).from_erp[0,2]
          i = 11
          records = (prefix+"_"+tbl_name).camelize.constantize.where(:sys_plant_id=> plant_id,:kind=>kind.to_s).where('extract(year from date) = ?', period.strftime("%Y").to_i).where('extract(month from date) = ?', period.strftime("%m").to_i).order("number desc").limit(1)
          seq = (records.present? ? records.first.number.last(3).to_i+1 : 1)
          length_seq = seq.to_s.length
          length_seq == 1 ? number = "00"+seq.to_s : length_seq == 2 ? number = "0"+seq.to_s : number = seq.to_s
        
          seq_number = first+""+year+""+month_abc+""+number 
        end
      when "ship"
        case tbl_name
        when 'sj_scrap'
          prefix_code = 'SJSCRAP'
        when 'sjc'
          prefix_code = 'SJC'
        when 'sj'
          prefix_code = 'SJS'
        when 'do_replacement'
          prefix_code = 'DOR'
        end
        case plant_id.to_i
        when 1
          prefix_code = "#{prefix_code}."
        when 2
          prefix_code = "#{prefix_code}/"
        when 3
          prefix_code = "#{prefix_code}-"
        when 4, 5
          prefix_code = "#{prefix_code}\\"
        end

        case tbl_name
        when 'do'
          period = period.to_date
          year = period.strftime("%y").to_s
          case plant_id.to_i
          when 2 # Jati        
            mkt_customer = MktCustomer.where(("plant_#{plant_id}").to_sym=> 1).find(customer_id)          
            if mkt_customer.present? and mkt_customer.use_prefix_do.present? # contoh: EPSON
              records       = (prefix+"_"+tbl_name).camelize.constantize.where(:sys_plant_id=> plant_id).where("date BETWEEN ? AND ?", period.at_beginning_of_year, period.at_end_of_year).where("number like ?", "%TECH").order(number: :desc).limit(1)
              if records.present? and records.first.date.strftime("%y") == year # dalam tahun yg sama
                last_number = records.first.number
                last_number.slice!  mkt_customer.prefix_do.to_s # => Hapus Prefix
                last_number.slice! "TECH" # => Hapus Suffix
                last_number = last_number.last(5).to_i # ambil counter DO
              else                                        # beda tahun reset counter
                last_number = 1
              end
            else
              records       = (prefix+"_"+tbl_name).camelize.constantize.where(:sys_plant_id=> plant_id).where("date BETWEEN ? AND ?", period.at_beginning_of_year, period.at_end_of_year).where.not("number like ?", "%TECH").order(number: :desc).limit(1)
              if records.present? and records.first.date.strftime("%y") == year # dalam tahun yg sama
                last_number = records.first.number.last(5).to_i
              else                                        # beda tahun reset counter
                last_number = 1
              end
            end
          when 1, 3, 4, 5 # Pinang
            if year.to_s == '17'
              nomor_ngaco   = ['D1725804','D1725791','D1725790','D1725789','D1725788','D1725787','D1725786','D1725785','D1725784','D1725783','D1725782','D1725781','D1725780','D1725779','D1725778','D1725777','D1725776','D1725775','D1725774','D1725773','D1725772','D1725771','D1725770','D1725769','D1725768','D1725767','D1725766','D1725765','D1725764','D1725763','D1725762','D1725761','D1725760','D1725759','D1725758','D1725757','D1725756','D1725755','D1725754','D1725753','D1725752','D1725751','D1725750','D1725749','D1725748','D1725747','D1725746','D1725745','D1725744','D1725743','D1725742','D1725741','D1725740','D1725739','D1725738','D1725737','D1725736','D1725735']
              records       = (prefix+"_"+tbl_name).camelize.constantize.where(:sys_plant_id=> plant_id).where("date BETWEEN ? AND ?", period.at_beginning_of_year, period.at_end_of_year).where.not(:number=> nomor_ngaco).order(number: :desc).limit(1)
            else
              records       = (prefix+"_"+tbl_name).camelize.constantize.where(:sys_plant_id=> plant_id).where("date BETWEEN ? AND ?", period.at_beginning_of_year, period.at_end_of_year).order(number: :desc).limit(1)
            end
            if records.present? and records.first.date.strftime("%y") == year # dalam tahun yg sama
              last_number = records.first.number.last(5).to_i     
            else                                        # beda tahun reset counter
              last_number = 1
            end     
          end
          last_number = last_number.to_i+1
          length_last_number = last_number.to_s.length # nomor dokumen, menghitung jumlah karakter
          case length_last_number 
          when 1 
            numz = "0000" 
          when 2 
            numz = "000"  
          when 3 
            numz = "00"   
          when 4 
            numz = "0" 
          when 5
            numz = ""
          end
          case plant_id.to_i
          when 1 # Kapuk
            seq_number = "T1"+year+numz+last_number.to_s
          when 2 # Jati
            if mkt_customer.present? and mkt_customer.use_prefix_do.present? # contoh: Epson
              # IEI1603255TECH
              seq_number = mkt_customer.prefix_do+year+numz+last_number.to_s+"TECH"
            else
              # 1605132
              seq_number = year+numz+last_number.to_s
            end
          when 3 # Pinang
            seq_number = "T2"+year+numz+last_number.to_s
          when 4 # DPIL
            seq_number = "D"+year+numz+last_number.to_s
            seq_number = "D1725805" if seq_number == 'D1725734'
          when 5 # Techno Kapuk
            if period.strftime("%Y-%m-%d").to_date > Date.parse("2019-10-31")
              seq_number = "D2"+year+numz+last_number.to_s
            else
              seq_number = "D"+year+numz+last_number.to_s
            end
          end
        when 'sjc', 'sj','sj_scrap','do_replacement'
          period = period.to_date
          year = period.strftime("%y")
          month = period.strftime("%m")
          
          i = 11
          records = (prefix+"_"+tbl_name).camelize.constantize.where(:sys_plant_id=> plant_id).where('extract(year from date) = ?', period.strftime("%Y").to_i).where('extract(month from date) = ?', period.strftime("%m").to_i).order(number: :desc).limit(1)
          seq = records.present? ? records.first.number.to_s[i,3].to_i+1 : 1
          length_seq = seq.to_s.length
          length_seq == 1 ? number = "000"+seq.to_s : length_seq == 2 ? number = "00"+seq.to_s : length_seq == 3 ? number = "0"+seq.to_s : number = seq.to_s
         
          seq_number = prefix_code+year+"/"+month+"/"+number
        when 'spk'
          period = period.to_date
          year = period.strftime("%y")
          i = 2
          records = (prefix+"_"+tbl_name).camelize.constantize.where(:sys_plant_id=> plant_id).where('extract(year from date) = ?', period.strftime("%Y").to_i).order(number: :desc).limit(1)
          seq = records.present? ? records.first.number.to_s[i,4].to_i+1 : 1
          length_seq = seq.to_s.length
          length_seq == 1 ? number = "000"+seq.to_s : length_seq == 2 ? number = "00"+seq.to_s : length_seq == 3 ? number = "0"+seq.to_s : number = seq.to_s
          seq_number = year+number
        when 'rit'
          first = "C - "
          i = 4
          records = (prefix+"_"+tbl_name).camelize.constantize.where(:sys_plant_id=> plant_id).order(number: :desc).limit(1)
          seq = records.present? ? records.first.number.to_s[i,3].to_i+1 : 1
          length_seq = seq.to_s.length
          length_seq == 1 ? number = "00"+seq.to_s : length_seq == 2 ? number = "0"+seq.to_s : number = seq.to_s
          seq_number = first+number
        when 'schedule_delivery'
          # SCH/20/03/006 
          period = period.to_date
          year = period.strftime("%y")
          month = period.strftime("%m")
          
          i = 11
          records = (prefix+"_"+tbl_name).camelize.constantize.where(:sys_plant_id=> plant_id).where('extract(year from date) = ?', period.strftime("%Y").to_i).where('extract(month from date) = ?', period.strftime("%m").to_i).order(number: :desc).limit(1)
          seq = records.present? ? records.first.number.last(3).to_i+1 : 1
          length_seq = seq.to_s.length
          length_seq == 1 ? number = "000"+seq.to_s : length_seq == 2 ? number = "00"+seq.to_s : length_seq == 3 ? number = "0"+seq.to_s : number = seq.to_s
         
          seq_number = "SCH/"+year+"/"+month+"/"+number
        when 'box_log'
          period = period.to_date
          year = period.strftime("%y")
          month = period.strftime("%m")
          
          i = 11
          records = (prefix+"_"+tbl_name).camelize.constantize.where(:sys_plant_id=> plant_id,:kind=>params[:kind]).where('extract(year from date) = ?', period.strftime("%Y").to_i).where('extract(month from date) = ?', period.strftime("%m").to_i).order(number: :desc).limit(1)
          seq = records.present? ? records.first.number.last(3).to_i+1 : 1
          length_seq = seq.to_s.length
          length_seq == 1 ? number = "000"+seq.to_s : length_seq == 2 ? number = "00"+seq.to_s : length_seq == 3 ? number = "0"+seq.to_s : number = seq.to_s
         
          seq_number = "BOX/#{params[:kind].upcase}/"+year+"/"+month+"/"+number
        when 'temporary_ceiling_limit'
          period = period.to_date
          year = period.strftime("%y")
          month = period.strftime("%m")
          
          i = 11
          records = (prefix+"_"+tbl_name).camelize.constantize.where(:sys_plant_id=> plant_id).where('extract(year from date) = ?', period.strftime("%Y").to_i).where('extract(month from date) = ?', period.strftime("%m").to_i).order(number: :desc).limit(1)
          seq = records.present? ? records.first.number.last(3).to_i+1 : 1
          length_seq = seq.to_s.length
          length_seq == 1 ? number = "000"+seq.to_s : length_seq == 2 ? number = "00"+seq.to_s : length_seq == 3 ? number = "0"+seq.to_s : number = seq.to_s
         
          seq_number = "TCL/"+year+"/"+month+"/"+number
        end
      when "prod"
        prefix_code = tbl_name.upcase.to_s
        case plant_id.to_i
        when 1
          prefix_code = "#{prefix_code}."
        else
          prefix_code = "#{prefix_code}/"
        end
        case tbl_name
        when 'spb2'
          # code'
          records = (prefix+"_"+tbl_name).camelize.constantize.where(:sys_plant_id => plant_id).where("date between ? and ?", period.to_date.beginning_of_day.at_beginning_of_month(),  period.to_date.end_of_day.at_end_of_month()).order(number: :desc).limit(1) #filter berdasarkan plant dan range tanggal
        
          if records.blank?
            increment = 1
          else
            increment = records.first.number.last(4).to_i+1
          end
          case increment.to_s.length
          when 1
            digit = "000"
          when 2
            digit = "00"
          when 3
            digit = "0"
          else
            digit = ""
          end

          seq_number = prefix_code+period.to_date.strftime("%y/%m/")+digit+increment.to_s
        when 'material_request'
          record = (prefix+"_"+tbl_name).camelize.constantize.where(:sys_plant_id => plant_id).order("number desc").limit(1).last
          kode2= "REQ"
          # generet disini om
          if record.present?
            new_num = record.number.last(3).to_i+1
            length_seq = new_num.to_s.length
            seq = (length_seq == 1 ? "00"+seq.to_s : (length_seq == 2 ? "0"+seq.to_s : seq.to_s))
            seq_number = "#{kode2}/#{DateTime.now.strftime('%Y')}/#{DateTime.now.strftime('%m')}/#{seq}#{new_num}"

          else
            seq_number = "#{kode2}/#{DateTime.now.strftime('%Y')}/#{DateTime.now.strftime('%m')}/001"
          end
        end
      when "secproc"
        case tbl_name
        when 'spb8out'
          prefix_code = "SPB8B"
        else
          prefix_code = tbl_name.upcase.to_s
        end

        case plant_id.to_i
        when 1
          prefix_code = "#{prefix_code}."
        else
          prefix_code = "#{prefix_code}/"
        end
        case tbl_name
        when 'spb5', 'spb8out', 'spb8'
          records = (prefix+"_"+tbl_name).camelize.constantize.where(:sys_plant_id => plant_id).where("date between ? and ?", period.to_date.beginning_of_day.at_beginning_of_month(),  period.to_date.end_of_day.at_end_of_month()).order(code: :desc).limit(1) #filter berdasarkan plant dan range tanggal
    
          if records.blank?
            increment = 1
          else
            increment = records.first.code.last(4).to_i+1
          end
          case increment.to_s.length
          when 1
            digit = "000"
          when 2
            digit = "00"
          when 3
            digit = "0"
          else
            digit = ""
          end

          seq_number = prefix_code+period.to_date.strftime("%y/%m/")+digit+increment.to_s
        end
      when "qc"
        case tbl_name 
        when 'daily_inspection'
          prefix_code = 'IPQC'
        when 'nrb_recycle'
          prefix_code = 'NRBR'
        when 'nrb_sub'
          prefix_code = 'NRBS'
        when 'nrb_dispose'
          prefix_code = 'NRBD'
        when 'spg_external'
          prefix_code = 'SPGQC-EXT'
        when 'spg_internal'
          prefix_code = 'SPGQC-INT'
        when 'adjustment'
          prefix_code = 'ADJ'
        else
          prefix_code = tbl_name.upcase.to_s
        end

        case plant_id.to_i
        when 1
          prefix_code = "#{prefix_code}."
        else
          prefix_code = "#{prefix_code}/"
        end
        case tbl_name
        when 'spb6', 'spb7', 'spb9','spg_internal','nrb_recycle', 'nrb_sub', 'nrb_dispose','spg_external','inprocess_lot_out','daily_inspection'
          # code
          records = (prefix+"_"+tbl_name).camelize.constantize.where(:sys_plant_id => plant_id).where("date between ? and ?", period.to_date.beginning_of_day.at_beginning_of_month(),  period.to_date.end_of_day.at_end_of_month()).order(code: :desc).limit(1) #filter berdasarkan plant dan range tanggal
        
          if records.blank?
            increment = 1
          else
            increment = records.first.code.last(4).to_i+1
          end
          case increment.to_s.length
          when 1
            digit = "000"
          when 2
            digit = "00"
          when 3
            digit = "0"
          else
            digit = ""
          end

          seq_number = prefix_code+period.to_date.strftime("%y/%m/")+digit+increment.to_s
        when 'adjustment'
          records = (prefix+"_"+tbl_name).camelize.constantize.where(:sys_plant_id => plant_id).where("date between ? and ?", period.to_date.beginning_of_day.at_beginning_of_month(),  period.to_date.end_of_day.at_end_of_month()).order(code: :desc).limit(1) #filter berdasarkan plant dan range tanggal
        
          if records.blank?
            increment = 1
          else
            if records.first.code.to_s[7,2] != period.to_date.strftime("%d").to_s
              increment = 1
            else
              increment = records.first.code.to_s[9,3].to_i+1
            end
          end
          case increment.to_s.length
          when 1
            digit = "00"
          when 2
            digit = "0"
          else
            digit = ""
          end
          seq_number = "#{prefix_code}"+period.to_date.strftime("%y%m%d").to_s+digit+increment.to_s
        end
      when "wh"
        case tbl_name
        when "adjustment","spbw"
          case tbl_name
          when "adjustment"
            prefix_code = "ADJ"
          when "spbw"
            prefix_code = "SPBW"
          end
        when "spg_supplier"
          case plant_id.to_i
          when 1
            prefix_code = "SPG."                  
          when 3
            prefix_code = "SPG-"
          when 4
            prefix_code = "SPG\\"
          else
            prefix_code = "SPG/"
          end
        else
          case tbl_name
          when "spbw"
            prefix_code = "SPBW"
          when "spb_machine"
            prefix_code = "SPBM"
          when "spb9out"
            prefix_code = "SPB9B"
          when "spb1sub", "spb2sub"
            prefix_code = "#{tbl_name.to_s[0,5].upcase}"
          when "spb1k", "spb3k", "spb1", "spb3","spb11"
            prefix_code = "#{tbl_name.upcase}"
          when "spg_ext_supplier"
            prefix_code = "SPG-EXTs"
          when "spg_ext_customer"
            prefix_code = "SPG-EXTc"
          when "spg_internal"
            prefix_code = "SPG-INT"
          when "spg_internal_sub"
            prefix_code = "SPG-INS"
          end

          case plant_id.to_i
          when 1
            prefix_code = "#{prefix_code}."
          else
            prefix_code = "#{prefix_code}/"
          end
        end

        case tbl_name        
        when 'spb1', 'spb1k','spb1sub', 'spb2sub', 'spb3k', 'spb3','spb9out','spg_ext_supplier','spg_ext_customer','spg_internal','spg_internal_sub','spb11'
          # code
          records = (prefix+"_"+tbl_name).camelize.constantize.where(:sys_plant_id => plant_id).where("date between ? and ?", period.to_date.beginning_of_day.at_beginning_of_month(),  period.to_date.end_of_day.at_end_of_month()).order(code: :desc).limit(1) #filter berdasarkan plant dan range tanggal
        
          if records.blank?
            increment = 1
          else
            increment = records.first.code.last(4).to_i+1
          end
          case increment.to_s.length
          when 1
            digit = "000"
          when 2
            digit = "00"
          when 3
            digit = "0"
          else
            digit = ""
          end

          seq_number = prefix_code+period.to_date.strftime("%y/%m/")+digit+increment.to_s
        when 'spg_supplier'
          records = (prefix+"_"+tbl_name).camelize.constantize.where(:sys_plant_id => plant_id, :kind=> kind).where("date between ? and ?", period.to_date.beginning_of_day.at_beginning_of_month(),  period.to_date.end_of_day.at_end_of_month()).order(code: :desc).limit(1) #filter berdasarkan plant dan range tanggal
        
          if records.blank?
            increment = 1
          else
            increment = records.first.code.to_s[4,4].to_i+1
          end
          case increment.to_s.length
          when 1
            digit = "000"
          when 2
            digit = "00"
          when 3
            digit = "0"
          else
            digit = ""
          end
          seq_number = prefix_code+digit+increment.to_s+period.to_date.strftime("%m%y")+kind.upcase
        when 'spb_machine','spbw'
          records = (prefix+"_"+tbl_name).camelize.constantize.where(:sys_plant_id => plant_id, :kind=> kind).where("date between ? and ?", period.to_date.beginning_of_day.at_beginning_of_month(),  period.to_date.end_of_day.at_end_of_month()).order(code: :desc).limit(1) #filter berdasarkan plant dan range tanggal
        
          if records.blank?
            increment = 1
          else
            case kind
            when 'in'
              increment = records.first.code.to_s[14,5].to_i+1
            when 'out'
              increment = records.first.code.to_s[15,5].to_i+1
            end
          end
          case increment.to_s.length
          when 1
            digit = "000"
          when 2
            digit = "00"
          when 3
            digit = "0"
          else
            digit = ""
          end
          seq_number = prefix_code+kind.upcase+period.to_date.strftime("%y/%m/").to_s+digit+increment.to_s
        when 'adjustment'
          records = (prefix+"_"+tbl_name).camelize.constantize.where(:sys_plant_id => plant_id).where("date between ? and ?", period.to_date.beginning_of_day.at_beginning_of_month(),  period.to_date.end_of_day.at_end_of_month()).order(code: :desc).limit(1) #filter berdasarkan plant dan range tanggal
        
          if records.blank?
            increment = 1
          else
            if records.first.code.to_s[7,2] != period.to_date.strftime("%d").to_s
              increment = 1
            else
              increment = records.first.code.to_s[9,3].to_i+1
            end
          end
          case increment.to_s.length
          when 1
            digit = "00"
          when 2
            digit = "0"
          else
            digit = ""
          end
          seq_number = "#{prefix_code}"+period.to_date.strftime("%y%m%d").to_s+digit+increment.to_s  
        end 
      when "acc"
        case tbl_name
        when "asset_management"
          asset = EngAsset.find_by(:id=>kind)
          record = (prefix+"_"+tbl_name).camelize.constantize.where(:sys_plant_id => plant_id,:eng_asset_id=>kind).order("number desc").limit(1).last
          case plant_id.to_i
          when 2
            kode2= "TI01"
          when 3
            kode2= "TS02"
          when 4
            kode2= "TI02"
          else
            kode2="TS01"
          end

          # generet disini om
          if record.present?
            new_num = record.number.last(3).to_i+1
            length_seq = new_num.to_s.length
            seq = (length_seq == 1 ? "00"+seq.to_s : (length_seq == 2 ? "0"+seq.to_s : seq.to_s))
            seq_number = "#{asset.internal_part_id[0..10]}.#{kode2}.#{seq}#{new_num}"
          else
            seq_number = "#{asset.internal_part_id[0..10]}.#{kode2}.001"
          end
          
        end
      when "fin"
        case tbl_name
        when "routine_cost","routine_cost_payment","salary_advance","proof_salary_advance","finish_salary_advance"
          record = (prefix+"_"+tbl_name).camelize.constantize.where(:sys_plant_id => plant_id).where("date between ? and ?", period.to_date.beginning_of_day.at_beginning_of_month(),  period.to_date.end_of_day.at_end_of_month()).order("created_at desc").limit(1).last
          case tbl_name
          when "routine_cost"
            kode2= "RE/"
          when "routine_cost_payment"
            kode2= "BPKBR/#{kind}"
          when "salary_advance"
            kode2= "KASBON/#{kind}"
          when "proof_salary_advance"
            kode2= "BPK/#{kind}"
          when "finish_salary_advance"
            kode2= "/#{kind}"
          end
          # generet disini om
          if record.present?
            new_num = record.number.last(3).to_i + 1
            length_seq = new_num.to_s.length
            seq = (length_seq == 1 ? "00"+seq.to_s : (length_seq == 2 ? "0"+seq.to_s : seq.to_s))
            seq_number = "#{kode2}/#{DateTime.now.strftime('%Y')}/#{DateTime.now.strftime('%m')}/#{seq}#{new_num}"

          else
            seq_number = "#{kode2}/#{DateTime.now.strftime('%Y')}/#{DateTime.now.strftime('%m')}/001"
          end
        end
      end
    # end    
    
    return seq_number
  end
end
