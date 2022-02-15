class HrdEmployee < SipDbBase
  def duty_plant_name_1
    case self.duty_plant_1.to_i
    when 1
      nama = "TSSI (Kapuk)"
    when 2
      nama = "TECHNO (KB)"
    when 3
      nama = "TSSI (Pinang)"
    when 4
      nama = "TECHNO (DPIL)"
    else
      nama = nil
    end
    return nama
  end

  def duty_plant_name_2
    case self.duty_plant_2.to_i
    when 1
      nama = "TSSI (Kapuk)"
    when 2
      nama = "TECHNO (KB)"
    when 3
      nama = "TSSI (Pinang)"
    when 4
      nama = "TECHNO (DPIL)"
    else
      nama = nil
    end
    return nama
  end

  def duty_plant_name_3
    case self.duty_plant_3.to_i
    when 1
      nama = "TSSI (Kapuk)"
    when 2
      nama = "TECHNO (KB)"
    when 3
      nama = "TSSI (Pinang)"
    when 4
      nama = "TECHNO (DPIL)"
    else
      nama = nil
    end
    return nama
  end

  def duty_plant_name_4
    case self.duty_plant_4.to_i
    when 1
      nama = "TSSI (Kapuk)"
    when 2
      nama = "TECHNO (KB)"
    when 3
      nama = "TSSI (Pinang)"
    when 4
      nama = "TECHNO (DPIL)"
    else
      nama = nil
    end
    return nama
  end
end