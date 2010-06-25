require 'sinatra/base'
require 'haml'
require 'lib/extensions'
require 'fastercsv'
require 'pdfkit'

class Storyboardr < Sinatra::Base
  
  COLORS = %w( red orange green teal blue purple pink brown )
  
  get '/' do
    haml :index
  end
  
  post '/' do
    # reading from CSV file...
    file = params[:file][:tempfile]
    data = FasterCSV.parse(file)
    @stories = data.collect do |project, category, description, estimate|
      {
        :project      => project.to_s,
        :category     => category.to_s,
        :description  => description.to_s,
        :estimate     => estimate.to_s,
        :color        => nil
      }
    end
    
    # assigning colors
    index = 0
    @stories.collect{|s| s[:project].downcase }.uniq.each do |uniq_project|
      index = 0 if index == COLORS.size
      @stories.select{|s| s[:project].downcase == uniq_project}.each{|s| s[:color] = COLORS[index]}
      index += 1
    end
    
    haml :index
    
    # kit = PDFKit.new(haml(:index))
    
    # content_type 'application/pdf'
    # attachment 'stories.pdf'
    # kit.to_pdf
  end
  
end