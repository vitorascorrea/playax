require 'pdf-reader'
require_relative './../importers'

class Importers::PdfEcad
  CATEGORIES = {"CA" => "Author", "E" => "Publisher", "V" => "Versionist", "SE" => "SubPublisher"}

  def initialize(path)
    @reader = PDF::Reader.new(path)
    @array = []
  end

  def works
    return @array if !@array.empty? # return the works array if is not empty
    @reader.pages.each do |page|
      page.text.each_line do |line|
        if line.match(/ LB+[ |\/]/) # book info
          @array << work(line)
        elsif line.match(/([0-9]+[0-9]+[0-9]\.[0-9]+[0-9]\.[0-9]+[0-9]\.[0-9]+[0-9])|SICAM/) # right holders
            @array.last[:right_holders] << right_holder(line)
        end
      end
    end
    @array
  end

  def right_holder(line)
    return nil if !line.match(/[0-9]{1,3}\,[0-9]{0,2}/) #return nil if line is not a right holder (using share identifier)
    ipi_match = line.match(/[0-9]+[0-9]+[0-9]\.[0-9]+[0-9]\.[0-9]+[0-9]\.[0-9]+[0-9]/).to_s.split('.').join
    right_holder = { :name => line[10,39].strip,
                    :pseudos => [{name: line[49,25].strip, main: true}],
                    :ipi => !ipi_match.empty? ? ipi_match : nil,
                    :share => line.match(/[0-9]{1,3}\,[0-9]{0,2}/).to_s.gsub(/,/,'.').to_f,
                    :society_name => line.match(/  SICAM|([0-9] [A-Z]{3,9})/).to_s[2..-1],
                    :external_ids => [{source_name: "Ecad", source_id: line.match(/[0-9]{3,6}\s/).to_s.strip}],
                    :role => CATEGORIES[line.match(/[A-Z]{1,2}\s{1,3}[0-9]/).to_s[0,3].strip]
                   }
  end

  def work(line)
    return nil if line.match(/[0-9]{1,3}\,[0-9]{0,2}/) #return nil if line is not a work (using share identifier)
    aux_hash ={:iswc => line.match(/(T\-[0-9]{3}\.[0-9]{3}\.[0-9]{3}\-[0-9])|\-   \.   \.   \-/).to_s,
               :title => line[35,50].strip,
               :external_ids => [{source_name: "Ecad", source_id: line.match(/[0-9]{5,10}\s/).to_s.strip}],
               :situation => line.match(/ LB | LB\/DE | LB\/BL\/DE /).to_s.strip,
               :created_at => line.match(/[0-9]{2}\/[0-9]{2}\/[0-9]{4}/).to_s,
               :right_holders => []
              }
  end
end
