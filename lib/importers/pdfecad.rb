require 'pdf-reader'
require_relative './../importers'

class Importers::PdfEcad
  #corrigir aqui
  CATEGORIES = {"DC" => "Author", "SM" => "Author", "CA" => "Author", "C" => "Author", "E" => "Publisher", "V" => "Versionist", "SE" => "SubPublisher"}

  def initialize(path)
    @reader = PDF::Reader.new(path)
    @array = []
  end

  def works
    @reader.pages.each do |page|
      aux_hash = {:right_holders => []}
      page.text.each_line do |line|
        if line.match(/ LB+[ |\/]/) # book info
          aux_hash = create_book_hash(line)
          @array << aux_hash
        elsif line.match(/[0-9]+[0-9]+[0-9]\.[0-9]+[0-9]\.[0-9]+[0-9]\.[0-9]+[0-9]/) # right holders
            aux_hash[:right_holders] << dry_right_holder(line)
        end
      end
    end
    return @array
  end

  def dry_right_holder(line)
    right_holder = { :name => line[10,40].strip,
                    :pseudos => [{name: line[50,25].strip, main: true}],
                    :ipi => line.match(/[0-9]+[0-9]+[0-9]\.[0-9]+[0-9]\.[0-9]+[0-9]\.[0-9]+[0-9]/).to_s.split('.').join,
                    :share => line.match(/[0-9]{2,3}\,[0-9]{0,2}/).to_s.to_f,
                    :role => CATEGORIES.select{|key, value| key == line.match(/   [A-Z]{1,2} /).to_s.strip}.values[0] }
  end

  def right_holder(line)
    return @array.find{|hash| hash["line_text"] == line}
  end


  def work(line)
    return @array.find{|hash| hash["line_text"] == line}
  end

  def create_book_hash(line)
    aux_hash ={:iswc => line[13,15],
               :title => line[35,50].strip,
               :external_ids => [{source_name: "Ecad", source_id: line[0,10].strip}],
               :situation => line[93,8].strip,
               :created_at => line[108,14].strip,
               :right_holders => [],
               :line_text => line
              }
  end
end

# @importer = Importers::PdfEcad.new("../../pdf/careqa.pdf")
# line = "4882         CARLOS DE SOUZA                        CARLOS CAREQA            582.66.28.18 ABRAMUS          CA   100,                        1"
# rh = @importer.right_holder(line)
# puts rh.nil?
